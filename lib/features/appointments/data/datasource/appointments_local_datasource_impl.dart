import 'package:my_clinic/core/storage/json_list_store.dart';
import 'package:my_clinic/features/appointments/data/models/appointment_model.dart';

import 'appointments_local_datasource.dart';

class AppointmentsLocalDataSourceImpl implements AppointmentsLocalDataSource {
  static const String storageKey = 'appointments_v1';

  final JsonListStore _store;

  AppointmentsLocalDataSourceImpl(this._store);

  @override
  Future<List<AppointmentModel>> getAppointments({String? patientId}) async {
    return _store
        .readAll()
        .map(AppointmentModel.fromJson)
        .where((a) => patientId == null || a.patientId == patientId)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  @override
  Future<AppointmentModel> saveAppointment(AppointmentModel appointment) async {
    await _store.upsert(appointment.toJson());
    return appointment;
  }

  @override
  Future<void> deleteAppointment(String id) async {
    await _store.removeWhere((item) => item['id'] == id);
  }

  @override
  Future<void> deleteForPatient(String patientId) async {
    await _store.removeWhere((item) => item['patientId'] == patientId);
  }
}
