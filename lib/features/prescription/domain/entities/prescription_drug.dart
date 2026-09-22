import 'package:equatable/equatable.dart';

class PrescriptionDrug extends Equatable {
  final String drugId;
  final String drugName;
  final String genericName;
  final String dose;
  final String frequency;
  final String duration;
  final String whenToTake;
  final String? notes;

  const PrescriptionDrug({
    required this.drugId,
    required this.drugName,
    required this.genericName,
    required this.dose,
    required this.frequency,
    required this.duration,
    required this.whenToTake,
    this.notes,
  });

  PrescriptionDrug copyWith({
    String? drugId,
    String? drugName,
    String? genericName,
    String? dose,
    String? frequency,
    String? duration,
    String? whenToTake,
    String? notes,
  }) {
    return PrescriptionDrug(
      drugId: drugId ?? this.drugId,
      drugName: drugName ?? this.drugName,
      genericName: genericName ?? this.genericName,
      dose: dose ?? this.dose,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      whenToTake: whenToTake ?? this.whenToTake,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    drugId,
    drugName,
    genericName,
    dose,
    frequency,
    duration,
    whenToTake,
    notes,
  ];
}
