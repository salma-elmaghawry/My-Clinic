import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/error_mapper.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/profile/data/datasource/doctor_profile_local_datasource.dart';
import 'package:my_clinic/features/profile/domain/entities/doctor_profile.dart';

import 'doctor_profile_repository.dart';

class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  final DoctorProfileLocalDataSource _localDataSource;

  DoctorProfileRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, DoctorProfile>> getProfile() async {
    try {
      return Right(await _localDataSource.getProfile());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, DoctorProfile>> saveProfile(DoctorProfile profile) async {
    try {
      await _localDataSource.saveProfile(profile);
      return Right(profile);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
