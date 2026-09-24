import 'package:my_clinic/features/prescription/data/models/prescription_model.dart';

abstract class PrescriptionsLocalDataSource {
  /// Inserts or replaces the prescription with the same id.
  Future<PrescriptionModel> save(PrescriptionModel prescription);

  /// All prescriptions, newest first. Filtered to one patient when
  /// [patientId] is given.
  Future<List<PrescriptionModel>> getPrescriptions({String? patientId});

  Future<void> deletePrescription(String id);

  Future<void> deleteForPatient(String patientId);
}
