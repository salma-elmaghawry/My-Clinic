import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';
import 'package:dr_ahmed/features/patients/domain/entities/gender.dart';
import 'package:dr_ahmed/features/patients/domain/entities/patient.dart';

class PatientHeaderCard extends StatelessWidget {
  final Patient patient;

  const PatientHeaderCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genderLabel = patient.gender == Gender.male
        ? 'patients.gender.male'.tr()
        : 'patients.gender.female'.tr();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
              style: theme.textTheme.displaySmall?.copyWith(color: Colors.white),
            ),
          ),
          horizontalSpace(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name, style: theme.textTheme.displaySmall),
                verticalSpace(4),
                Text(
                  '${patient.age} · $genderLabel',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.start,
                ),
                if (patient.phone != null) ...[
                  verticalSpace(2),
                  Text(
                    patient.phone!,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.start,
                  ),
                ],
                if (patient.reasonForVisit != null) ...[
                  verticalSpace(6),
                  Text(
                    patient.reasonForVisit!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
