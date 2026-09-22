import 'package:dartz/dartz.dart';
import 'package:dr_ahmed/core/error_handling/error_mapper.dart';
import 'package:dr_ahmed/core/error_handling/failures.dart';
import 'package:dr_ahmed/features/patients/data/datasource/patients_local_datasource.dart';
import 'package:dr_ahmed/features/patients/domain/entities/patient.dart';

import 'patients_repository.dart';

class PatientsRepositoryImpl implements PatientsRepository {
  final PatientsLocalDataSource _localDataSource;

  PatientsRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Patient>>> getPatients() async {
    try {
      final models = await _localDataSource.getPatients();
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, List<Patient>>> searchPatients(String query) async {
    try {
      final models = await _localDataSource.searchPatients(query);
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Patient>> getPatientById(String id) async {
    try {
      final model = await _localDataSource.getPatientById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, List<Patient>>> getRecentPatients({int limit = 5}) async {
    try {
      final models = await _localDataSource.getRecentPatients(limit: limit);
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
