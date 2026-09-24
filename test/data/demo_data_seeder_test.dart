import 'package:flutter_test/flutter_test.dart';
import 'package:my_clinic/core/demo/demo_data_seeder.dart';
import 'package:my_clinic/core/helpers/date_helpers.dart';

import '../helpers.dart';

void main() {
  test('demo data loads through the real repositories', () async {
    final repos = await TestRepos.create();
    final now = DateTime(2026, 9, 24, 8);
    await DemoDataSeeder.seed(repos.prefs, now: now);

    final patients = (await repos.patients.getPatients()).getOrElse(
      () => [],
    );
    final prescriptions = (await repos.prescriptions.getPrescriptions())
        .getOrElse(() => []);
    final appointments = (await repos.appointments.getAppointments())
        .getOrElse(() => []);

    expect(patients.length, greaterThanOrEqualTo(30));
    expect(patients.where((p) => p.lastVisitAt.isSameDay(now)), isNotEmpty);
    expect(prescriptions.where((p) => p.isDraft), isNotEmpty);
    expect(
      appointments.where((a) => a.isScheduled && a.dateTime.isSameDay(now)),
      isNotEmpty,
    );
    // Every appointment and prescription points at a real patient.
    final ids = patients.map((p) => p.id).toSet();
    expect(appointments.every((a) => ids.contains(a.patientId)), isTrue);
    expect(prescriptions.every((p) => ids.contains(p.patientId)), isTrue);
    expect(repos.prefs.getString('doctor_profile_name'), 'Dr. Karim Adel');
  });
}
