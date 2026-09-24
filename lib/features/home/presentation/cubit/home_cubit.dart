import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/helpers/date_helpers.dart';
import 'package:my_clinic/core/storage/clinic_data_events.dart';
import 'package:my_clinic/features/appointments/repository/appointments_repository.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final PatientsRepository _patientsRepository;
  final AppointmentsRepository _appointmentsRepository;
  late final StreamSubscription<void> _changes;

  HomeCubit(
    this._patientsRepository,
    this._appointmentsRepository,
    ClinicDataEvents events,
  ) : super(const HomeState()) {
    _changes = events.stream.listen((_) => loadHome());
  }

  Future<void> loadHome() async {
    emit(state.copyWith(status: Status.loading));
    final allResult = await _patientsRepository.getPatients();
    final appointmentsResult = await _appointmentsRepository.getAppointments();
    if (isClosed) return;

    final today = DateTime.now();
    final todayAppointments = appointmentsResult
        .getOrElse(() => const [])
        .where((a) => a.isScheduled && a.dateTime.isSameDay(today))
        .length;

    allResult.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
        ),
      ),
      // Patients come back sorted by last visit, newest first.
      (patients) => emit(
        state.copyWith(
          status: Status.success,
          recentPatients: patients.take(5).toList(),
          todayPatientsCount: patients
              .where((p) => p.lastVisitAt.isSameDay(today))
              .length,
          appointmentsCount: todayAppointments,
          totalPatientsCount: patients.length,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _changes.cancel();
    return super.close();
  }
}
