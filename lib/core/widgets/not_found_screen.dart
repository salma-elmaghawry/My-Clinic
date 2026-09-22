import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/routes/routes.dart';

/// Real, styled handler for [MaterialApp.onUnknownRoute] — a bad or stale
/// route name should never surface Flutter's raw "No route defined" text
/// to a doctor mid-shift.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 56.sp,
                  color: theme.colorScheme.primary,
                ),
                verticalSpace(16),
                Text(
                  'common.not_found.title'.tr(),
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                verticalSpace(8),
                Text(
                  'common.not_found.description'.tr(),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                verticalSpace(24),
                FilledButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.main, (route) => false),
                  child: Text('common.not_found.go_home'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
