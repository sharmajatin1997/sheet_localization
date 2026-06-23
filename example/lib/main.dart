import 'package:flutter/material.dart';
import 'package:sheet_localization/sheet_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // REPLACE WITH YOUR GOOGLE SHEET ID
  // Note: The sheet must be published to the web! (File -> Share -> Publish to Web)
  await SheetLocalization.init(
    // Using sheetId instead of csvUrl to bypass Google's 5-minute cache!
    sheetId: '1FOHW-OG-HFay9lE9mC-8BXTsgMwPXw76lqyQ65CS_l0', 
    defaultLanguage: 'en',
    // Automatically checks for new text every 2 secs silently!
    autoRefreshInterval: const Duration(seconds: 2),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap your app with SheetLocalizationBuilder to enable OTA updates
    return SheetLocalizationBuilder(
      builder: (context) {
        return MaterialApp(
          title: 'Sheet Localization Demo',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: HomeScreen(), // Removed const here so it rebuilds!
        );
      }
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = SheetLocalization.instance.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr),
        actions: [
          // Language Switcher
          DropdownButton<String>(
            value: currentLang,
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'hi', child: Text('Hindi')),
            ],
            onChanged: (lang) {
              if (lang != null) {
                SheetLocalization.instance.setLanguage(lang);
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'welcome_message'.tr,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('login_button'.tr),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Change a value in your Google Sheet, save it, then click the Refresh button below to see the magic!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
