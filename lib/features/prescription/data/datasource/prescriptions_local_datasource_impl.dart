import 'package:my_clinic/core/storage/json_list_store.dart';
import 'package:my_clinic/features/prescription/data/models/prescription_model.dart';

import 'prescriptions_local_datasource.dart';

class PrescriptionsLocalDataSourceImpl implements PrescriptionsLocalDataSource {
  static const String storageKey = 'prescriptions_v1';

  final JsonListStore _store;

  PrescriptionsLocalDataSourceImpl(this._store);

  @override
  Future<PrescriptionModel> save(PrescriptionModel prescription) async {
    await _store.upsert(prescription.toJson());
    return prescription;
  }

  @override
  Future<List<PrescriptionModel>> getPrescriptions({String? patientId}) async {
    final all =
        _store
            .readAll()
            .map(PrescriptionModel.fromJson)
            .where((p) => patientId == null || p.patientId == patientId)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  @override
  Future<void> deletePrescription(String id) async {
    await _store.removeWhere((item) => item['id'] == id);
  }

  @override
  Future<void> deleteForPatient(String patientId) async {
    await _store.removeWhere((item) => item['patientId'] == patientId);
  }
}
