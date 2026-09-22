import 'package:easy_localization/easy_localization.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/profile/domain/entities/doctor_profile.dart';

class DoctorProfileState extends BaseState {
  final DoctorProfile profile;
  final Failure? failure;

  const DoctorProfileState({
    super.status,
    super.message,
    this.profile = const DoctorProfile(name: '', specialty: '', clinicName: ''),
    this.failure,
  });

  /// What the UI should show for the doctor's name: the real saved value,
  /// or a localized placeholder before the doctor has filled anything in.
  String get displayName =>
      profile.name.isEmpty ? 'profile.default_name'.tr() : profile.name;

  /// Same idea for specialty. Specialty itself is free text (not a
  /// translation key) so the app fits any medical specialty.
  String get displaySpecialty =>
      profile.specialty.isEmpty ? 'profile.default_specialty'.tr() : profile.specialty;

  String get displayClinicName =>
      profile.clinicName.isEmpty ? 'profile.default_clinic'.tr() : profile.clinicName;

  DoctorProfileState copyWith({
    Status? status,
    String? message,
    DoctorProfile? profile,
    Failure? failure,
  }) {
    return DoctorProfileState(
      status: status ?? this.status,
      message: message ?? this.message,
      profile: profile ?? this.profile,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, message, profile, failure];
}
