import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';

import 'patient_detail_state.dart';

class PatientDetailCubit extends Cubit<PatientDetailState> {
  final PatientsRepository _repository;

  PatientDetailCubit(this._repository) : super(const PatientDetailState());

  Future<void> fetchPatient(String id) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _repository.getPatientById(id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: Status.failure,
        message: failure.message,
        failure: failure,
      )),
      (patient) => emit(state.copyWith(status: Status.success, patient: patient)),
    );
  }
}
