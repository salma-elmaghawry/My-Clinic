import 'package:dr_ahmed/features/prescription/domain/entities/prescription_drug.dart';

class PrescriptionDrugModel {
  final String drugId;
  final String drugName;
  final String genericName;
  final String dose;
  final String frequency;
  final String duration;
  final String whenToTake;
  final String? notes;

  const PrescriptionDrugModel({
    required this.drugId,
    required this.drugName,
    required this.genericName,
    required this.dose,
    required this.frequency,
    required this.duration,
    required this.whenToTake,
    this.notes,
  });

  factory PrescriptionDrugModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionDrugModel(
      drugId: json['drugId'] as String,
      drugName: json['drugName'] as String,
      genericName: json['genericName'] as String,
      dose: json['dose'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      whenToTake: json['whenToTake'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drugId': drugId,
      'drugName': drugName,
      'genericName': genericName,
      'dose': dose,
      'frequency': frequency,
      'duration': duration,
      'whenToTake': whenToTake,
      'notes': notes,
    };
  }

  factory PrescriptionDrugModel.fromEntity(PrescriptionDrug entity) {
    return PrescriptionDrugModel(
      drugId: entity.drugId,
      drugName: entity.drugName,
      genericName: entity.genericName,
      dose: entity.dose,
      frequency: entity.frequency,
      duration: entity.duration,
      whenToTake: entity.whenToTake,
      notes: entity.notes,
    );
  }

  PrescriptionDrug toEntity() {
    return PrescriptionDrug(
      drugId: drugId,
      drugName: drugName,
      genericName: genericName,
      dose: dose,
      frequency: frequency,
      duration: duration,
      whenToTake: whenToTake,
      notes: notes,
    );
  }
}
