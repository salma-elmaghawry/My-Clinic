import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';

class HomeState extends BaseState {
  final int todayPatientsCount;
  final int appointmentsCount;
  final List<Patient> recentPatients;
  final Failure? failure;

  const HomeState({
    super.status,
    super.message,
    this.todayPatientsCount = 0,
    this.appointmentsCount = 0,
    this.recentPatients = const [],
    this.failure,
  });

  HomeState copyWith({
    Status? status,
    String? message,
    int? todayPatientsCount,
    int? appointmentsCount,
    List<Patient>? recentPatients,
    Failure? failure,
  }) {
    return HomeState(
      status: status ?? this.status,
      message: message ?? this.message,
      todayPatientsCount: todayPatientsCount ?? this.todayPatientsCount,
      appointmentsCount: appointmentsCount ?? this.appointmentsCount,
      recentPatients: recentPatients ?? this.recentPatients,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    todayPatientsCount,
    appointmentsCount,
    recentPatients,
    failure,
  ];
}
