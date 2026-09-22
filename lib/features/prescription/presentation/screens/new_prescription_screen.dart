import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/animations/animations.dart';
import 'package:dr_ahmed/core/helpers/extensions.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';
import 'package:dr_ahmed/core/routes/routes.dart';
import 'package:dr_ahmed/features/patients/domain/entities/gender.dart';
import 'package:dr_ahmed/features/patients/domain/entities/patient.dart';
import 'package:dr_ahmed/features/prescription/presentation/cubit/new_prescription_cubit.dart';
import 'package:dr_ahmed/features/prescription/presentation/cubit/new_prescription_state.dart';
import 'package:dr_ahmed/features/prescription/presentation/widgets/add_another_drug_button.dart';
import 'package:dr_ahmed/features/prescription/presentation/widgets/diagnosis_field.dart';
import 'package:dr_ahmed/features/prescription/presentation/widgets/drug_dose_frequency_row.dart';
import 'package:dr_ahmed/features/prescription/presentation/widgets/drug_duration_field.dart';
import 'package:dr_ahmed/features/prescription/presentation/widgets/drug_notes_field.dart';
import 'package:dr_ahmed/features/prescription/presentation/widgets/drug_search_field.dart';
import 'package:dr_ahmed/features/prescription/presentation/widgets/prescription_action_buttons.dart';
import 'package:dr_ahmed/features/prescription/presentation/widgets/selected_drug_chip.dart';
import 'package:dr_ahmed/features/prescription/presentation/widgets/when_to_take_field.dart';

class NewPrescriptionScreen extends StatelessWidget {
  const NewPrescriptionScreen({super.key});

  static final GlobalKey _drugSearchKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewPrescriptionCubit, NewPrescriptionState>(
      listenWhen: (previous, current) =>
          previous.generatedPrescription != current.generatedPrescription ||
          (current.isFailure && previous.message != current.message),
      listener: (context, state) {
        if (state.generatedPrescription != null) {
          context.pushNamed(
            Routes.prescriptionPreview,
            arguments: state.generatedPrescription,
          );
        } else if (state.isFailure && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        } else if (state.isSuccess &&
            state.action == NewPrescriptionAction.saveDraft &&
            state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<NewPrescriptionCubit>();
        return Scaffold(
          appBar: AppBar(title: Text('prescription.new.title'.tr())),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.patient == null)
                    _PatientPicker(state: state, cubit: cubit)
                  else
                    _SelectedPatientCard(state: state, cubit: cubit),
                  verticalSpace(20),
                  DiagnosisField(
                    initialValue: state.diagnosis,
                    onChanged: cubit.setDiagnosis,
                  ),
                  verticalSpace(20),
                  KeyedSubtree(
                    key: _drugSearchKey,
                    child: DrugSearchField(
                      results: state.drugResults,
                      onChanged: cubit.searchDrugs,
                      onSelect: cubit.addDrug,
                    ),
                  ),
                  verticalSpace(16),
                  ...state.selectedDrugs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final drug = entry.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectedDrugChip(
                            drugName: drug.drugName,
                            genericName: drug.genericName,
                            onRemove: () => cubit.removeDrug(index),
                          ),
                          verticalSpace(8),
                          DrugDoseFrequencyRow(
                            dose: drug.dose,
                            frequency: drug.frequency,
                            onDoseChanged: (v) =>
                                cubit.updateDrug(index, dose: v),
                            onFrequencyChanged: (v) =>
                                cubit.updateDrug(index, frequency: v),
                          ),
                          verticalSpace(8),
                          DrugDurationField(
                            duration: drug.duration,
                            onChanged: (v) =>
                                cubit.updateDrug(index, duration: v),
                          ),
                          verticalSpace(8),
                          WhenToTakeField(
                            whenToTake: drug.whenToTake,
                            onChanged: (v) =>
                                cubit.updateDrug(index, whenToTake: v),
                          ),
                          verticalSpace(8),
                          DrugNotesField(
                            notes: drug.notes,
                            onChanged: (v) =>
                                cubit.updateDrug(index, notes: v),
                          ),
                        ],
                      ),
                    ).fadeInSlideUp();
                  }),
                  if (state.selectedDrugs.isNotEmpty) ...[
                    verticalSpace(4),
                    AddAnotherDrugButton(
                      onTap: () {
                        final searchContext = _drugSearchKey.currentContext;
                        if (searchContext != null) {
                          Scrollable.ensureVisible(
                            searchContext,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                  ],
                  verticalSpace(28),
                  PrescriptionActionButtons(
                    isSavingDraft: state.isLoading &&
                        state.action == NewPrescriptionAction.saveDraft,
                    isGenerating: state.isLoading &&
                        state.action == NewPrescriptionAction.generate,
                    onSaveDraft: cubit.saveDraft,
                    onGenerate: cubit.generate,
                  ),
                  verticalSpace(16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PatientPicker extends StatelessWidget {
  final NewPrescriptionState state;
  final NewPrescriptionCubit cubit;

  const _PatientPicker({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: cubit.searchPatients,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: 'prescription.new.select_patient_hint'.tr(),
            prefixIcon: const Icon(Icons.person_search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
        if (state.patientResults.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            constraints: BoxConstraints(maxHeight: 220.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: state.patientResults.length,
              separatorBuilder: (_, _) => Divider(height: 1.h),
              itemBuilder: (context, index) {
                final Patient patient = state.patientResults[index];
                return ListTile(
                  dense: true,
                  title: Text(patient.name, style: theme.textTheme.bodyMedium),
                  subtitle: Text(
                    '${patient.age} · ${patient.gender == Gender.male ? 'patients.gender.male'.tr() : 'patients.gender.female'.tr()}',
                    style: theme.textTheme.bodySmall,
                  ),
                  onTap: () => cubit.selectPatient(patient),
                );
              },
            ),
          ).fadeInSlideUp(),
      ],
    );
  }
}

class _SelectedPatientCard extends StatelessWidget {
  final NewPrescriptionState state;
  final NewPrescriptionCubit cubit;

  const _SelectedPatientCard({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = state.patient!;
    final genderLabel = patient.patientGender == Gender.male
        ? 'patients.gender.male'.tr()
        : 'patients.gender.female'.tr();
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              patient.patientName.isNotEmpty
                  ? patient.patientName[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.patientName, style: theme.textTheme.labelLarge),
                Text(
                  '${patient.patientAge} · $genderLabel',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: cubit.clearPatient,
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }
}
