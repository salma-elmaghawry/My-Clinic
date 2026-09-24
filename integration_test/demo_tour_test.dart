// Scripted demo tour for the README screenshots and the demo video.
//
// It seeds the fictional demo clinic, then walks through every main feature
// at a human pace. Each stop saves a screenshot to docs/screenshots/.
// Run it with scripts/record_demo.sh, which also records the simulator
// screen, or directly:
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/demo_tour_test.dart -d <device>

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_clinic/app.dart';
import 'package:my_clinic/core/demo/demo_data_seeder.dart';
import 'package:my_clinic/core/injection/injection_container.dart';
import 'package:my_clinic/core/theme/controller/theme_cubit.dart';
import 'package:my_clinic/features/appointments/presentation/widgets/week_date_strip.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('demo tour', (tester) async {
    // Fresh demo clinic in English and light mode on every run.
    // Clear first: EasyLocalization would otherwise restore a language
    // saved by an earlier session on this device.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await EasyLocalization.ensureInitialized();
    await prefs.setString('app_locale', 'en');
    await DemoDataSeeder.seed(prefs);
    await getIt.reset();
    await setupInjection();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
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

    // ignore: avoid_print
    print('DEMO_TOUR_START');
    final tour = _Tour(tester, binding);

    // 1. Home: today's numbers, milestone card, recent patients.
    await tour.pause(2600);
    await tour.shot('01_home');
    await tour.scrollDown(360);
    await tour.pause(1600);
    await tour.shot('02_home_recent_patients');
    await tour.scrollUp(360);

    // 2. Patients list, search, and one patient's file.
    await tour.tab(Icons.people_alt_outlined);
    await tour.pause(1600);
    await tour.shot('03_patients');
    await tour.type(find.byType(TextField).first, 'Youss');
    await tour.pause(1200);
    await tour.tap(find.text('Youssef Ibrahim').last);
    await tour.pause(1800);
    await tour.shot('04_patient_file');
    for (final tabLabel in ['Current Treatment', 'Visits', 'Prescriptions']) {
      await tester.ensureVisible(find.text(tabLabel));
      await tour.tap(find.text(tabLabel));
      await tour.pause(1600);
      if (tabLabel == 'Current Treatment') {
        await tour.shot('05_patient_treatment');
      }
    }
    await tour.back();
    await tester.enterText(find.byType(TextField).first, '');
    await tour.pause(600);

    // 3. Write a prescription with the drug search, then preview it.
    await tour.tab(Icons.add_circle_outline);
    await tour.pause(1000);
    await tour.type(find.byType(TextField).first, 'Mona');
    await tour.pause(800);
    await tour.tap(find.text('Mona Hassan').last);
    await tour.pause(800);
    await tour.type(
      find.widgetWithText(TextField, 'Diagnosis'),
      'Varicose veins, both legs (CEAP C2)',
    );
    await tour.type(
      find.widgetWithText(TextField, 'Search drugs by name'),
      'Detra',
    );
    await tour.pause(900);
    await tour.tap(find.text('Detralex').last);
    await tour.pause(900);
    await tour.type(
      find.widgetWithText(TextField, 'Search drugs by name'),
      'Compress',
    );
    await tour.pause(900);
    await tour.tap(find.text('Compression Stockings').last);
    await tour.pause(1000);
    final durations = find.widgetWithText(TextField, 'Duration');
    for (var i = 0; i < 2; i++) {
      await tester.ensureVisible(durations.at(i));
      await tester.pumpAndSettle();
      await tester.enterText(durations.at(i), '3 months');
      await tour.pause(700);
    }
    await tester.ensureVisible(find.text('Mona Hassan').first);
    await tour.pause(600);
    await tour.shot('06_new_prescription');
    await tester.ensureVisible(find.text('Generate'));
    await tour.pause(1200);
    await tour.tap(find.text('Generate'));
    await tour.pause(2600);
    await tour.shot('07_prescription_preview');
    await tour.scrollDown(420);
    await tour.pause(1800);
    await tour.shot('08_prescription_qr');
    await tour.back();

    // 4. Appointments: today's schedule, then the rest of the week.
    await tour.tab(Icons.event_note_outlined);
    await tour.pause(2000);
    await tour.shot('09_appointments');
    // Peek at tomorrow (or yesterday, if tomorrow starts a new week).
    Finder dayCell(DateTime d) => find.descendant(
      of: find.byType(WeekDateStrip),
      matching: find.text('${d.day}'),
    );
    final now = DateTime.now();
    final tomorrow = dayCell(now.add(const Duration(days: 1)));
    await tour.tap(
      tomorrow.evaluate().isNotEmpty
          ? tomorrow
          : dayCell(now.subtract(const Duration(days: 1))),
    );
    await tour.pause(1600);
    await tour.tap(find.byTooltip('Today'));
    await tour.pause(1000);

    // 5. Drug database and clinic stats from Home's quick access.
    await tour.tab(Icons.home_outlined);
    await tester.ensureVisible(find.text('Drug Database'));
    await tour.pause(800);
    await tour.tap(find.text('Drug Database'));
    await tour.pause(1800);
    await tour.shot('10_drug_database');
    await tour.back();
    await tester.ensureVisible(find.text('Clinic Stats'));
    await tour.pause(600);
    await tour.tap(find.text('Clinic Stats'));
    await tour.pause(2200);
    await tour.shot('11_stats');
    await tour.scrollDown(500);
    await tour.pause(1800);
    await tour.shot('12_stats_top_drugs');
    await tour.back();
    await tour.scrollUp(1200);

    // 6. Settings: dark mode, then Arabic (right-to-left).
    await tour.tab(Icons.settings_outlined);
    await tour.pause(1400);
    await tour.shot('13_settings');
    await tour.tap(find.text('Dark'));
    await tour.pause(1200);
    await tour.tab(Icons.home_outlined);
    await tour.pause(1800);
    await tour.shot('14_home_dark');
    await tour.tab(Icons.settings_outlined);
    await tour.tap(find.text('AR'));
    await tour.pause(1400);
    await tour.tab(Icons.home_outlined);
    await tour.pause(1800);
    await tour.shot('15_home_arabic_dark');
    await tour.tab(Icons.settings_outlined);
    await tour.tap(find.byIcon(Icons.light_mode_outlined));
    await tour.pause(1000);
    await tour.tab(Icons.people_alt_outlined);
    await tour.pause(1200);
    await tour.tap(find.text('Nour Samir').first);
    await tour.pause(1800);
    await tour.shot('16_patient_file_arabic');
    await tour.back();
    await tour.tab(Icons.home_outlined);
    await tour.pause(2000);
    await tour.shot('17_home_arabic');

    // ignore: avoid_print
    print('DEMO_TOUR_END');
    await tour.pause(800);

    // Leave the simulator in English for the next run.
    await context(tester).setLocale(const Locale('en'));
    await tester.pumpAndSettle();
  });
}

BuildContext context(WidgetTester tester) =>
    tester.element(find.byType(MaterialApp));

/// Small helpers that keep the tour readable and paced for video.
class _Tour {
  final WidgetTester tester;
  final IntegrationTestWidgetsFlutterBinding binding;

  _Tour(this.tester, this.binding);

  Future<void> pause([int ms = 1200]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    await tester.pumpAndSettle();
  }

  Future<void> shot(String name) async {
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  Future<void> tap(Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tab(IconData icon) async {
    await tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(icon),
      ),
    );
    await pause(500);
  }

  Future<void> back() async {
    await tap(find.byType(BackButton).first);
    await pause(900);
  }

  /// Types one character at a time so the video shows real typing.
  Future<void> type(Finder field, String text) async {
    await tester.tap(field);
    for (var i = 1; i <= text.length; i++) {
      await tester.enterText(field, text.substring(0, i));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 55));
    }
    await tester.pumpAndSettle();
  }

  Future<void> scrollDown(double by) => _scroll(-by);

  Future<void> scrollUp(double by) => _scroll(by);

  Future<void> _scroll(double dy) async {
    final scrollable = find.byType(Scrollable).hitTestable().first;
    await tester.timedDrag(
      scrollable,
      Offset(0, dy),
      const Duration(milliseconds: 700),
    );
    await tester.pumpAndSettle();
  }
}
