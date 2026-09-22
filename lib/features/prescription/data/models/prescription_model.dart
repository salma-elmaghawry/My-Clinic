import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription_status.dart';

import 'prescription_drug_model.dart';

class PrescriptionModel {
  final String id;
  final String patientId;
  final String patientName;
  final int patientAge;
  final Gender patientGender;
  final DateTime date;
  final String diagnosis;
  final List<PrescriptionDrugModel> drugs;
  final List<String> notes;
  final PrescriptionStatus status;

  const PrescriptionModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.date,
    required this.diagnosis,
    this.drugs = const [],
    this.notes = const [],
    required this.status,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientAge: json['patientAge'] as int,
      patientGender: Gender.values.byName(json['patientGender'] as String),
      date: DateTime.parse(json['date'] as String),
      diagnosis: json['diagnosis'] as String,
      drugs: (json['drugs'] as List<dynamic>? ?? [])
          .map((e) => PrescriptionDrugModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List<dynamic>? ?? []).cast<String>(),
      status: PrescriptionStatus.values.byName(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientGender': patientGender.name,
      'date': date.toIso8601String(),
      'diagnosis': diagnosis,
      'drugs': drugs.map((e) => e.toJson()).toList(),
      'notes': notes,
      'status': status.name,
    };
  }

  factory PrescriptionModel.fromEntity(Prescription entity) {
    return PrescriptionModel(
      id: entity.id,
      patientId: entity.patientId,
      patientName: entity.patientName,
      patientAge: entity.patientAge,
      patientGender: entity.patientGender,
      date: entity.date,
      diagnosis: entity.diagnosis,
      drugs: entity.drugs.map(PrescriptionDrugModel.fromEntity).toList(),
      notes: entity.notes,
      status: entity.status,
    );
  }

  Prescription toEntity() {
    return Prescription(
      id: id,
      patientId: patientId,
      patientName: patientName,
      patientAge: patientAge,
      patientGender: patientGender,
      date: date,
      diagnosis: diagnosis,
      drugs: drugs.map((e) => e.toEntity()).toList(),
      notes: notes,
      status: status,
    );
  }
}
