import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/error_mapper.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/core/storage/clinic_data_events.dart';
import 'package:my_clinic/features/appointments/data/datasource/appointments_local_datasource.dart';
import 'package:my_clinic/features/appointments/data/models/appointment_model.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';

import 'appointments_repository.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final AppointmentsLocalDataSource _localDataSource;
  final ClinicDataEvents _events;

  AppointmentsRepositoryImpl(this._localDataSource, this._events);

  @override
  Future<Either<Failure, List<Appointment>>> getAppointments({
    String? patientId,
  }) async {
    try {
      final models = await _localDataSource.getAppointments(
        patientId: patientId,
      );
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Appointment>> saveAppointment(
    Appointment appointment,
  ) async {
    try {
      final model = await _localDataSource.saveAppointment(
        AppointmentModel.fromEntity(appointment),
      );
      _events.notifyChanged();
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAppointment(String id) async {
    try {
      await _localDataSource.deleteAppointment(id);
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
