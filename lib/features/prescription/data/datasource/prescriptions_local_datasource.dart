import 'package:my_clinic/features/prescription/data/models/prescription_model.dart';

abstract class PrescriptionsLocalDataSource {
  Future<PrescriptionModel> saveDraft(PrescriptionModel prescription);

  Future<PrescriptionModel> generate(PrescriptionModel prescription);
}
