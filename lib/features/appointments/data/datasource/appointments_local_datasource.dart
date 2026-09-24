import 'package:my_clinic/features/appointments/data/models/appointment_model.dart';

abstract class AppointmentsLocalDataSource {
  /// All appointments sorted by time, optionally limited to one patient.
  Future<List<AppointmentModel>> getAppointments({String? patientId});

  Future<AppointmentModel> saveAppointment(AppointmentModel appointment);

  Future<void> deleteAppointment(String id);

  Future<void> deleteForPatient(String patientId);
}
