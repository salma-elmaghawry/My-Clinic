import 'package:my_clinic/features/prescription/domain/entities/drug.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug_category.dart';

class DrugModel {
  final String id;
  final String name;
  final String genericName;
  final String commonDose;
  final DrugCategory category;
  final String? defaultFrequency;
  final String? defaultWhenToTake;

  const DrugModel({
    required this.id,
    required this.name,
    required this.genericName,
    required this.commonDose,
    required this.category,
    this.defaultFrequency,
    this.defaultWhenToTake,
  });

  factory DrugModel.fromJson(Map<String, dynamic> json) {
    return DrugModel(
      id: json['id'] as String,
      name: json['name'] as String,
      genericName: json['genericName'] as String,
      commonDose: json['commonDose'] as String,
      category: DrugCategory.values.byName(json['category'] as String),
      defaultFrequency: json['defaultFrequency'] as String?,
      defaultWhenToTake: json['defaultWhenToTake'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'commonDose': commonDose,
      'category': category.name,
      'defaultFrequency': defaultFrequency,
      'defaultWhenToTake': defaultWhenToTake,
    };
  }

  Drug toEntity() {
    return Drug(
      id: id,
      name: name,
      genericName: genericName,
      commonDose: commonDose,
      category: category,
      defaultFrequency: defaultFrequency,
      defaultWhenToTake: defaultWhenToTake,
    );
  }
}
