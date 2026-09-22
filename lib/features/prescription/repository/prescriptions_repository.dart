import 'package:dartz/dartz.dart';
import 'package:dr_ahmed/core/error_handling/failures.dart';
import 'package:dr_ahmed/features/prescription/domain/entities/prescription.dart';

abstract class PrescriptionsRepository {
  Future<Either<Failure, Prescription>> saveDraft(Prescription prescription);

  Future<Either<Failure, Prescription>> generate(Prescription prescription);
}
