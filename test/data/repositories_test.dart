import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';
import 'package:my_clinic/features/patients/repository/patients_repository_impl.dart';
import 'package:my_clinic/features/patients/data/datasource/patients_local_datasource_impl.dart';
import 'package:my_clinic/core/storage/json_list_store.dart';
import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug_category.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription_status.dart';

import '../helpers.dart';

T right<T>(Either<Failure, T> e) => e.getOrElse(() => throw StateError('$e'));

void main() {
  group('Patients', () {
    test(
      'saved patients survive a new datasource instance (app restart)',
      () async {
        final repos = await TestRepos.create();
        await repos.patients.savePatient(testPatient());

        final restarted = PatientsRepositoryImpl(
          PatientsLocalDataSourceImpl(
            JsonListStore(repos.prefs, PatientsLocalDataSourceImpl.storageKey),
          ),
          repos.events,
        );
        final patients = right(await restarted.getPatients());
        expect(patients.single.name, 'Mona Hassan');
      },
    );

    test('search matches name and phone digits', () async {
      final repos = await TestRepos.create();
      await repos.patients.savePatient(testPatient());
      await repos.patients.savePatient(
        testPatient(id: 'p2', name: 'Karim Adel', phone: '0111 999 0000'),
      );

      expect(
        right(await repos.patients.searchPatients('mona')).single.id,
        'p1',
      );
      expect(
        right(await repos.patients.searchPatients('1119990')).single.id,
        'p2',
      );
      expect(right(await repos.patients.searchPatients('')).length, 2);
    });

    test('list is sorted by last visit, newest first', () async {
      final repos = await TestRepos.create();
      await repos.patients.savePatient(
        testPatient(id: 'old', lastVisitAt: DateTime(2025)),
      );
      await repos.patients.savePatient(
        testPatient(id: 'new', lastVisitAt: DateTime(2026)),
      );
      expect(right(await repos.patients.getPatients()).map((p) => p.id), [
        'new',
        'old',
      ]);
    });

    test('save updates in place, delete removes, missing id fails', () async {
      final repos = await TestRepos.create();
      await repos.patients.savePatient(testPatient());
      await repos.patients.savePatient(testPatient().copyWith(name: 'Mona H.'));
      expect(right(await repos.patients.getPatients()).single.name, 'Mona H.');

      await repos.patients.deletePatient('p1');
      expect(right(await repos.patients.getPatients()), isEmpty);
      expect((await repos.patients.getPatientById('p1')).isLeft(), isTrue);
    });

    test('writes notify listeners so open screens refresh', () async {
      final repos = await TestRepos.create();
      var notified = 0;
      repos.events.stream.listen((_) => notified++);
      await repos.patients.savePatient(testPatient());
      await Future<void>.delayed(Duration.zero);
      expect(notified, 1);
    });
  });

  group('Prescriptions', () {
    Prescription rx(String id, {String patientId = 'p1', DateTime? date}) =>
        Prescription(
          id: id,
          patientId: patientId,
          patientName: 'Mona',
          patientAge: 40,
          patientGender: Gender.female,
          date: date ?? DateTime(2026, 3, 1),
          diagnosis: 'Flu',
          status: PrescriptionStatus.draft,
        );

    test('draft then generate with the same id keeps one record', () async {
      final repos = await TestRepos.create();
      await repos.prescriptions.saveDraft(rx('r1'));
      await repos.prescriptions.generate(rx('r1'));

      final all = right(await repos.prescriptions.getPrescriptions());
      expect(all.single.status, PrescriptionStatus.generated);
    });

    test('filter by patient and delete for patient', () async {
      final repos = await TestRepos.create();
      await repos.prescriptions.generate(rx('r1'));
      await repos.prescriptions.generate(rx('r2', patientId: 'p2'));

      expect(
        right(
          await repos.prescriptions.getPrescriptions(patientId: 'p2'),
        ).single.id,
        'r2',
      );
      await repos.prescriptions.deleteForPatient('p1');
      expect(
        right(await repos.prescriptions.getPrescriptions()).single.id,
        'r2',
      );
    });
  });

  group('Appointments', () {
    test('sorted by time and filterable by patient', () async {
      final repos = await TestRepos.create();
      await repos.appointments.saveAppointment(
        Appointment(
          id: 'a2',
          patientId: 'p1',
          patientName: 'Mona',
          dateTime: DateTime(2026, 5, 2),
        ),
      );
      await repos.appointments.saveAppointment(
        Appointment(
          id: 'a1',
          patientId: 'p2',
          patientName: 'Karim',
          dateTime: DateTime(2026, 5, 1),
        ),
      );
      expect(
        right(await repos.appointments.getAppointments()).map((a) => a.id),
        ['a1', 'a2'],
      );
      expect(
        right(
          await repos.appointments.getAppointments(patientId: 'p1'),
        ).single.id,
        'a2',
      );
    });
  });

  group('Drugs', () {
    test('custom drugs are listed first, searchable, and deletable', () async {
      final repos = await TestRepos.create();
      final builtInCount = right(await repos.drugs.getDrugs()).length;
      await repos.drugs.addCustomDrug(
        const Drug(
          id: 'c1',
          name: 'Panadol',
          genericName: 'Paracetamol',
          commonDose: '500mg',
          category: DrugCategory.analgesic,
          isCustom: true,
        ),
      );

      final drugs = right(await repos.drugs.getDrugs());
      expect(drugs.length, builtInCount + 1);
      expect(drugs.first.isCustom, isTrue);
      expect(right(await repos.drugs.searchDrugs('paracet')).single.id, 'c1');

      await repos.drugs.deleteCustomDrug('c1');
      expect(right(await repos.drugs.getDrugs()).length, builtInCount);
    });
  });
}
