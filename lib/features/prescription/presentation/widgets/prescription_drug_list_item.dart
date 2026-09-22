import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';
import 'package:dr_ahmed/features/prescription/domain/entities/prescription_drug.dart';

class PrescriptionDrugListItem extends StatelessWidget {
  final int index;
  final PrescriptionDrug drug;

  const PrescriptionDrugListItem({
    super.key,
    required this.index,
    required this.drug,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              '$index',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          horizontalSpace(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${drug.drugName} (${drug.genericName}) ${drug.dose}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                verticalSpace(2),
                Text(
                  '${drug.frequency} · ${drug.duration} · ${drug.whenToTake}',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.start,
                ),
                if (drug.notes != null && drug.notes!.isNotEmpty) ...[
                  verticalSpace(2),
                  Text(
                    drug.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
