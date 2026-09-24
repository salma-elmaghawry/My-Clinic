import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';

import 'medical_history_entry_model.dart';
import 'next_visit_model.dart';
import 'treatment_item_model.dart';

class PatientModel {
  final String id;
  final String name;
  final int age;
  final Gender gender;
  final String? photoUrl;
  final String? phone;
  final String? reasonForVisit;
  final DateTime lastVisitAt;
  final List<MedicalHistoryEntryModel> medicalHistory;
  final List<TreatmentItemModel> currentTreatments;
  final NextVisitModel? nextVisit;
  final DateTime createdAt;

  const PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.photoUrl,
    this.phone,
    this.reasonForVisit,
    required this.lastVisitAt,
    this.medicalHistory = const [],
    this.currentTreatments = const [],
    this.nextVisit,
    required this.createdAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: Gender.values.byName(json['gender'] as String),
      photoUrl: json['photoUrl'] as String?,
      phone: json['phone'] as String?,
      reasonForVisit: json['reasonForVisit'] as String?,
      lastVisitAt: DateTime.parse(json['lastVisitAt'] as String),
      medicalHistory: (json['medicalHistory'] as List<dynamic>? ?? [])
          .map(
            (e) => MedicalHistoryEntryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      currentTreatments: (json['currentTreatments'] as List<dynamic>? ?? [])
          .map((e) => TreatmentItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextVisit: json['nextVisit'] != null
          ? NextVisitModel.fromJson(json['nextVisit'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory PatientModel.fromEntity(Patient entity) {
    return PatientModel(
      id: entity.id,
      name: entity.name,
      age: entity.age,
      gender: entity.gender,
      photoUrl: entity.photoUrl,
      phone: entity.phone,
      reasonForVisit: entity.reasonForVisit,
      lastVisitAt: entity.lastVisitAt,
      medicalHistory: entity.medicalHistory
          .map(
            (e) =>
                MedicalHistoryEntryModel(condition: e.condition, date: e.date),
          )
          .toList(),
      currentTreatments: entity.currentTreatments
          .map(
            (e) => TreatmentItemModel(
              drugName: e.drugName,
              frequency: e.frequency,
              notes: e.notes,
            ),
          )
          .toList(),
      nextVisit: entity.nextVisit == null
          ? null
          : NextVisitModel(
              dateTime: entity.nextVisit!.dateTime,
              reminderSet: entity.nextVisit!.reminderSet,
            ),
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender.name,
      'photoUrl': photoUrl,
      'phone': phone,
      'reasonForVisit': reasonForVisit,
      'lastVisitAt': lastVisitAt.toIso8601String(),
      'medicalHistory': medicalHistory.map((e) => e.toJson()).toList(),
      'currentTreatments': currentTreatments.map((e) => e.toJson()).toList(),
      'nextVisit': nextVisit?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Patient toEntity() {
    return Patient(
      id: id,
      name: name,
      age: age,
      gender: gender,
      photoUrl: photoUrl,
      phone: phone,
      reasonForVisit: reasonForVisit,
      lastVisitAt: lastVisitAt,
      medicalHistory: medicalHistory.map((e) => e.toEntity()).toList(),
      currentTreatments: currentTreatments.map((e) => e.toEntity()).toList(),
      nextVisit: nextVisit?.toEntity(),
      createdAt: createdAt,
    );
  }
}
