import 'package:equatable/equatable.dart';
import 'package:my_clinic/features/patients/domain/entities/gender.dart';

import 'prescription_drug.dart';
import 'prescription_status.dart';

class Prescription extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final int patientAge;
  final Gender patientGender;
  final DateTime date;
  final String diagnosis;
  final List<PrescriptionDrug> drugs;
  final List<String> notes;
  final PrescriptionStatus status;

  const Prescription({
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

  Prescription copyWith({PrescriptionStatus? status}) {
    return Prescription(
      id: id,
      patientId: patientId,
      patientName: patientName,
      patientAge: patientAge,
      patientGender: patientGender,
      date: date,
      diagnosis: diagnosis,
      drugs: drugs,
      notes: notes,
      status: status ?? this.status,
    );
  }

  bool get isDraft => status == PrescriptionStatus.draft;

  @override
  List<Object?> get props => [
    id,
    patientId,
    patientName,
    patientAge,
    patientGender,
    date,
    diagnosis,
    drugs,
    notes,
    status,
  ];
}
