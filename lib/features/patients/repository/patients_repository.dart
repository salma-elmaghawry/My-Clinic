import 'package:dartz/dartz.dart';
import 'package:dr_ahmed/core/error_handling/failures.dart';
import 'package:dr_ahmed/features/patients/domain/entities/patient.dart';

abstract class PatientsRepository {
  Future<Either<Failure, List<Patient>>> getPatients();

  Future<Either<Failure, List<Patient>>> searchPatients(String query);

  Future<Either<Failure, Patient>> getPatientById(String id);

  Future<Either<Failure, List<Patient>>> getRecentPatients({int limit = 5});
}
