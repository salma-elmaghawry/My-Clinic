import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/animations/animations.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';

/// Shared placeholder for features explicitly deferred to a later pass
/// (Appointments, full Drug Database, Notes & Stats, ...).
class ComingSoonView extends StatelessWidget {
  final String titleKey;
  final IconData icon;

  const ComingSoonView({
    super.key,
    required this.titleKey,
    this.icon = Icons.hourglass_top_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40.sp, color: theme.colorScheme.primary),
            ),
            verticalSpace(16),
            Text(
              titleKey.tr(),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            verticalSpace(8),
            Text(
              'common.coming_soon.description'.tr(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ).fadeInScale(),
      ),
    );
  }
}
