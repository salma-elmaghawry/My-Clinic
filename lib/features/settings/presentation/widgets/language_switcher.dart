import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_clinic/core/injection/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentCode = context.locale.languageCode;
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'en', label: Text('EN')),
        ButtonSegment(value: 'ar', label: Text('AR')),
      ],
      selected: {currentCode},
      onSelectionChanged: (selection) async {
        final code = selection.first;
        await context.setLocale(Locale(code));
        await getIt<SharedPreferences>().setString('app_locale', code);
      },
      style: SegmentedButton.styleFrom(
        textStyle: theme.textTheme.labelMedium,
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: theme.colorScheme.primary,
      ),
      showSelectedIcon: false,
    );
  }
}
