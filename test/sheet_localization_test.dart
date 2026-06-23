import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheet_localization/sheet_localization.dart';

void main() {
  // Required for testing code that uses SharedPreferences or other native plugins
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock local storage for testing
    SharedPreferences.setMockInitialValues({});
  });

  test('translate returns the key itself when translations are empty or missing', () async {
    // Initialize with a fake ID for testing
    await SheetLocalization.init(sheetId: 'fake_test_id');
    
    // Since we haven't downloaded any real translations yet, 
    // it should return the key exactly as it is.
    expect('hello_world'.tr, 'hello_world');
    expect('login'.tr, 'login');
  });

  test('current language defaults to en', () async {
    await SheetLocalization.init(sheetId: 'fake_test_id');
    
    expect(SheetLocalization.instance.currentLanguage, 'en');
  });

  test('language can be changed', () async {
    await SheetLocalization.init(sheetId: 'fake_test_id');
    
    SheetLocalization.instance.setLanguage('hi');
    expect(SheetLocalization.instance.currentLanguage, 'hi');
  });
}
