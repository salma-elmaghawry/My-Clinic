import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/utils/app_text_styles.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';

/// No signature image asset exists, so the doctor's signature is rendered
/// as styled cursive text instead of an image.
class PrescriptionSignatureBlock extends StatelessWidget {
  const PrescriptionSignatureBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = context.watch<DoctorProfileCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            profileState.displayName,
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
          profileState.displaySpecialty,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
