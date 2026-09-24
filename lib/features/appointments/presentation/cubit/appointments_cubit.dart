import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/helpers/date_helpers.dart';
import 'package:my_clinic/core/storage/clinic_data_events.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';
import 'package:my_clinic/features/appointments/repository/appointments_repository.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';

import 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final AppointmentsRepository _repository;
  final PatientsRepository _patientsRepository;
  late final StreamSubscription<void> _changes;

  AppointmentsCubit(
    this._repository,
    this._patientsRepository,
    ClinicDataEvents events,
  ) : super(AppointmentsState(selectedDate: DateTime.now().dateOnly)) {
    _changes = events.stream.listen((_) => load());
  }

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading));
    final result = await _repository.getAppointments();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
        ),
      ),
      (appointments) => emit(
        state.copyWith(status: Status.success, appointments: appointments),
      ),
    );
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date.dateOnly));
  }

  /// Marks the visit as done and moves the patient's last-visit date to it,
  /// so they count toward "today's patients" and float to the top of lists.
  Future<void> markCompleted(Appointment appointment) async {
    await _setStatus(appointment, AppointmentStatus.completed);
    final patientResult = await _patientsRepository.getPatientById(
      appointment.patientId,
    );
    await patientResult.fold((_) async {}, (patient) async {
      if (appointment.dateTime.isAfter(patient.lastVisitAt)) {
        await _patientsRepository.savePatient(
          patient.copyWith(lastVisitAt: appointment.dateTime),
        );
      }
    });
  }

  Future<void> cancel(Appointment appointment) =>
      _setStatus(appointment, AppointmentStatus.cancelled);

  Future<void> reschedule(Appointment appointment) =>
      _setStatus(appointment, AppointmentStatus.scheduled);

  Future<void> delete(Appointment appointment) async {
    final result = await _repository.deleteAppointment(appointment.id);
    _emitIfFailed(result.fold((f) => f.message, (_) => null));
  }

  Future<void> _setStatus(
    Appointment appointment,
    AppointmentStatus status,
  ) async {
    final result = await _repository.saveAppointment(
      appointment.copyWith(status: status),
    );
    _emitIfFailed(result.fold((f) => f.message, (_) => null));
  }

  void _emitIfFailed(String? message) {
    if (message != null && !isClosed) {
      emit(state.copyWith(status: Status.failure, message: message));
    }
  }

  @override
  Future<void> close() {
    _changes.cancel();
    return super.close();
  }
}
