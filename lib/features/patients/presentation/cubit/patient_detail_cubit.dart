import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/storage/clinic_data_events.dart';
import 'package:my_clinic/features/appointments/repository/appointments_repository.dart';
import 'package:my_clinic/features/patients/domain/entities/medical_history_entry.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';
import 'package:my_clinic/features/prescription/repository/prescriptions_repository.dart';

import 'patient_detail_state.dart';

class PatientDetailCubit extends Cubit<PatientDetailState> {
  final PatientsRepository _repository;
  final PrescriptionsRepository _prescriptionsRepository;
  final AppointmentsRepository _appointmentsRepository;
  late final StreamSubscription<void> _changes;
  String? _patientId;

  PatientDetailCubit(
    this._repository,
    this._prescriptionsRepository,
    this._appointmentsRepository,
    ClinicDataEvents events,
  ) : super(const PatientDetailState()) {
    _changes = events.stream.listen((_) {
      final id = _patientId;
      if (id != null && !state.deleted) fetchPatient(id, silent: true);
    });
  }

  /// Loads the patient plus their prescriptions and appointments. [silent]
  /// skips the loading state so background refreshes don't flash a skeleton.
  Future<void> fetchPatient(String id, {bool silent = false}) async {
    _patientId = id;
    if (!silent) emit(state.copyWith(status: Status.loading));
    final result = await _repository.getPatientById(id);
    final prescriptions = await _prescriptionsRepository.getPrescriptions(
      patientId: id,
    );
    final appointments = await _appointmentsRepository.getAppointments(
      patientId: id,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
        ),
      ),
      (patient) => emit(
        state.copyWith(
          status: Status.success,
          patient: patient,
          prescriptions: prescriptions.getOrElse(() => const []),
          appointments: appointments.getOrElse(() => const []),
        ),
      ),
    );
  }

  Future<void> addHistoryEntry(String condition, DateTime date) async {
    final patient = state.patient;
    if (patient == null || condition.trim().isEmpty) return;
    final entries = [
      ...patient.medicalHistory,
      MedicalHistoryEntry(condition: condition.trim(), date: date),
    ]..sort((a, b) => b.date.compareTo(a.date));
    await _repository.savePatient(patient.copyWith(medicalHistory: entries));
  }

  Future<void> removeHistoryEntry(MedicalHistoryEntry entry) async {
    final patient = state.patient;
    if (patient == null) return;
    await _repository.savePatient(
      patient.copyWith(
        medicalHistory: patient.medicalHistory
            .where((e) => e != entry)
            .toList(),
      ),
    );
  }

  /// Deletes the patient together with their prescriptions and appointments.
  Future<void> deletePatient() async {
    final patient = state.patient;
    if (patient == null) return;
    await _prescriptionsRepository.deleteForPatient(patient.id);
    await _appointmentsRepository.deleteForPatient(patient.id);
    final result = await _repository.deletePatient(patient.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
        ),
      ),
      (_) => emit(state.copyWith(deleted: true)),
    );
  }

  @override
  Future<void> close() {
    _changes.cancel();
    return super.close();
  }
}
