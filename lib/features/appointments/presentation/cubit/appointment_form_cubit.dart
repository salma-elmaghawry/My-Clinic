import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/helpers/id_generator.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';
import 'package:my_clinic/features/appointments/repository/appointments_repository.dart';

class AppointmentFormState extends BaseState {
  const AppointmentFormState({super.status, super.message});
}

class AppointmentFormCubit extends Cubit<AppointmentFormState> {
  final AppointmentsRepository _repository;

  AppointmentFormCubit(this._repository) : super(const AppointmentFormState());

  /// Creates a new appointment, or updates [existing] when editing.
  Future<void> save({
    Appointment? existing,
    required String? patientId,
    required String? patientName,
    required DateTime dateTime,
    required String note,
  }) async {
    if (patientId == null || patientName == null) {
      emit(
        AppointmentFormState(
          status: Status.failure,
          message: 'appointments.form.errors.missing_patient'.tr(),
        ),
      );
      return;
    }
    emit(const AppointmentFormState(status: Status.loading));
    final trimmedNote = note.trim();
    final appointment = Appointment(
      id: existing?.id ?? generateId(),
      patientId: patientId,
      patientName: patientName,
      dateTime: dateTime,
      note: trimmedNote.isEmpty ? null : trimmedNote,
      status: existing?.status ?? AppointmentStatus.scheduled,
    );
    final result = await _repository.saveAppointment(appointment);
    result.fold(
      (failure) => emit(
        AppointmentFormState(status: Status.failure, message: failure.message),
      ),
      (_) => emit(const AppointmentFormState(status: Status.success)),
    );
  }
}
