import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';

enum PatientsAction { fetch, search }

class PatientsState extends BaseState {
  final List<Patient> patients;
  final String query;
  final Failure? failure;
  final PatientsAction? action;

  const PatientsState({
    super.status,
    super.message,
    this.patients = const [],
    this.query = '',
    this.failure,
    this.action,
  });

  PatientsState copyWith({
    Status? status,
    String? message,
    List<Patient>? patients,
    String? query,
    Failure? failure,
    PatientsAction? action,
  }) {
    return PatientsState(
      status: status ?? this.status,
      message: message ?? this.message,
      patients: patients ?? this.patients,
      query: query ?? this.query,
      failure: failure ?? this.failure,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    patients,
    query,
    failure,
    action,
  ];
}
