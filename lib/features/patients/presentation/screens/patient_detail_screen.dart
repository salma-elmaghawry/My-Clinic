import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_detail_cubit.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_detail_state.dart';
import 'package:my_clinic/features/patients/presentation/widgets/current_treatment_list.dart';
import 'package:my_clinic/features/patients/presentation/widgets/medical_history_list.dart';
import 'package:my_clinic/features/patients/presentation/widgets/next_visit_card.dart';
import 'package:my_clinic/features/patients/presentation/widgets/patient_detail_tab_bar.dart';
import 'package:my_clinic/features/patients/presentation/widgets/patient_header_card.dart';
import 'package:my_clinic/features/prescription/presentation/screens/new_prescription_args.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<PatientDetailCubit>().fetchPatient(widget.patientId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailCubit, PatientDetailState>(
      builder: (context, state) {
        final patient = state.patient;
        return Scaffold(
          appBar: AppBar(title: Text('patients.list.title'.tr())),
          body: SafeArea(
            child: Builder(
              builder: (context) {
                if (state.isLoading && patient == null) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: AnimatedSkeleton(
                      width: double.infinity,
                      height: 120.h,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  );
                }
                if (state.isFailure || patient == null) {
                  return Center(
                    child: Text(
                      state.message ?? 'errors.unexpected_error'.tr(),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: PatientHeaderCard(patient: patient)
                          .fadeInSlideUp(),
                    ),
                    PatientDetailTabBar(controller: _tabController),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          MedicalHistoryList(entries: patient.medicalHistory),
                          CurrentTreatmentList(
                            treatments: patient.currentTreatments,
                          ),
                          NextVisitCard(nextVisit: patient.nextVisit),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: AnimatedButton(
                        height: 52.h,
                        borderRadius: BorderRadius.circular(14.r),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        onPressed: () => context.pushNamed(
                          Routes.newPrescription,
                          arguments: NewPrescriptionArgs(
                            patientId: patient.id,
                            patientName: patient.name,
                            patientAge: patient.age,
                            patientGender: patient.gender,
                          ),
                        ),
                        child: Text(
                          'patients.detail.new_prescription_button'.tr(),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
