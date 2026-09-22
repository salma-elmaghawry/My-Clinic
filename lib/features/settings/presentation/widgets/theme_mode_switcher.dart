import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/theme/controller/theme_cubit.dart';
import 'package:my_clinic/core/theme/controller/theme_state.dart';

class ThemeModeSwitcher extends StatelessWidget {
  const ThemeModeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('preferences.theme_light'.tr()),
              icon: const Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('preferences.theme_dark'.tr()),
              icon: const Icon(Icons.dark_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('preferences.theme_system'.tr()),
              icon: const Icon(Icons.brightness_auto_outlined),
            ),
          ],
          selected: {state.themeMode},
          onSelectionChanged: (selection) {
            context.read<ThemeCubit>().setThemeMode(selection.first);
          },
          style: SegmentedButton.styleFrom(
            textStyle: theme.textTheme.labelMedium,
            selectedForegroundColor: Colors.white,
            selectedBackgroundColor: theme.colorScheme.primary,
          ),
          showSelectedIcon: false,
        );
      },
    );
  }
}
