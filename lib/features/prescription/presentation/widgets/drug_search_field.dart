import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug.dart';

class DrugSearchField extends StatelessWidget {
  final List<Drug> results;
  final ValueChanged<String> onChanged;
  final ValueChanged<Drug> onSelect;

  const DrugSearchField({
    super.key,
    required this.results,
    required this.onChanged,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onChanged,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: 'prescription.new.drug_search_hint'.tr(),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
        if (results.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            constraints: BoxConstraints(maxHeight: 220.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: results.length,
              separatorBuilder: (_, _) => Divider(height: 1.h),
              itemBuilder: (context, index) {
                final drug = results[index];
                return ListTile(
                  dense: true,
                  title: Text(drug.name, style: theme.textTheme.bodyMedium),
                  subtitle: Text(
                    '${drug.genericName} · ${drug.commonDose}',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () => onSelect(drug),
                );
              },
            ),
          ).fadeInSlideUp(),
      ],
    );
  }
}
