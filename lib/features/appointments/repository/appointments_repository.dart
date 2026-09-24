import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';

abstract class AppointmentsRepository {
  Future<Either<Failure, List<Appointment>>> getAppointments({
    String? patientId,
  });

  Future<Either<Failure, Appointment>> saveAppointment(Appointment appointment);

  Future<Either<Failure, Unit>> deleteAppointment(String id);

  Future<Either<Failure, Unit>> deleteForPatient(String patientId);
}
