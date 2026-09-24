import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/profile/domain/entities/doctor_profile.dart';

abstract class DoctorProfileRepository {
  Future<Either<Failure, DoctorProfile>> getProfile();

  Future<Either<Failure, DoctorProfile>> saveProfile(DoctorProfile profile);

  /// Stores the image at [sourcePath] as the doctor's photo and returns the
  /// path of the stored copy.
  Future<Either<Failure, String>> savePhoto(String sourcePath);

  Future<Either<Failure, Unit>> removePhoto();
}
