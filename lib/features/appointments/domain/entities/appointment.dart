import 'package:equatable/equatable.dart';

enum AppointmentStatus { scheduled, completed, cancelled }

class Appointment extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime dateTime;
  final String? note;
  final AppointmentStatus status;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.dateTime,
    this.note,
    this.status = AppointmentStatus.scheduled,
  });

  bool get isScheduled => status == AppointmentStatus.scheduled;

  Appointment copyWith({
    String? patientId,
    String? patientName,
    DateTime? dateTime,
    String? note,
    AppointmentStatus? status,
  }) {
    return Appointment(
      id: id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    patientId,
    patientName,
    dateTime,
    note,
    status,
  ];
}
