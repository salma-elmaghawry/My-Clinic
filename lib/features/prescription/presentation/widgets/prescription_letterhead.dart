import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';

class PrescriptionLetterhead extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionLetterhead({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(context.locale.toString());
    final genderLabel = prescription.patientGender == Gender.male
        ? 'patients.gender.male'.tr()
        : 'patients.gender.female'.tr();
    final profileState = context.watch<DoctorProfileCubit>().state;
    final clinicLine = profileState.profile.clinicName.isNotEmpty
        ? '${profileState.displayName} · ${profileState.profile.clinicName}'
        : profileState.displayName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.asset(
                profileState.profile.logoAssetPath,
                width: 48.w,
                height: 48.w,
                fit: BoxFit.cover,
              ),
            ),
            horizontalSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clinicLine, style: theme.textTheme.displaySmall),
                  Text(
                    profileState.displaySpecialty,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        verticalSpace(16),
        Divider(color: theme.dividerColor),
        verticalSpace(12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prescription.patientName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  verticalSpace(4),
                  Text(
                    '${prescription.patientAge} · $genderLabel',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              dateFormat.format(prescription.date),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
