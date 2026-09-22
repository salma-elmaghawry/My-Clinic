import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/animations/animations.dart';
import 'package:dr_ahmed/core/helpers/extensions.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';
import 'package:dr_ahmed/core/routes/routes.dart';
import 'package:dr_ahmed/features/patients/presentation/cubit/patients_cubit.dart';
import 'package:dr_ahmed/features/patients/presentation/cubit/patients_state.dart';
import 'package:dr_ahmed/features/patients/presentation/widgets/patient_list_tile.dart';
import 'package:dr_ahmed/features/patients/presentation/widgets/patient_search_bar.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PatientsCubit>().fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('patients.list.title'.tr())),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PatientSearchBar(
                onChanged: (query) =>
                    context.read<PatientsCubit>().search(query),
              ),
              verticalSpace(16),
              Expanded(
                child: BlocBuilder<PatientsCubit, PatientsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.patients.isEmpty) {
                      return ListView.builder(
                        itemCount: 5,
                        itemBuilder: (_, _) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: AnimatedSkeleton(
                            width: double.infinity,
                            height: 78.h,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      );
                    }
                    if (state.isFailure) {
                      return Center(
                        child: Text(
                          state.message ?? 'errors.unexpected_error'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    if (state.patients.isEmpty) {
                      return Center(child: Text('common.no_data'.tr()));
                    }
                    final tiles = state.patients
                        .map(
                          (patient) => PatientListTile(
                            patient: patient,
                            onTap: () => context.pushNamed(
                              Routes.patientDetail,
                              arguments: patient.id,
                            ),
                          ),
                        )
                        .toList();
                    return ListView(children: tiles.animateList());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
