import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/animations/animations.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';
import 'package:dr_ahmed/features/patients/domain/entities/medical_history_entry.dart';

class MedicalHistoryList extends StatelessWidget {
  final List<MedicalHistoryEntry> entries;

  const MedicalHistoryList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) {
      return Center(child: Text('common.no_data'.tr()));
    }
    final dateFormat = DateFormat.yMMMd(context.locale.toString());
    final tiles = entries
        .map(
          (entry) => Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.medical_information_outlined,
                    color: theme.colorScheme.secondary),
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
