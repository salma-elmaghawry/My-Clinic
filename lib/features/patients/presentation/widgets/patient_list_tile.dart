import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/animations/animations.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';
import 'package:dr_ahmed/features/patients/domain/entities/gender.dart';
import 'package:dr_ahmed/features/patients/domain/entities/patient.dart';

class PatientListTile extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientListTile({super.key, required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genderLabel = patient.gender == Gender.male
        ? 'patients.gender.male'.tr()
        : 'patients.gender.female'.tr();

    return AnimatedTap(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Text(
                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            horizontalSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.name, style: theme.textTheme.bodyLarge),
                  verticalSpace(2),
                  Text(
                    '${patient.age} · $genderLabel',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.start,
                  ),
                  if (patient.reasonForVisit != null) ...[
                    verticalSpace(2),
                    Text(
                      patient.reasonForVisit!,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
