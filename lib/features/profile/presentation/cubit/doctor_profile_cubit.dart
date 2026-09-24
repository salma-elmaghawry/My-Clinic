import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/features/profile/repository/doctor_profile_repository.dart';

import 'doctor_profile_state.dart';

/// Provided once at the app root (next to [ThemeCubit]) since the doctor's
/// name/specialty/clinic are read from many unrelated screens: splash,
/// home greeting, and every prescription document.
class DoctorProfileCubit extends Cubit<DoctorProfileState> {
  final DoctorProfileRepository _repository;

  DoctorProfileCubit(this._repository) : super(const DoctorProfileState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading));
    final result = await _repository.getProfile();
    result.fold(
      (failure) => emit(state.copyWith(status: Status.failure, message: failure.message, failure: failure)),
      (profile) => emit(state.copyWith(status: Status.success, profile: profile)),
    );
  }

  Future<bool> save({
    required String name,
    required String specialty,
    required String clinicName,
  }) async {
    emit(state.copyWith(status: Status.loading));
    final updated = state.profile.copyWith(
      name: name,
      specialty: specialty,
      clinicName: clinicName,
    );
    final result = await _repository.saveProfile(updated);
    return result.fold(
      (failure) {
        emit(state.copyWith(status: Status.failure, message: failure.message, failure: failure));
        return false;
      },
      (profile) {
        emit(state.copyWith(status: Status.success, profile: profile));
        return true;
      },
    );
  }

  /// Saves the photo right away (like most avatar pickers) instead of
  /// waiting for the form's Save button.
  Future<bool> updatePhoto(String sourcePath) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _repository.savePhoto(sourcePath);
    return result.fold(
      (failure) {
        emit(state.copyWith(status: Status.failure, message: failure.message, failure: failure));
        return false;
      },
      (storedPath) {
        emit(state.copyWith(
          status: Status.success,
          profile: state.profile.copyWith(photoPath: storedPath),
        ));
        return true;
      },
    );
  }

  Future<bool> removePhoto() async {
    emit(state.copyWith(status: Status.loading));
    final result = await _repository.removePhoto();
    return result.fold(
      (failure) {
        emit(state.copyWith(status: Status.failure, message: failure.message, failure: failure));
        return false;
      },
      (_) {
        emit(state.copyWith(
          status: Status.success,
          profile: state.profile.copyWith(clearPhoto: true),
        ));
        return true;
      },
    );
  }
}
