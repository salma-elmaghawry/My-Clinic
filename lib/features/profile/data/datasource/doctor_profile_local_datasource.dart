import 'package:my_clinic/features/profile/domain/entities/doctor_profile.dart';

abstract class DoctorProfileLocalDataSource {
  Future<DoctorProfile> getProfile();

  Future<void> saveProfile(DoctorProfile profile);
}
