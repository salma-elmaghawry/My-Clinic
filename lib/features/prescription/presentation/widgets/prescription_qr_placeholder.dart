import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';

/// Static placeholder — no real QR generation this pass (see plan's
/// "Explicitly deferred" section).
class PrescriptionQrPlaceholder extends StatelessWidget {
  const PrescriptionQrPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 96.w,
          height: 96.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Icon(
            Icons.qr_code_2,
            size: 56.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        verticalSpace(6),
        Text(
          'prescription.preview.qr_caption'.tr(),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
