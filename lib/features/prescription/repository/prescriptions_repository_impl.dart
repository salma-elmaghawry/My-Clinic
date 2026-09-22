import 'package:dartz/dartz.dart';
import 'package:dr_ahmed/core/error_handling/error_mapper.dart';
import 'package:dr_ahmed/core/error_handling/failures.dart';
import 'package:dr_ahmed/features/prescription/data/datasource/prescriptions_local_datasource.dart';
import 'package:dr_ahmed/features/prescription/data/models/prescription_model.dart';
import 'package:dr_ahmed/features/prescription/domain/entities/prescription.dart';

import 'prescriptions_repository.dart';

class PrescriptionsRepositoryImpl implements PrescriptionsRepository {
  final PrescriptionsLocalDataSource _localDataSource;

  PrescriptionsRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, Prescription>> saveDraft(Prescription prescription) async {
    try {
      final model = await _localDataSource.saveDraft(
        PrescriptionModel.fromEntity(prescription),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Prescription>> generate(Prescription prescription) async {
    try {
      final model = await _localDataSource.generate(
        PrescriptionModel.fromEntity(prescription),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
