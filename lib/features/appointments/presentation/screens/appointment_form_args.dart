import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';

/// Route arguments for the appointment form. Pass [appointment] to edit an
/// existing one, or a patient and/or date to pre-fill a new one.
class AppointmentFormArgs {
  final Appointment? appointment;
  final String? patientId;
  final String? patientName;
  final DateTime? initialDate;

  const AppointmentFormArgs({
    this.appointment,
    this.patientId,
    this.patientName,
    this.initialDate,
  });
}
