import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/constants/doctor_profile.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';
import 'package:dr_ahmed/core/utils/app_text_styles.dart';

/// No signature image asset exists, so the doctor's signature is rendered
/// as styled cursive text instead of an image.
class PrescriptionSignatureBlock extends StatelessWidget {
  const PrescriptionSignatureBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            kDoctorProfile.name,
            maxLines: 1,
            style: AppTextStyles.signatureCursive.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        verticalSpace(4),
        SizedBox(
          width: 140.w,
          child: Divider(color: theme.dividerColor),
        ),
        Text(
          kDoctorProfile.titleKey.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
