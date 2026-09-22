import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/animations/animations.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';
import 'package:dr_ahmed/core/widgets/coming_soon_view.dart';
import 'package:dr_ahmed/features/settings/presentation/widgets/language_switcher.dart';
import 'package:dr_ahmed/features/settings/presentation/widgets/theme_mode_switcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('nav.settings'.tr())),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'preferences.theme'.tr(),
                    style: theme.textTheme.labelLarge,
                    textAlign: TextAlign.start,
                  ),
                  verticalSpace(8),
                  const ThemeModeSwitcher().fadeInSlideUp(),
                  verticalSpace(20),
                  Text(
                    'preferences.language'.tr(),
                    style: theme.textTheme.labelLarge,
                    textAlign: TextAlign.start,
                  ),
                  verticalSpace(8),
                  const LanguageSwitcher().fadeInSlideUp(delay: 50.ms),
                ],
              ),
            ),
            const Expanded(
              child: ComingSoonView(
                titleKey: 'common.coming_soon.title',
                icon: Icons.settings_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
