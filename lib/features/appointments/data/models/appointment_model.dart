import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime dateTime;
  final String? note;
  final AppointmentStatus status;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.dateTime,
    this.note,
    this.status = AppointmentStatus.scheduled,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      note: json['note'] as String?,
      status: AppointmentStatus.values.byName(json['status'] as String),
    );
  }

  factory AppointmentModel.fromEntity(Appointment entity) {
    return AppointmentModel(
      id: entity.id,
      patientId: entity.patientId,
      patientName: entity.patientName,
      dateTime: entity.dateTime,
      note: entity.note,
      status: entity.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'dateTime': dateTime.toIso8601String(),
      'note': note,
      'status': status.name,
    };
  }

  Appointment toEntity() {
    return Appointment(
      id: id,
      patientId: patientId,
      patientName: patientName,
      dateTime: dateTime,
      note: note,
      status: status,
    );
  }
}
