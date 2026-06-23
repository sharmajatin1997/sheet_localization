import 'sheet_localization_core.dart';

/// Extension to make translating strings effortless.
/// Usage: 'welcome_message'.tr
extension SheetLocalizationStringX on String {
  /// Translates the string key using the current language from [SheetLocalization].
  String get tr {
    return SheetLocalization.instance.translate(this);
  }
}
