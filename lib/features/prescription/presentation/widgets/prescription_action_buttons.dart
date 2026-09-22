import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/animations/animations.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';

class PrescriptionActionButtons extends StatelessWidget {
  final bool isSavingDraft;
  final bool isGenerating;
  final VoidCallback onSaveDraft;
  final VoidCallback onGenerate;

  const PrescriptionActionButtons({
    super.key,
    required this.isSavingDraft,
    required this.isGenerating,
    required this.onSaveDraft,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: AnimatedButton(
            isLoading: isSavingDraft,
            backgroundColor: theme.colorScheme.surface,
            onPressed: onSaveDraft,
            height: 52.h,
            borderRadius: BorderRadius.circular(14.r),
            loadingColor: theme.colorScheme.primary,
            child: Text(
              'prescription.new.save_draft'.tr(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: AnimatedButton(
            isLoading: isGenerating,
            backgroundColor: theme.colorScheme.primary,
            onPressed: onGenerate,
            height: 52.h,
            borderRadius: BorderRadius.circular(14.r),
            child: Text(
              'prescription.new.generate'.tr(),
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
