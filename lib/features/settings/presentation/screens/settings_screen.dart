import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/core/widgets/coming_soon_view.dart';
import 'package:my_clinic/features/settings/presentation/widgets/language_switcher.dart';
import 'package:my_clinic/features/settings/presentation/widgets/theme_mode_switcher.dart';

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
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(
                        Icons.badge_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text('profile.title'.tr()),
                      subtitle: Text('profile.settings_subtitle'.tr()),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          Navigator.of(context).pushNamed(Routes.editProfile),
                    ),
                  ).fadeInSlideUp(),
                  verticalSpace(20),
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
