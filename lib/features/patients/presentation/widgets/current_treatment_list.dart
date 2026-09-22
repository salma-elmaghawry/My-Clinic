import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/features/patients/domain/entities/treatment_item.dart';

class CurrentTreatmentList extends StatelessWidget {
  final List<TreatmentItem> treatments;

  const CurrentTreatmentList({super.key, required this.treatments});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (treatments.isEmpty) {
      return Center(child: Text('common.no_data'.tr()));
    }
    final tiles = treatments
        .map(
          (treatment) => Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.medication_outlined, color: theme.colorScheme.tertiary),
                horizontalSpace(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        treatment.drugName,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        treatment.frequency,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.start,
                      ),
                      if (treatment.notes != null)
                        Text(
                          treatment.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.start,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: tiles.animateList(),
    );
  }
}
