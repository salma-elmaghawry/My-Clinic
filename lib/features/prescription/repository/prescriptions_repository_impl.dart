import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/error_mapper.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/core/storage/clinic_data_events.dart';
import 'package:my_clinic/features/prescription/data/datasource/prescriptions_local_datasource.dart';
import 'package:my_clinic/features/prescription/data/models/prescription_model.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription_status.dart';

import 'prescriptions_repository.dart';

class PrescriptionsRepositoryImpl implements PrescriptionsRepository {
  final PrescriptionsLocalDataSource _localDataSource;
  final ClinicDataEvents _events;

  PrescriptionsRepositoryImpl(this._localDataSource, this._events);

  @override
  Future<Either<Failure, Prescription>> saveDraft(Prescription prescription) =>
      _save(prescription, PrescriptionStatus.draft);

  @override
  Future<Either<Failure, Prescription>> generate(Prescription prescription) =>
      _save(prescription, PrescriptionStatus.generated);

  Future<Either<Failure, Prescription>> _save(
    Prescription prescription,
    PrescriptionStatus status,
  ) async {
    try {
      final model = await _localDataSource.save(
        PrescriptionModel.fromEntity(prescription.copyWith(status: status)),
      );
      _events.notifyChanged();
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, List<Prescription>>> getPrescriptions({
    String? patientId,
  }) async {
    try {
      final models = await _localDataSource.getPrescriptions(
        patientId: patientId,
      );
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePrescription(String id) async {
    try {
      await _localDataSource.deletePrescription(id);
      _events.notifyChanged();
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteForPatient(String patientId) async {
    try {
      await _localDataSource.deleteForPatient(patientId);
      _events.notifyChanged();
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
