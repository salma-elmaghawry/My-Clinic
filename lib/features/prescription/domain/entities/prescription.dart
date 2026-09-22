import 'package:equatable/equatable.dart';
import 'package:dr_ahmed/features/patients/domain/entities/gender.dart';

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
