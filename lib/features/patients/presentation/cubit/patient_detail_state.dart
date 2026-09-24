import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';

class PatientDetailState extends BaseState {
  final Patient? patient;
  final List<Prescription> prescriptions;
  final List<Appointment> appointments;
  final Failure? failure;

  /// True once the patient has been deleted, so the screen can close.
  final bool deleted;

  const PatientDetailState({
    super.status,
    super.message,
    this.patient,
    this.prescriptions = const [],
    this.appointments = const [],
    this.failure,
    this.deleted = false,
  });

  /// The earliest still-scheduled appointment from now on, if any.
  Appointment? get nextAppointment {
    final now = DateTime.now();
    for (final appointment in appointments) {
      if (appointment.isScheduled && appointment.dateTime.isAfter(now)) {
        return appointment;
      }
    }
    return null;
  }

  PatientDetailState copyWith({
    Status? status,
    String? message,
    Patient? patient,
    List<Prescription>? prescriptions,
    List<Appointment>? appointments,
    Failure? failure,
    bool? deleted,
  }) {
    return PatientDetailState(
      status: status ?? this.status,
      message: message ?? this.message,
      patient: patient ?? this.patient,
      prescriptions: prescriptions ?? this.prescriptions,
      appointments: appointments ?? this.appointments,
      failure: failure ?? this.failure,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    patient,
    prescriptions,
    appointments,
    failure,
    deleted,
  ];
}
