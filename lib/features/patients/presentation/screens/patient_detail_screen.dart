import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/core/widgets/confirm_dialog.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_detail_cubit.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_detail_state.dart';
import 'package:my_clinic/features/patients/presentation/widgets/add_history_entry_dialog.dart';
import 'package:my_clinic/features/patients/presentation/widgets/current_treatment_list.dart';
import 'package:my_clinic/features/patients/presentation/widgets/medical_history_list.dart';
import 'package:my_clinic/features/patients/presentation/widgets/patient_detail_tab_bar.dart';
import 'package:my_clinic/features/patients/presentation/widgets/patient_header_card.dart';
import 'package:my_clinic/features/patients/presentation/widgets/patient_prescriptions_tab.dart';
import 'package:my_clinic/features/patients/presentation/widgets/patient_visits_tab.dart';
import 'package:my_clinic/features/prescription/presentation/screens/new_prescription_args.dart';

enum _PatientMenuAction { edit, delete }

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
    _tabController = TabController(length: 4, vsync: this);
    context.read<PatientDetailCubit>().fetchPatient(widget.patientId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onMenu(
    _PatientMenuAction action,
    PatientDetailState state,
  ) async {
    final cubit = context.read<PatientDetailCubit>();
    switch (action) {
      case _PatientMenuAction.edit:
        await context.pushNamed(Routes.patientForm, arguments: state.patient);
      case _PatientMenuAction.delete:
        final confirmed = await showConfirmDialog(
          context,
          title: 'patients.delete_confirm.title'.tr(),
          message: 'patients.delete_confirm.message'.tr(
            namedArgs: {'name': state.patient!.name},
          ),
        );
        if (confirmed) await cubit.deletePatient();
    }
  }

  Future<void> _addHistory() async {
    final cubit = context.read<PatientDetailCubit>();
    final input = await showAddHistoryEntryDialog(context);
    if (input != null) await cubit.addHistoryEntry(input.condition, input.date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientDetailCubit, PatientDetailState>(
      listenWhen: (prev, curr) => !prev.deleted && curr.deleted,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('patients.deleted_snackbar'.tr())),
        );
        Navigator.of(context).pop();
      },
      builder: (context, state) {
        final patient = state.patient;
        final cubit = context.read<PatientDetailCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text('patients.detail.title'.tr()),
            actions: [
              if (patient != null)
                PopupMenuButton<_PatientMenuAction>(
                  onSelected: (action) => _onMenu(action, state),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _PatientMenuAction.edit,
                      child: Text('patients.actions.edit'.tr()),
                    ),
                    PopupMenuItem(
                      value: _PatientMenuAction.delete,
                      child: Text('patients.actions.delete'.tr()),
                    ),
                  ],
                ),
            ],
          ),
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
                if (patient == null) {
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
                      child: PatientHeaderCard(
                        patient: patient,
                      ).fadeInSlideUp(),
                    ),
                    PatientDetailTabBar(controller: _tabController),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          MedicalHistoryList(
                            entries: patient.medicalHistory,
                            onAdd: _addHistory,
                            onRemove: cubit.removeHistoryEntry,
                          ),
                          CurrentTreatmentList(
                            treatments: patient.currentTreatments,
                          ),
                          PatientVisitsTab(
                            patient: patient,
                            appointments: state.appointments,
                            nextAppointment: state.nextAppointment,
                          ),
                          PatientPrescriptionsTab(
                            prescriptions: state.prescriptions,
                          ),
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
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(color: Colors.white),
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
