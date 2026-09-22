import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/error_mapper.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/prescription/data/datasource/drugs_local_datasource.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug.dart';

import 'drugs_repository.dart';

class DrugsRepositoryImpl implements DrugsRepository {
  final DrugsLocalDataSource _localDataSource;

  DrugsRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Drug>>> getDrugs() async {
    try {
      final models = await _localDataSource.getDrugs();
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, List<Drug>>> searchDrugs(String query) async {
    try {
      final models = await _localDataSource.searchDrugs(query);
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
