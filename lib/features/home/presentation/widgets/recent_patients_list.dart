import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';

import 'recent_patient_tile.dart';

class RecentPatientsList extends StatelessWidget {
  final List<Patient> patients;

  const RecentPatientsList({super.key, required this.patients});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (patients.isEmpty) {
      return Text('common.no_data'.tr(), style: theme.textTheme.bodySmall);
    }
    return SizedBox(
      height: 118.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return RecentPatientTile(
            patient: patient,
            onTap: () => context.pushNamed(
              Routes.patientDetail,
              arguments: patient.id,
            ),
          );
        },
      ),
    );
  }
}
