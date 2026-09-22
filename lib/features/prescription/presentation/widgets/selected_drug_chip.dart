import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';

class SelectedDrugChip extends StatelessWidget {
  final String drugName;
  final String genericName;
  final VoidCallback onRemove;

  const SelectedDrugChip({
    super.key,
    required this.drugName,
    required this.genericName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                drugName,
                style: theme.textTheme.labelLarge,
                textAlign: TextAlign.start,
              ),
              Text(
                genericName,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
        horizontalSpace(8),
        IconButton(
          onPressed: onRemove,
          icon: Icon(Icons.close, size: 20.sp, color: theme.colorScheme.error),
          tooltip: 'common.cancel'.tr(),
        ),
      ],
    );
  }
}
