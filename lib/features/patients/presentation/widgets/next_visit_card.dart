import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/animations/animations.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';
import 'package:dr_ahmed/features/patients/domain/entities/next_visit.dart';

class NextVisitCard extends StatelessWidget {
  final NextVisit? nextVisit;

  const NextVisitCard({super.key, this.nextVisit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visit = nextVisit;
    if (visit == null) {
      return Center(child: Text('common.no_data'.tr()));
    }
    final dateFormat = DateFormat.yMMMEd(context.locale.toString());
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(Icons.event_available, color: theme.colorScheme.primary, size: 28.sp),
            horizontalSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(visit.dateTime),
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.start,
                  ),
                  verticalSpace(4),
                  Text(
                    visit.reminderSet
                        ? 'patients.detail.next_visit.reminder_set'.tr()
                        : '',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            if (visit.reminderSet)
              Icon(Icons.notifications_active,
                  color: theme.colorScheme.secondary, size: 20.sp),
          ],
        ),
      ),
    ).fadeInScale();
  }
}
