import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/storage/clinic_data_events.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';

import 'patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  final PatientsRepository _repository;
  late final StreamSubscription<void> _changes;

  PatientsCubit(this._repository, ClinicDataEvents events)
    : super(const PatientsState()) {
    // Re-run the current search whenever patients change elsewhere.
    _changes = events.stream.listen((_) => search(state.query));
  }

  Future<void> fetchPatients() async {
    emit(state.copyWith(status: Status.loading, action: PatientsAction.fetch));
    final result = await _repository.getPatients();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: PatientsAction.fetch,
        ),
      ),
      (patients) => emit(
        state.copyWith(
          status: Status.success,
          patients: patients,
          action: PatientsAction.fetch,
        ),
      ),
    );
  }

  Future<void> search(String query) async {
    emit(
      state.copyWith(
        status: Status.loading,
        query: query,
        action: PatientsAction.search,
      ),
    );
    final result = await _repository.searchPatients(query);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: PatientsAction.search,
        ),
      ),
      (patients) => emit(
        state.copyWith(
          status: Status.success,
          patients: patients,
          action: PatientsAction.search,
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
