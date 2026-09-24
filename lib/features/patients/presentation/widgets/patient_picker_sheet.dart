import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/injection/injection_container.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patients_cubit.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patients_state.dart';
import 'package:my_clinic/features/patients/presentation/widgets/patient_search_bar.dart';

/// Bottom sheet that lets the doctor search and pick one patient. Resolves
/// to the chosen [Patient], or null if dismissed.
Future<Patient?> showPatientPickerSheet(BuildContext context) {
  return showModalBottomSheet<Patient>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider<PatientsCubit>(
      create: (_) => getIt<PatientsCubit>()..fetchPatients(),
      child: const _PatientPickerSheet(),
    ),
  );
}

class _PatientPickerSheet extends StatelessWidget {
  const _PatientPickerSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'patients.picker.title'.tr(),
              style: theme.textTheme.displaySmall,
            ),
            verticalSpace(12),
            PatientSearchBar(
              onChanged: (q) => context.read<PatientsCubit>().search(q),
            ),
            verticalSpace(8),
            Expanded(
              child: BlocBuilder<PatientsCubit, PatientsState>(
                builder: (context, state) {
                  if (state.isLoading && state.patients.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.patients.isEmpty) {
                    return Center(
                      child: Text(
                        'patients.picker.empty'.tr(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: state.patients.length,
                    separatorBuilder: (_, _) => Divider(height: 1.h),
                    itemBuilder: (context, index) {
                      final patient = state.patients[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            patient.name.isNotEmpty
                                ? patient.name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(patient.name),
                        subtitle: patient.phone == null
                            ? null
                            : Text(patient.phone!),
                        onTap: () => Navigator.of(context).pop(patient),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
