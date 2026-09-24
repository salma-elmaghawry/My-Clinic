import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/features/patients/domain/entities/medical_history_entry.dart';

class MedicalHistoryList extends StatelessWidget {
  final List<MedicalHistoryEntry> entries;
  final VoidCallback onAdd;
  final ValueChanged<MedicalHistoryEntry> onRemove;

  const MedicalHistoryList({
    super.key,
    required this.entries,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(context.locale.toString());
    final tiles = entries
        .map(
          (entry) => Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.fromLTRB(12.w, 4.h, 4.w, 4.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.medical_information_outlined,
                  color: theme.colorScheme.secondary,
                ),
                horizontalSpace(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.condition,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        dateFormat.format(entry.date),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'common.delete'.tr(),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onRemove(entry),
                ),
              ],
            ),
          ),
        )
        .toList();
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text('patients.detail.medical_history.add'.tr()),
        ),
        verticalSpace(12),
        if (entries.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 24.h),
            child: Center(child: Text('common.no_data'.tr())),
          )
        else
          ...tiles.animateList(),
      ],
    );
  }
}
