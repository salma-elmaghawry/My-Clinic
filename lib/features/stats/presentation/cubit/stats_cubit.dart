import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/helpers/date_helpers.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';
import 'package:my_clinic/features/appointments/repository/appointments_repository.dart';
import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';
import 'package:my_clinic/features/prescription/repository/prescriptions_repository.dart';

class DrugUsage {
  final String name;
  final int count;

  const DrugUsage(this.name, this.count);
}

class StatsState extends BaseState {
  final int totalPatients;
  final int newPatientsThisMonth;
  final int prescriptionsThisMonth;
  final int visitsThisMonth;
  final int upcomingAppointments;
  final int malePatients;
  final int femalePatients;
  final List<DrugUsage> topDrugs;

  const StatsState({
    super.status,
    super.message,
    this.totalPatients = 0,
    this.newPatientsThisMonth = 0,
    this.prescriptionsThisMonth = 0,
    this.visitsThisMonth = 0,
    this.upcomingAppointments = 0,
    this.malePatients = 0,
    this.femalePatients = 0,
    this.topDrugs = const [],
  });

  @override
  List<Object?> get props => [
    status,
    message,
    totalPatients,
    newPatientsThisMonth,
    prescriptionsThisMonth,
    visitsThisMonth,
    upcomingAppointments,
    malePatients,
    femalePatients,
    topDrugs.map((d) => '${d.name}:${d.count}').join(','),
  ];
}

class StatsCubit extends Cubit<StatsState> {
  final PatientsRepository _patients;
  final PrescriptionsRepository _prescriptions;
  final AppointmentsRepository _appointments;

  StatsCubit(this._patients, this._prescriptions, this._appointments)
    : super(const StatsState());

  Future<void> load() async {
    emit(const StatsState(status: Status.loading));
    final patients = (await _patients.getPatients()).getOrElse(() => const []);
    final prescriptions = (await _prescriptions.getPrescriptions()).getOrElse(
      () => const [],
    );
    final appointments = (await _appointments.getAppointments()).getOrElse(
      () => const [],
    );
    if (isClosed) return;

    final now = DateTime.now();
    final generated = prescriptions.where((p) => !p.isDraft);

    final drugCounts = <String, int>{};
    for (final p in generated) {
      for (final d in p.drugs) {
        drugCounts.update(d.drugName, (c) => c + 1, ifAbsent: () => 1);
      }
    }
    final topDrugs =
        drugCounts.entries.map((e) => DrugUsage(e.key, e.value)).toList()
          ..sort((a, b) => b.count.compareTo(a.count));

    emit(
      StatsState(
        status: Status.success,
        totalPatients: patients.length,
        newPatientsThisMonth: patients
            .where((p) => p.createdAt.isSameMonth(now))
            .length,
        prescriptionsThisMonth: generated
            .where((p) => p.date.isSameMonth(now))
            .length,
        visitsThisMonth: appointments
            .where(
              (a) =>
                  a.status == AppointmentStatus.completed &&
                  a.dateTime.isSameMonth(now),
            )
            .length,
        upcomingAppointments: appointments
            .where((a) => a.isScheduled && a.dateTime.isAfter(now))
            .length,
        malePatients: patients.where((p) => p.gender == Gender.male).length,
        femalePatients: patients.where((p) => p.gender == Gender.female).length,
        topDrugs: topDrugs.take(5).toList(),
      ),
    );
  }
}
