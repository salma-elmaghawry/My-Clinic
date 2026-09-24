import 'package:my_clinic/features/profile/domain/entities/doctor_profile.dart';

abstract class DoctorProfileLocalDataSource {
  Future<DoctorProfile> getProfile();

  Future<void> saveProfile(DoctorProfile profile);

  /// Copies the image at [sourcePath] into app storage as the doctor's
  /// photo, replacing any previous one, and returns the stored file's path.
  Future<String> savePhoto(String sourcePath);

  /// Deletes the stored photo, if any.
  Future<void> removePhoto();
}
