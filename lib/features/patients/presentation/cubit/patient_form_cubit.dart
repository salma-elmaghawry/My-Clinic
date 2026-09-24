import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/helpers/id_generator.dart';
import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';

class PatientFormState extends BaseState {
  final Patient? savedPatient;

  const PatientFormState({super.status, super.message, this.savedPatient});

  @override
  List<Object?> get props => [status, message, savedPatient];
}

class PatientFormCubit extends Cubit<PatientFormState> {
  final PatientsRepository _repository;

  PatientFormCubit(this._repository) : super(const PatientFormState());

  /// Creates a new patient, or updates [existing] keeping its history,
  /// treatments and dates.
  Future<void> save({
    Patient? existing,
    required String name,
    required int age,
    required Gender gender,
    required String phone,
    required String reasonForVisit,
  }) async {
    emit(const PatientFormState(status: Status.loading));
    final now = DateTime.now();
    final cleanPhone = phone.trim().isEmpty ? null : phone.trim();
    final cleanReason = reasonForVisit.trim().isEmpty
        ? null
        : reasonForVisit.trim();
    final patient = existing == null
        ? Patient(
            id: generateId(),
            name: name.trim(),
            age: age,
            gender: gender,
            phone: cleanPhone,
            reasonForVisit: cleanReason,
            lastVisitAt: now,
            createdAt: now,
          )
        : Patient(
            id: existing.id,
            name: name.trim(),
            age: age,
            gender: gender,
            photoUrl: existing.photoUrl,
            phone: cleanPhone,
            reasonForVisit: cleanReason,
            lastVisitAt: existing.lastVisitAt,
            medicalHistory: existing.medicalHistory,
            currentTreatments: existing.currentTreatments,
            nextVisit: existing.nextVisit,
            createdAt: existing.createdAt,
          );
    final result = await _repository.savePatient(patient);
    result.fold(
      (failure) => emit(
        PatientFormState(status: Status.failure, message: failure.message),
      ),
      (saved) =>
          emit(PatientFormState(status: Status.success, savedPatient: saved)),
    );
  }
}
