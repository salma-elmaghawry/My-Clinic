import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/core/helpers/date_helpers.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';

class AppointmentsState extends BaseState {
  final DateTime selectedDate;
  final List<Appointment> appointments;
  final Failure? failure;

  const AppointmentsState({
    super.status,
    super.message,
    required this.selectedDate,
    this.appointments = const [],
    this.failure,
  });

  List<Appointment> get dayAppointments =>
      appointments.where((a) => a.dateTime.isSameDay(selectedDate)).toList();

  /// Days that have at least one still-scheduled appointment, used to put a
  /// dot under those days in the date strip.
  Set<DateTime> get busyDays => appointments
      .where((a) => a.isScheduled)
      .map((a) => a.dateTime.dateOnly)
      .toSet();

  AppointmentsState copyWith({
    Status? status,
    String? message,
    DateTime? selectedDate,
    List<Appointment>? appointments,
    Failure? failure,
  }) {
    return AppointmentsState(
      status: status ?? this.status,
      message: message ?? this.message,
      selectedDate: selectedDate ?? this.selectedDate,
      appointments: appointments ?? this.appointments,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    selectedDate,
    appointments,
    failure,
  ];
}
