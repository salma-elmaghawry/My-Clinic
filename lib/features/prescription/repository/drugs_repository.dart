import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug.dart';

abstract class DrugsRepository {
  Future<Either<Failure, List<Drug>>> getDrugs();

  Future<Either<Failure, List<Drug>>> searchDrugs(String query);
}
