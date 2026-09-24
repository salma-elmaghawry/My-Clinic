import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/error_mapper.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/core/storage/clinic_data_events.dart';
import 'package:my_clinic/features/patients/data/datasource/patients_local_datasource.dart';
import 'package:my_clinic/features/patients/data/models/patient_model.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';

import 'patients_repository.dart';

class PatientsRepositoryImpl implements PatientsRepository {
  final PatientsLocalDataSource _localDataSource;
  final ClinicDataEvents _events;

  PatientsRepositoryImpl(this._localDataSource, this._events);

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
  Future<Either<Failure, List<Patient>>> getRecentPatients({
    int limit = 5,
  }) async {
    try {
      final models = await _localDataSource.getRecentPatients(limit: limit);
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Patient>> savePatient(Patient patient) async {
    try {
      final model = await _localDataSource.savePatient(
        PatientModel.fromEntity(patient),
      );
      _events.notifyChanged();
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePatient(String id) async {
    try {
      await _localDataSource.deletePatient(id);
      _events.notifyChanged();
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
