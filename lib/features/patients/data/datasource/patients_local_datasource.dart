import 'package:my_clinic/features/patients/data/models/patient_model.dart';

/// On-device data source for patients. Throws raw exceptions and never
/// returns an Either; the repository layer is the only try/catch boundary.
/// A future Supabase datasource implements this same interface.
abstract class PatientsLocalDataSource {
  Future<List<PatientModel>> getPatients();

  Future<List<PatientModel>> searchPatients(String query);

  Future<PatientModel> getPatientById(String id);

  Future<List<PatientModel>> getRecentPatients({int limit = 5});

  /// Inserts a new patient or replaces the one with the same id.
  Future<PatientModel> savePatient(PatientModel patient);

  Future<void> deletePatient(String id);
}
