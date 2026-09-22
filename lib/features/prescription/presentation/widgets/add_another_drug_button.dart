import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dr_ahmed/core/animations/animations.dart';

class AddAnotherDrugButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddAnotherDrugButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedTap(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            'prescription.new.add_another_drug'.tr(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
