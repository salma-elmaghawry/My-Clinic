import 'package:equatable/equatable.dart';

import 'drug_category.dart';

class Drug extends Equatable {
  final String id;
  final String name;
  final String genericName;
  final String commonDose;
  final DrugCategory category;
  final String? defaultFrequency;
  final String? defaultWhenToTake;

  const Drug({
    required this.id,
    required this.name,
    required this.genericName,
    required this.commonDose,
    required this.category,
    this.defaultFrequency,
    this.defaultWhenToTake,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    genericName,
    commonDose,
    category,
    defaultFrequency,
    defaultWhenToTake,
  ];
}
