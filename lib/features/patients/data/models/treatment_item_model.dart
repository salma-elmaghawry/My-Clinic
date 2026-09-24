import 'package:my_clinic/features/patients/domain/entities/treatment_item.dart';

class TreatmentItemModel {
  final String drugName;
  final String frequency;
  final String? notes;

  const TreatmentItemModel({
    required this.drugName,
    required this.frequency,
    this.notes,
  });

  factory TreatmentItemModel.fromJson(Map<String, dynamic> json) {
    return TreatmentItemModel(
      drugName: json['drugName'] as String,
      frequency: json['frequency'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'drugName': drugName, 'frequency': frequency, 'notes': notes};
  }

  TreatmentItem toEntity() {
    return TreatmentItem(
      drugName: drugName,
      frequency: frequency,
      notes: notes,
    );
  }
}
