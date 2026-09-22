import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final PatientsRepository _patientsRepository;

  HomeCubit(this._patientsRepository) : super(const HomeState());

  Future<void> loadHome() async {
    emit(state.copyWith(status: Status.loading));
    final result = await _patientsRepository.getRecentPatients(limit: 5);
    result.fold(
      (failure) => emit(state.copyWith(
        status: Status.failure,
        message: failure.message,
        failure: failure,
      )),
      (recentPatients) => emit(state.copyWith(
        status: Status.success,
        recentPatients: recentPatients,
        // Placeholder stats until real data sources exist for this pass.
        todayPatientsCount: recentPatients.length,
        // TODO: replace with AppointmentsRepository once that feature ships.
        appointmentsCount: 3,
      )),
    );
  }
}
