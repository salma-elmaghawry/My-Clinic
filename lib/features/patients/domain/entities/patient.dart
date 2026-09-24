import 'package:equatable/equatable.dart';

import 'gender.dart';
import 'medical_history_entry.dart';
import 'next_visit.dart';
import 'treatment_item.dart';

class Patient extends Equatable {
  final String id;
  final String name;
  final int age;
  final Gender gender;
  final String? photoUrl;
  final String? phone;
  final String? reasonForVisit;
  final DateTime lastVisitAt;
  final List<MedicalHistoryEntry> medicalHistory;
  final List<TreatmentItem> currentTreatments;
  final NextVisit? nextVisit;
  final DateTime createdAt;

  const Patient({
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

  Patient copyWith({
    String? name,
    int? age,
    Gender? gender,
    String? phone,
    String? reasonForVisit,
    DateTime? lastVisitAt,
    List<MedicalHistoryEntry>? medicalHistory,
    List<TreatmentItem>? currentTreatments,
  }) {
    return Patient(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      photoUrl: photoUrl,
      phone: phone ?? this.phone,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      currentTreatments: currentTreatments ?? this.currentTreatments,
      nextVisit: nextVisit,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    age,
    gender,
    photoUrl,
    phone,
    reasonForVisit,
    lastVisitAt,
    medicalHistory,
    currentTreatments,
    nextVisit,
    createdAt,
  ];
}
