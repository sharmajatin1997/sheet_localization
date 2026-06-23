import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SheetLocalization extends ChangeNotifier {
  static final SheetLocalization _instance = SheetLocalization._internal();

  static SheetLocalization get instance => _instance;

  SheetLocalization._internal();

  // Maps Language Code (e.g., 'en') to a Map of keys and values.
  // {'en': {'welcome': 'Welcome', 'login': 'Login'}, 'hi': {'welcome': 'Swagat', ...}}
  Map<String, Map<String, String>> _translations = {};
  
  String _currentLang = 'en';
  String _sheetId = '';
  String _sheetPageId = '0';
  String _csvUrl = '';
  Timer? _pollingTimer;

  String get currentLanguage => _currentLang;

  /// Change the active language and notify listeners to rebuild UI.
  void setLanguage(String lang) {
    if (_currentLang != lang) {
      _currentLang = lang;
      notifyListeners();
      
      // Save user preference
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('sheet_loc_current_lang', lang);
      });
    }
  }

  /// Force refresh translations from Google Sheets manually.
  Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    await _fetchFromGoogleSheet(prefs);
  }

  /// Initialize the package.
  /// Provide either [csvUrl] (recommended) OR [sheetId].
  /// Optionally provide [autoRefreshInterval] to auto-fetch updates silently in the background!
  static Future<void> init({
    String sheetId = '',
    String sheetPageId = '0',
    String csvUrl = '',
    String defaultLanguage = 'en',
    Duration? autoRefreshInterval,
  }) async {
    _instance._sheetId = sheetId;
    _instance._sheetPageId = sheetPageId;
    _instance._csvUrl = csvUrl;
    _instance._currentLang = defaultLanguage;
    _instance._pollingTimer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    
    // Check if user previously selected a language
    final savedLang = prefs.getString('sheet_loc_current_lang');
    if (savedLang != null) {
      _instance._currentLang = savedLang;
    }

    // 1. Load cached translations immediately so app loads fast
    await _instance._loadCachedTranslations(prefs);

    // 2. Fetch fresh translations from Google Sheets
    if (_instance._translations.isEmpty) {
      // First launch: Wait for download so user doesn't see raw keys!
      await _instance._fetchFromGoogleSheet(prefs);
    } else {
      // Subsequent launch: Update in background without blocking
      _instance._fetchFromGoogleSheet(prefs);
    }

    // 3. Setup Auto-Refresh Polling if requested
    if (autoRefreshInterval != null) {
      _instance._pollingTimer = Timer.periodic(autoRefreshInterval, (timer) {
        _instance._fetchFromGoogleSheet(prefs);
      });
    }
  }

  /// Translates a given key based on the current language.
  String translate(String key) {
    final langMap = _translations[_currentLang];
    if (langMap != null && langMap.containsKey(key)) {
      return langMap[key]!;
    }
    
    // Fallback to English if key not found in current language
    if (_currentLang != 'en' && _translations.containsKey('en')) {
      final enMap = _translations['en'];
      if (enMap != null && enMap.containsKey(key)) {
        return enMap[key]!;
      }
    }
    
    // Return key itself if not found anywhere
    return key;
  }

  Future<void> _loadCachedTranslations(SharedPreferences prefs) async {
    final cachedData = prefs.getString('sheet_loc_data');
    if (cachedData != null) {
      try {
        final decoded = jsonDecode(cachedData) as Map<String, dynamic>;
        _translations = decoded.map((key, value) {
          return MapEntry(key, Map<String, String>.from(value));
        });
        notifyListeners();
      } catch (e) {
        debugPrint('SheetLocalization: Error loading cached data: $e');
      }
    }
  }

  Future<void> _fetchFromGoogleSheet(SharedPreferences prefs) async {
    if (_sheetId.isEmpty && _csvUrl.isEmpty) return;

    final urlStr = _csvUrl.isNotEmpty 
        ? _csvUrl 
        : 'https://docs.google.com/spreadsheets/d/$_sheetId/export?format=csv&id=$_sheetId&gid=$_sheetPageId';
    final url = Uri.parse(urlStr);

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        // Parse CSV
        // We decode as utf8 to support all languages correctly
        final decodedString = utf8.decode(response.bodyBytes);
        final List<List<dynamic>> csvTable = csv.decode(decodedString);

        if (csvTable.isEmpty) return;

        // Extract Headers: [key, en, hi, fr, ...]
        final headers = csvTable[0].map((e) => e.toString().trim()).toList();
        
        // Find index of 'key' column
        final keyIndex = headers.indexOf('key');
        if (keyIndex == -1) {
          debugPrint('SheetLocalization: Missing "key" column in Google Sheet');
          return;
        }

        // Initialize empty maps for each language found in headers
        Map<String, Map<String, String>> newTranslations = {};
        for (int i = 0; i < headers.length; i++) {
          if (i != keyIndex && headers[i].isNotEmpty) {
            newTranslations[headers[i]] = {};
          }
        }

        // Process rows
        for (int i = 1; i < csvTable.length; i++) {
          final row = csvTable[i];
          if (row.length <= keyIndex) continue;
          
          final String translationKey = row[keyIndex].toString().trim();
          if (translationKey.isEmpty) continue;

          for (int j = 0; j < headers.length; j++) {
            if (j != keyIndex && j < row.length && headers[j].isNotEmpty) {
              final langCode = headers[j];
              final translationValue = row[j].toString().trim();
              if (translationValue.isNotEmpty) {
                newTranslations[langCode]![translationKey] = translationValue;
              }
            }
          }
        }

        // Update translations and notify if changed
        bool hasChanges = jsonEncode(_translations) != jsonEncode(newTranslations);
        
        if (hasChanges) {
          _translations = newTranslations;
          await prefs.setString('sheet_loc_data', jsonEncode(_translations));
          notifyListeners();
          debugPrint('SheetLocalization: Translations updated successfully!');
        }

      } else {
        debugPrint('SheetLocalization: Failed to fetch from Google Sheets. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SheetLocalization: Network error fetching translations: $e');
    }
  }
}
