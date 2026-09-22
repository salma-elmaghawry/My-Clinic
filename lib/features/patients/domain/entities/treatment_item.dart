import 'package:equatable/equatable.dart';

class TreatmentItem extends Equatable {
  final String drugName;
  final String frequency;
  final String? notes;

  const TreatmentItem({
    required this.drugName,
    required this.frequency,
    this.notes,
  });

  @override
  List<Object?> get props => [drugName, frequency, notes];
}
