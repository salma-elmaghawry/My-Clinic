import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';

abstract class PrescriptionsRepository {
  Future<Either<Failure, Prescription>> saveDraft(Prescription prescription);

  Future<Either<Failure, Prescription>> generate(Prescription prescription);

  Future<Either<Failure, List<Prescription>>> getPrescriptions({
    String? patientId,
  });

  Future<Either<Failure, Unit>> deletePrescription(String id);

  Future<Either<Failure, Unit>> deleteForPatient(String patientId);
}
