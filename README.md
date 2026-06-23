# Sheet Localization 🚀

A powerful Flutter package that allows you to manage your app's localization (translations) directly from a **Google Sheet**. Update your app's text **Over-The-Air (OTA) instantly**, without needing to push updates to the Play Store or App Store!

## ✨ Features

- **🚀 Live OTA Updates:** Change text in your Google Sheet, and the app updates automatically.
- **⚡ Offline First:** Translations are cached locally on the device for instant load times, even offline.
- **⏱️ Auto Polling:** Set an interval (e.g., 5 minutes) to fetch new text silently in the background while the user is using the app.
- **🪄 Magic `.tr` Extension:** Translate strings effortlessly like `'welcome_message'.tr`.
- **🆓 100% Free Backend:** No need to pay for Firebase or AWS; Google Sheets handles all the hosting for free.

---

## 🛠️ 1. Google Sheet Setup (Crucial Step)

Before writing any code, you need to set up your Google Sheet.

1. **Create a new Google Sheet**.
2. **Format the Headers:** 
   - The **A1** cell *must* be named exactly `key` (lowercase).
   - The subsequent columns in row 1 should be your language codes (e.g., `en`, `hi`, `es`, `fr`).
3. **Add your data:**

| key | en | hi |
|---|---|---|
| `app_title` | My App | मेरी ऐप |
| `welcome_message` | Welcome to my App | मेरी ऐप में आपका स्वागत है |
| `login_button` | Login | लॉग इन |

4. **Publish to Web:**
   - Go to **File > Share > Publish to web**.
   - Change "Web page" to **"Comma-separated values (.csv)"**.
   - Click **Publish**.
5. **Get your Sheet ID:**
   - Look at your browser's URL bar. It looks like this:
     `https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID_IS_HERE/edit#gid=0`
   - Copy that long string of random characters.

---

## 💻 2. Installation

Add the dependency to your `pubspec.yaml` (assuming local path for now, or from pub.dev once published):

```yaml
dependencies:
  flutter:
    sdk: flutter
  sheet_localization: ^0.0.1
```

---

## 🚀 3. Usage

### Step 1: Initialize the Package
Initialize the package in your `main()` function before calling `runApp`.

```dart
import 'package:sheet_localization/sheet_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SheetLocalization.init(
    sheetId: 'YOUR_GOOGLE_SHEET_ID_HERE', 
    defaultLanguage: 'en',
    // Optional: Automatically fetch updates every 5 minutes in the background
    autoRefreshInterval: const Duration(minutes: 5),
  );

  runApp(const MyApp());
}
```

### Step 2: Wrap your App
Wrap your `MaterialApp` or `CupertinoApp` with the `SheetLocalizationBuilder`. This builder listens to changes and automatically rebuilds the entire UI when new translations arrive.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SheetLocalizationBuilder(
      builder: (context) {
        return MaterialApp(
          title: 'Sheet Localization Demo',
          home: HomeScreen(), // Important: Do NOT make this 'const' if it has translations!
        );
      }
    );
  }
}
```

### Step 3: Translate Strings
Simply append `.tr` to any string key that matches your Google Sheet!

```dart
Text('welcome_message'.tr)
```

---

## ⚙️ Advanced Features

### Change the Active Language
You can switch the app's language dynamically. This will automatically rebuild the UI and save the user's preference locally.

```dart
SheetLocalization.instance.setLanguage('hi'); // Switch to Hindi
```

### Manually Force a Refresh
If you want to trigger a manual download of the latest Google Sheet data (e.g., via a "Pull to Refresh" or a button):

```dart
await SheetLocalization.instance.refresh();
```

---

## ⚠️ Important Tips

1. **Avoid `const` on localized widgets:** If you declare a widget as `const Text('title'.tr)`, Flutter will aggressively cache it and it will **not** update when the language changes or new data is fetched. Remove `const` from widgets that contain translations.
2. **Sheet Caching:** Google's direct "Publish Link" (`pub?output=csv`) has a 5-minute cache limit. This package bypasses that by hitting the direct `/export` URL, ensuring your updates are fetched instantly!

Enjoy building with live, over-the-air translations! 🎉
