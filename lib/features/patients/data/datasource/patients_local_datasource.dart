import 'package:dr_ahmed/features/patients/data/models/patient_model.dart';

/// Local (in-memory) data source for patients. Throws raw exceptions —
/// never returns an Either; the repository layer is the only try/catch
/// boundary. Swapping this for a real backend later only touches this file.
abstract class PatientsLocalDataSource {
  Future<List<PatientModel>> getPatients();

  Future<List<PatientModel>> searchPatients(String query);

  Future<PatientModel> getPatientById(String id);

  Future<List<PatientModel>> getRecentPatients({int limit = 5});
}
