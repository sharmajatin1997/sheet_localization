import 'package:flutter/material.dart';
import 'sheet_localization_core.dart';

/// A widget that listens to changes in [SheetLocalization] and rebuilds its child.
/// This should wrap your MaterialApp or CupertinoApp.
class SheetLocalizationBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const SheetLocalizationBuilder({Key? key, required this.builder})
    : super(key: key);

  @override
  State<SheetLocalizationBuilder> createState() =>
      _SheetLocalizationBuilderState();
}

class _SheetLocalizationBuilderState extends State<SheetLocalizationBuilder> {
  @override
  void initState() {
    super.initState();
    SheetLocalization.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    SheetLocalization.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    // Rebuild the app when translations update or language changes
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // We pass the current language as a key to force rebuilds if needed,
    // though setState is usually enough.
    return KeyedSubtree(
      key: ValueKey(SheetLocalization.instance.currentLanguage),
      child: widget.builder(context),
    );
  }
}
