import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/profile/domain/entities/doctor_profile.dart';

abstract class DoctorProfileRepository {
  Future<Either<Failure, DoctorProfile>> getProfile();

  Future<Either<Failure, DoctorProfile>> saveProfile(DoctorProfile profile);
}
