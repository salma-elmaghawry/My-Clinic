import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dr_ahmed/core/bloc/base_bloc.dart';
import 'package:dr_ahmed/features/patients/repository/patients_repository.dart';

import 'patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  final PatientsRepository _repository;

  PatientsCubit(this._repository) : super(const PatientsState());

  Future<void> fetchPatients() async {
    emit(state.copyWith(status: Status.loading, action: PatientsAction.fetch));
    final result = await _repository.getPatients();
    result.fold(
      (failure) => emit(state.copyWith(
        status: Status.failure,
        message: failure.message,
        failure: failure,
        action: PatientsAction.fetch,
      )),
      (patients) => emit(state.copyWith(
        status: Status.success,
        patients: patients,
        action: PatientsAction.fetch,
      )),
    );
  }

  Future<void> search(String query) async {
    emit(state.copyWith(
      status: Status.loading,
      query: query,
      action: PatientsAction.search,
    ));
    final result = await _repository.searchPatients(query);
    result.fold(
      (failure) => emit(state.copyWith(
        status: Status.failure,
        message: failure.message,
        failure: failure,
        action: PatientsAction.search,
      )),
      (patients) => emit(state.copyWith(
        status: Status.success,
        patients: patients,
        action: PatientsAction.search,
      )),
    );
  }
}
