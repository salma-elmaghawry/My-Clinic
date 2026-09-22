import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';

class PatientDetailState extends BaseState {
  final Patient? patient;
  final Failure? failure;

  const PatientDetailState({
    super.status,
    super.message,
    this.patient,
    this.failure,
  });

  PatientDetailState copyWith({
    Status? status,
    String? message,
    Patient? patient,
    Failure? failure,
  }) {
    return PatientDetailState(
      status: status ?? this.status,
      message: message ?? this.message,
      patient: patient ?? this.patient,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, message, patient, failure];
}
