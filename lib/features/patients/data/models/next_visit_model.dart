import 'package:my_clinic/features/patients/domain/entities/next_visit.dart';

class NextVisitModel {
  final DateTime dateTime;
  final bool reminderSet;

  const NextVisitModel({required this.dateTime, required this.reminderSet});

  factory NextVisitModel.fromJson(Map<String, dynamic> json) {
    return NextVisitModel(
      dateTime: DateTime.parse(json['dateTime'] as String),
      reminderSet: json['reminderSet'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'dateTime': dateTime.toIso8601String(), 'reminderSet': reminderSet};
  }

  NextVisit toEntity() {
    return NextVisit(dateTime: dateTime, reminderSet: reminderSet);
  }
}
