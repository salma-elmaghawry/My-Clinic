import 'package:dartz/dartz.dart';
import 'package:dr_ahmed/core/error_handling/failures.dart';
import 'package:dr_ahmed/features/prescription/domain/entities/drug.dart';

abstract class DrugsRepository {
  Future<Either<Failure, List<Drug>>> getDrugs();

  Future<Either<Failure, List<Drug>>> searchDrugs(String query);
}
