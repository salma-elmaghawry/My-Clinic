import 'package:equatable/equatable.dart';

class MedicalHistoryEntry extends Equatable {
  final String condition;
  final DateTime date;

  const MedicalHistoryEntry({required this.condition, required this.date});

  @override
  List<Object?> get props => [condition, date];
}
