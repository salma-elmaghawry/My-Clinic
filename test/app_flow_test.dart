// Drives the real app: boots past the splash, adds a patient through the
// form, then visits every tab plus the drug database and stats screens,
// failing on any exception or layout overflow.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_clinic/app.dart';
import 'package:my_clinic/core/injection/injection_container.dart';
import 'package:my_clinic/core/theme/controller/theme_cubit.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester, String locale) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({'app_locale': locale});
  await EasyLocalization.ensureInitialized();
  await getIt.reset();
  await setupInjection();

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      fallbackLocale: const Locale('en'),
      startLocale: Locale(locale),
      saveLocale: false,
      path: 'assets/translations',
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
          BlocProvider<DoctorProfileCubit>(
            create: (_) => getIt<DoctorProfileCubit>(),
          ),
        ],
        child: const MyClinicApp(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1300));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('add a patient and visit every screen', (tester) async {
    await _pumpApp(tester, 'en');

    // Patients tab: empty state, then add a patient.
    await tester.tap(find.text('Patients').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('No patients yet'), findsOneWidget);

    await tester.tap(find.text('Add patient'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Nour Samir',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '33');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Lands on the new patient's file with all four tabs.
    expect(find.text('Patient File'), findsOneWidget);
    expect(find.text('Nour Samir'), findsWidgets);
    for (final tab in [
      'Current Treatment',
      'Visits',
      'Prescriptions',
      'Medical History',
    ]) {
      await tester.ensureVisible(find.text(tab));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
    }
    final saved = (await getIt<PatientsRepository>().getPatients()).getOrElse(
      () => [],
    );
    expect(saved.single.name, 'Nour Samir');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Nour Samir'), findsOneWidget);

    // Appointments tab.
    await tester.tap(find.text('Appointments').last);
    await tester.pumpAndSettle();
    expect(find.text('No appointments on this day'), findsOneWidget);

    // Home: quick access to drug database and stats.
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Drug Database'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drug Database'));
    await tester.pumpAndSettle();
    expect(find.text('Xarelto'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Clinic Stats'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clinic Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Total patients'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Settings no longer shows a "coming soon" placeholder.
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Coming soon'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic (right-to-left) screens lay out without overflow', (
    tester,
  ) async {
    await _pumpApp(tester, 'ar');

    Future<void> tapIcon(IconData icon) async {
      await tester.ensureVisible(find.byIcon(icon).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(icon).first);
      await tester.pumpAndSettle();
    }

    Future<void> tapTab(IconData icon) async {
      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byIcon(icon),
        ),
      );
      await tester.pumpAndSettle();
    }

    await tapTab(Icons.people_alt_outlined);
    await tapIcon(Icons.person_add_alt_1);
    await tester.enterText(find.byType(TextFormField).at(0), 'نور سمير');
    await tester.enterText(find.byType(TextFormField).at(1), '33');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('نور سمير'), findsWidgets);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tapTab(Icons.event_note_outlined);
    // Let the "patient saved" snackbar time out; it sits over the FAB.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tapTab(Icons.home_outlined);
    await tapIcon(Icons.medication_liquid_outlined);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tapIcon(Icons.insights_outlined);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tapTab(Icons.settings_outlined);
    expect(tester.takeException(), isNull);
  });
}
