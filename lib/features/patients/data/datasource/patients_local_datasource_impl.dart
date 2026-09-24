import 'package:my_clinic/core/error_handling/exceptions.dart';
import 'package:my_clinic/core/storage/json_list_store.dart';
import 'package:my_clinic/features/patients/data/models/patient_model.dart';

import 'patients_local_datasource.dart';

/// Stores patients on the device so records survive app restarts and work
/// with no internet in the clinic.
class PatientsLocalDataSourceImpl implements PatientsLocalDataSource {
  static const String storageKey = 'patients_v1';

  final JsonListStore _store;

  PatientsLocalDataSourceImpl(this._store);

  List<PatientModel> _all() {
    final patients = _store.readAll().map(PatientModel.fromJson).toList()
      ..sort((a, b) => b.lastVisitAt.compareTo(a.lastVisitAt));
    return patients;
  }

  @override
  Future<List<PatientModel>> getPatients() async => _all();

  @override
  Future<List<PatientModel>> searchPatients(String query) async {
    final normalized = query.trim().toLowerCase();
    final patients = _all();
    if (normalized.isEmpty) return patients;
    final digits = normalized.replaceAll(RegExp(r'\D'), '');
    return patients.where((p) {
      if (p.name.toLowerCase().contains(normalized)) return true;
      final phone = p.phone?.replaceAll(RegExp(r'\D'), '') ?? '';
      return digits.isNotEmpty && phone.contains(digits);
    }).toList();
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    for (final patient in _all()) {
      if (patient.id == id) return patient;
    }
    throw const PatientNotFoundException();
  }

  @override
  Future<List<PatientModel>> getRecentPatients({int limit = 5}) async {
    return _all().take(limit).toList();
  }

  @override
  Future<PatientModel> savePatient(PatientModel patient) async {
    await _store.upsert(patient.toJson());
    return patient;
  }

  @override
  Future<void> deletePatient(String id) async {
    await _store.removeWhere((item) => item['id'] == id);
  }
}
