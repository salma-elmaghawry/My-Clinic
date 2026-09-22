import 'package:dr_ahmed/features/patients/domain/entities/medical_history_entry.dart';

class MedicalHistoryEntryModel {
  final String condition;
  final DateTime date;

  const MedicalHistoryEntryModel({required this.condition, required this.date});

  factory MedicalHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryEntryModel(
      condition: json['condition'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'condition': condition, 'date': date.toIso8601String()};
  }

  MedicalHistoryEntry toEntity() {
    return MedicalHistoryEntry(condition: condition, date: date);
  }
}
