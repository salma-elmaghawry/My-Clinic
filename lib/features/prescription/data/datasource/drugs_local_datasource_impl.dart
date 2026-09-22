import 'package:dr_ahmed/features/prescription/data/models/drug_model.dart';
import 'package:dr_ahmed/features/prescription/domain/entities/drug_category.dart';

import 'drugs_local_datasource.dart';

class DrugsLocalDataSourceImpl implements DrugsLocalDataSource {
  static final List<DrugModel> _drugs = _seedDrugs();

  @override
  Future<List<DrugModel>> getDrugs() async {
    return List.unmodifiable(_drugs);
  }

  @override
  Future<List<DrugModel>> searchDrugs(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return List.unmodifiable(_drugs);
    return _drugs
        .where((d) =>
            d.name.toLowerCase().contains(normalized) ||
            d.genericName.toLowerCase().contains(normalized))
        .toList();
  }

  static List<DrugModel> _seedDrugs() {
    return const [
      DrugModel(
        id: 'd1',
        name: 'Xarelto',
        genericName: 'Rivaroxaban',
        commonDose: '20mg',
        category: DrugCategory.anticoagulant,
        defaultFrequency: 'Once daily',
        defaultWhenToTake: 'With food',
      ),
      DrugModel(
        id: 'd2',
        name: 'Eliquis',
        genericName: 'Apixaban',
        commonDose: '5mg',
        category: DrugCategory.anticoagulant,
        defaultFrequency: 'Twice daily',
        defaultWhenToTake: 'With or without food',
      ),
      DrugModel(
        id: 'd3',
        name: 'Warfarin',
        genericName: 'Warfarin sodium',
        commonDose: '5mg',
        category: DrugCategory.anticoagulant,
        defaultFrequency: 'Once daily',
        defaultWhenToTake: 'Same time each day',
      ),
      DrugModel(
        id: 'd4',
        name: 'Clexane',
        genericName: 'Enoxaparin',
        commonDose: '40mg',
        category: DrugCategory.anticoagulant,
        defaultFrequency: 'Once daily',
        defaultWhenToTake: 'Subcutaneous injection',
      ),
      DrugModel(
        id: 'd5',
        name: 'Fondaparinux',
        genericName: 'Fondaparinux sodium',
        commonDose: '2.5mg',
        category: DrugCategory.anticoagulant,
        defaultFrequency: 'Once daily',
        defaultWhenToTake: 'Subcutaneous injection',
      ),
      DrugModel(
        id: 'd6',
        name: 'Heparin sodium',
        genericName: 'Heparin',
        commonDose: '5000 IU',
        category: DrugCategory.anticoagulant,
        defaultFrequency: 'Every 8-12 hours',
        defaultWhenToTake: 'Subcutaneous injection',
      ),
      DrugModel(
        id: 'd7',
        name: 'Aspirin',
        genericName: 'Acetylsalicylic acid',
        commonDose: '81mg',
        category: DrugCategory.antiplatelet,
        defaultFrequency: 'Once daily',
        defaultWhenToTake: 'With food',
      ),
      DrugModel(
        id: 'd8',
        name: 'Plavix',
        genericName: 'Clopidogrel',
        commonDose: '75mg',
        category: DrugCategory.antiplatelet,
        defaultFrequency: 'Once daily',
        defaultWhenToTake: 'With or without food',
      ),
      DrugModel(
        id: 'd9',
        name: 'Detralex',
        genericName: 'Diosmin/Hesperidin',
        commonDose: '500mg',
        category: DrugCategory.venotonic,
        defaultFrequency: 'Twice daily',
        defaultWhenToTake: 'With meals',
      ),
      DrugModel(
        id: 'd10',
        name: 'Vessel Due F',
        genericName: 'Sulodexide',
        commonDose: '250 LSU',
        category: DrugCategory.venotonic,
        defaultFrequency: 'Once daily',
        defaultWhenToTake: 'Before meals',
      ),
      DrugModel(
        id: 'd11',
        name: 'Pentoxifylline',
        genericName: 'Pentoxifylline',
        commonDose: '400mg',
        category: DrugCategory.venotonic,
        defaultFrequency: 'Three times daily',
        defaultWhenToTake: 'With meals',
      ),
      DrugModel(
        id: 'd12',
        name: 'Cilostazol',
        genericName: 'Cilostazol',
        commonDose: '100mg',
        category: DrugCategory.venotonic,
        defaultFrequency: 'Twice daily',
        defaultWhenToTake: '30 minutes before meals',
      ),
      DrugModel(
        id: 'd13',
        name: 'Compression Stockings',
        genericName: 'Class II compression',
        commonDose: '20-30 mmHg',
        category: DrugCategory.compressionTherapy,
        defaultFrequency: 'Daily wear',
        defaultWhenToTake: 'Apply in the morning',
      ),
      DrugModel(
        id: 'd14',
        name: 'Elastic Crepe Bandage',
        genericName: 'Compression bandage',
        commonDose: '10cm',
        category: DrugCategory.compressionTherapy,
        defaultFrequency: 'Daily wear',
        defaultWhenToTake: 'Re-wrap daily',
      ),
      DrugModel(
        id: 'd15',
        name: 'Silver Sulfadiazine Cream',
        genericName: 'Silver sulfadiazine',
        commonDose: '1%',
        category: DrugCategory.woundCare,
        defaultFrequency: 'Once daily',
        defaultWhenToTake: 'Apply to clean wound',
      ),
      DrugModel(
        id: 'd16',
        name: 'Voltaren',
        genericName: 'Diclofenac',
        commonDose: '50mg',
        category: DrugCategory.analgesic,
        defaultFrequency: 'Twice daily',
        defaultWhenToTake: 'With food',
      ),
      DrugModel(
        id: 'd17',
        name: 'Augmentin',
        genericName: 'Amoxicillin/Clavulanate',
        commonDose: '1g',
        category: DrugCategory.antibiotic,
        defaultFrequency: 'Twice daily',
        defaultWhenToTake: 'With food',
      ),
    ];
  }
}
