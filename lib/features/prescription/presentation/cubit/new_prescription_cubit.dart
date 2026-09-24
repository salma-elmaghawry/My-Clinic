import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/core/helpers/id_generator.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';
import 'package:my_clinic/features/patients/domain/entities/treatment_item.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug_category.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription_drug.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription_status.dart';
import 'package:my_clinic/features/prescription/presentation/screens/new_prescription_args.dart';
import 'package:my_clinic/features/prescription/repository/drugs_repository.dart';
import 'package:my_clinic/features/prescription/repository/prescriptions_repository.dart';

import 'new_prescription_state.dart';

class NewPrescriptionCubit extends Cubit<NewPrescriptionState> {
  final PatientsRepository _patientsRepository;
  final DrugsRepository _drugsRepository;
  final PrescriptionsRepository _prescriptionsRepository;

  NewPrescriptionCubit(
    this._patientsRepository,
    this._drugsRepository,
    this._prescriptionsRepository,
  ) : super(const NewPrescriptionState());

  /// One id for the whole editing session, so "Save Draft" then "Generate"
  /// updates a single record instead of creating two.
  String _prescriptionId = generateId();

  void init(NewPrescriptionArgs? args) {
    if (args == null) return;
    final draft = args.draft;
    if (draft != null) {
      _prescriptionId = draft.id;
      emit(
        state.copyWith(
          patient: args,
          diagnosis: draft.diagnosis,
          selectedDrugs: draft.drugs,
        ),
      );
    } else {
      emit(state.copyWith(patient: args));
    }
  }

  Future<void> searchPatients(String query) async {
    emit(
      state.copyWith(
        patientQuery: query,
        status: Status.loading,
        action: NewPrescriptionAction.searchPatients,
      ),
    );
    final result = await _patientsRepository.searchPatients(query);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: NewPrescriptionAction.searchPatients,
        ),
      ),
      (patients) => emit(
        state.copyWith(
          status: Status.success,
          patientResults: patients,
          action: NewPrescriptionAction.searchPatients,
        ),
      ),
    );
  }

  void selectPatient(Patient patient) {
    emit(
      state.copyWith(
        patient: NewPrescriptionArgs(
          patientId: patient.id,
          patientName: patient.name,
          patientAge: patient.age,
          patientGender: patient.gender,
        ),
        patientResults: const [],
        patientQuery: '',
      ),
    );
  }

  void clearPatient() {
    emit(state.copyWith(clearPatient: true));
  }

  Future<void> searchDrugs(String query) async {
    emit(
      state.copyWith(
        drugQuery: query,
        status: Status.loading,
        action: NewPrescriptionAction.searchDrugs,
      ),
    );
    final result = await _drugsRepository.searchDrugs(query);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: NewPrescriptionAction.searchDrugs,
        ),
      ),
      (drugs) => emit(
        state.copyWith(
          status: Status.success,
          drugResults: drugs,
          action: NewPrescriptionAction.searchDrugs,
        ),
      ),
    );
  }

  void addDrug(Drug drug) {
    final newDrug = PrescriptionDrug(
      drugId: drug.id,
      drugName: drug.name,
      genericName: drug.genericName,
      dose: drug.commonDose,
      frequency: drug.defaultFrequency ?? '',
      duration: '',
      whenToTake: drug.defaultWhenToTake ?? '',
    );
    emit(
      state.copyWith(
        selectedDrugs: [...state.selectedDrugs, newDrug],
        drugResults: const [],
        drugQuery: '',
      ),
    );
  }

  /// Adds a drug that isn't in the list yet: saves it to the doctor's own
  /// drug list (so it shows up in future searches) and adds it to this
  /// prescription.
  Future<void> addCustomDrug(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final drug = Drug(
      id: generateId(),
      name: trimmed,
      genericName: '',
      commonDose: '',
      category: DrugCategory.other,
      isCustom: true,
    );
    await _drugsRepository.addCustomDrug(drug);
    addDrug(drug);
  }

  void removeDrug(int index) {
    final updated = List<PrescriptionDrug>.from(state.selectedDrugs)
      ..removeAt(index);
    emit(state.copyWith(selectedDrugs: updated));
  }

  void updateDrug(
    int index, {
    String? dose,
    String? frequency,
    String? duration,
    String? whenToTake,
    String? notes,
  }) {
    final updated = List<PrescriptionDrug>.from(state.selectedDrugs);
    updated[index] = updated[index].copyWith(
      dose: dose,
      frequency: frequency,
      duration: duration,
      whenToTake: whenToTake,
      notes: notes,
    );
    emit(state.copyWith(selectedDrugs: updated));
  }

  void setDiagnosis(String value) {
    emit(state.copyWith(diagnosis: value));
  }

  Future<void> saveDraft() async {
    final prescription = _buildPrescription(PrescriptionStatus.draft);
    if (prescription == null) return;

    emit(
      state.copyWith(
        status: Status.loading,
        action: NewPrescriptionAction.saveDraft,
      ),
    );
    final result = await _prescriptionsRepository.saveDraft(prescription);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: NewPrescriptionAction.saveDraft,
        ),
      ),
      (saved) => emit(
        state.copyWith(
          status: Status.success,
          message: 'prescription.new.draft_saved'.tr(),
          action: NewPrescriptionAction.saveDraft,
        ),
      ),
    );
  }

  Future<void> generate() async {
    final prescription = _buildPrescription(PrescriptionStatus.generated);
    if (prescription == null) return;

    emit(
      state.copyWith(
        status: Status.loading,
        action: NewPrescriptionAction.generate,
      ),
    );
    final result = await _prescriptionsRepository.generate(prescription);
    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: NewPrescriptionAction.generate,
        ),
      );
      return;
    }
    final generated = result.getOrElse(() => prescription);
    await _updatePatientTreatment(generated);
    emit(
      state.copyWith(
        status: Status.success,
        generatedPrescription: generated,
        action: NewPrescriptionAction.generate,
      ),
    );
  }

  /// A generated prescription becomes the patient's current treatment and
  /// counts as a visit today.
  Future<void> _updatePatientTreatment(Prescription prescription) async {
    final result = await _patientsRepository.getPatientById(
      prescription.patientId,
    );
    await result.fold((_) async {}, (patient) async {
      await _patientsRepository.savePatient(
        patient.copyWith(
          lastVisitAt: prescription.date,
          currentTreatments: prescription.drugs
              .map(
                (d) => TreatmentItem(
                  drugName: [
                    d.drugName,
                    d.dose,
                  ].where((s) => s.trim().isNotEmpty).join(' '),
                  frequency: d.frequency,
                  notes: d.notes,
                ),
              )
              .toList(),
        ),
      );
    });
  }

  /// Client-side validation for the two required-but-not-repository-backed
  /// conditions (patient selected, at least one drug added). Emits a
  /// localized failure state directly and returns null when invalid.
  Prescription? _buildPrescription(PrescriptionStatus status) {
    final patient = state.patient;
    if (patient == null) {
      emit(
        state.copyWith(
          status: Status.failure,
          message: 'prescription.new.errors.missing_patient'.tr(),
          failure: UnexpectedFailure(
            message: 'prescription.new.errors.missing_patient'.tr(),
          ),
        ),
      );
      return null;
    }
    if (state.selectedDrugs.isEmpty) {
      emit(
        state.copyWith(
          status: Status.failure,
          message: 'prescription.new.errors.missing_drugs'.tr(),
          failure: UnexpectedFailure(
            message: 'prescription.new.errors.missing_drugs'.tr(),
          ),
        ),
      );
      return null;
    }
    if (state.diagnosis.trim().isEmpty) {
      emit(
        state.copyWith(
          status: Status.failure,
          message: 'prescription.new.errors.missing_diagnosis'.tr(),
          failure: UnexpectedFailure(
            message: 'prescription.new.errors.missing_diagnosis'.tr(),
          ),
        ),
      );
      return null;
    }

    final noteEntries = state.selectedDrugs
        .where((d) => d.notes != null && d.notes!.trim().isNotEmpty)
        .map((d) => '${d.drugName}: ${d.notes}')
        .toList();

    return Prescription(
      id: _prescriptionId,
      patientId: patient.patientId,
      patientName: patient.patientName,
      patientAge: patient.patientAge,
      patientGender: patient.patientGender,
      date: DateTime.now(),
      diagnosis: state.diagnosis.trim(),
      drugs: state.selectedDrugs,
      notes: noteEntries,
      status: status,
    );
  }
}
