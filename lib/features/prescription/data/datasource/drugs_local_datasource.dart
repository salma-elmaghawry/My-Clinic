import 'package:dr_ahmed/features/prescription/data/models/drug_model.dart';

abstract class DrugsLocalDataSource {
  Future<List<DrugModel>> getDrugs();

  Future<List<DrugModel>> searchDrugs(String query);
}
