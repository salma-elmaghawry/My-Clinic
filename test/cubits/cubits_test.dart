import 'package:flutter_test/flutter_test.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:my_clinic/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_detail_cubit.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_form_cubit.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription_status.dart';
import 'package:my_clinic/features/prescription/presentation/cubit/new_prescription_cubit.dart';
import 'package:my_clinic/features/prescription/presentation/screens/new_prescription_args.dart';

import '../helpers.dart';

void main() {
  test('PatientFormCubit creates a patient with trimmed fields', () async {
    final repos = await TestRepos.create();
    final cubit = PatientFormCubit(repos.patients);
    await cubit.save(
      name: '  Ahmed Ali ',
      age: 30,
      gender: Gender.male,
      phone: ' ',
      reasonForVisit: 'Checkup',
    );
    expect(cubit.state.isSuccess, isTrue);
    final saved = cubit.state.savedPatient!;
    expect(saved.name, 'Ahmed Ali');
    expect(saved.phone, isNull);
    expect(saved.reasonForVisit, 'Checkup');
  });

  group('NewPrescriptionCubit', () {
    Future<(TestRepos, NewPrescriptionCubit)> setUp() async {
      final repos = await TestRepos.create();
      await repos.patients.savePatient(testPatient());
      final cubit =
          NewPrescriptionCubit(repos.patients, repos.drugs, repos.prescriptions)
            ..init(
              const NewPrescriptionArgs(
                patientId: 'p1',
                patientName: 'Mona Hassan',
                patientAge: 40,
                patientGender: Gender.female,
              ),
            );
      final drugs = (await repos.drugs.getDrugs()).getOrElse(() => []);
      cubit
        ..addDrug(drugs.first)
        ..setDiagnosis('DVT');
      return (repos, cubit);
    }

    test(
      'generate stores one record and updates the patient treatment',
      () async {
        final (repos, cubit) = await setUp();
        await cubit.saveDraft();
        await cubit.generate();

        final all = (await repos.prescriptions.getPrescriptions()).getOrElse(
          () => [],
        );
        expect(all.single.status, PrescriptionStatus.generated);
        expect(cubit.state.generatedPrescription, isNotNull);

        final patient = (await repos.patients.getPatientById(
          'p1',
        )).getOrElse(() => throw 0);
        expect(
          patient.currentTreatments.single.drugName,
          startsWith('Xarelto'),
        );
        expect(patient.lastVisitAt.isAfter(DateTime(2026, 1, 1)), isTrue);
      },
    );

    test('reopening a draft continues the same record', () async {
      final (repos, cubit) = await setUp();
      await cubit.saveDraft();
      final draft = (await repos.prescriptions.getPrescriptions())
          .getOrElse(() => [])
          .single;

      final reopened = NewPrescriptionCubit(
        repos.patients,
        repos.drugs,
        repos.prescriptions,
      )..init(NewPrescriptionArgs.fromDraft(draft));
      expect(reopened.state.diagnosis, 'DVT');
      expect(reopened.state.selectedDrugs, hasLength(1));
      await reopened.generate();
      expect(
        (await repos.prescriptions.getPrescriptions()).getOrElse(() => []),
        hasLength(1),
      );
    });

    test(
      'custom drug is added to the prescription and saved for later',
      () async {
        final (repos, cubit) = await setUp();
        await cubit.addCustomDrug('Brufen 400');
        expect(cubit.state.selectedDrugs.last.drugName, 'Brufen 400');
        final found = (await repos.drugs.searchDrugs(
          'brufen',
        )).getOrElse(() => []);
        expect(found.single.isCustom, isTrue);
      },
    );
  });

  test(
    'AppointmentsCubit.markCompleted moves the patient last visit',
    () async {
      final repos = await TestRepos.create();
      await repos.patients.savePatient(testPatient());
      final visit = DateTime(2026, 4, 10, 11);
      final appointment = Appointment(
        id: 'a1',
        patientId: 'p1',
        patientName: 'Mona Hassan',
        dateTime: visit,
      );
      await repos.appointments.saveAppointment(appointment);

      final cubit = AppointmentsCubit(
        repos.appointments,
        repos.patients,
        repos.events,
      );
      await cubit.markCompleted(appointment);

      final saved = (await repos.appointments.getAppointments())
          .getOrElse(() => [])
          .single;
      expect(saved.status, AppointmentStatus.completed);
      final patient = (await repos.patients.getPatientById(
        'p1',
      )).getOrElse(() => throw 0);
      expect(patient.lastVisitAt, visit);
      await cubit.close();
    },
  );

  test(
    'HomeCubit counts today\'s patients and scheduled appointments',
    () async {
      final repos = await TestRepos.create();
      final now = DateTime.now();
      await repos.patients.savePatient(testPatient(lastVisitAt: now));
      await repos.patients.savePatient(
        testPatient(id: 'p2', lastVisitAt: DateTime(2020)),
      );
      await repos.appointments.saveAppointment(
        Appointment(id: 'a1', patientId: 'p2', patientName: 'X', dateTime: now),
      );
      await repos.appointments.saveAppointment(
        Appointment(
          id: 'a2',
          patientId: 'p2',
          patientName: 'X',
          dateTime: now,
          status: AppointmentStatus.cancelled,
        ),
      );

      final cubit = HomeCubit(repos.patients, repos.appointments, repos.events);
      await cubit.loadHome();
      expect(cubit.state.status, Status.success);
      expect(cubit.state.todayPatientsCount, 1);
      expect(cubit.state.appointmentsCount, 1);
      expect(cubit.state.totalPatientsCount, 2);
      await cubit.close();
    },
  );

  test('PatientDetailCubit deletes the patient with their records', () async {
    final repos = await TestRepos.create();
    await repos.patients.savePatient(testPatient());
    await repos.appointments.saveAppointment(
      Appointment(
        id: 'a1',
        patientId: 'p1',
        patientName: 'Mona',
        dateTime: DateTime(2030),
      ),
    );
    final cubit = PatientDetailCubit(
      repos.patients,
      repos.prescriptions,
      repos.appointments,
      repos.events,
    );
    await cubit.fetchPatient('p1');
    expect(cubit.state.nextAppointment?.id, 'a1');

    await cubit.addHistoryEntry('Hypertension', DateTime(2024));
    await Future<void>.delayed(Duration.zero);
    await cubit.fetchPatient('p1');
    expect(
      cubit.state.patient!.medicalHistory.single.condition,
      'Hypertension',
    );

    await cubit.deletePatient();
    expect(cubit.state.deleted, isTrue);
    expect((await repos.patients.getPatients()).getOrElse(() => []), isEmpty);
    expect(
      (await repos.appointments.getAppointments()).getOrElse(() => []),
      isEmpty,
    );
    await cubit.close();
  });
}
