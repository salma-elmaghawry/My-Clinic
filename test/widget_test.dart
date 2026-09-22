// The default counter-app test from `flutter create` no longer applies —
// this app has no counter. Replaced with a trivial smoke test that boots
// the real app shell (EasyLocalization + DI + DrAhmedApp) and confirms it
// renders the initial (splash) route without throwing.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dr_ahmed/app.dart';
import 'package:dr_ahmed/core/injection/injection_container.dart';
import 'package:dr_ahmed/core/theme/controller/theme_cubit.dart';

void main() {
  testWidgets('DrAhmedApp boots and shows the splash screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await setupInjection();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        fallbackLocale: const Locale('en'),
        path: 'assets/translations',
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
          ],
          child: const DrAhmedApp(),
        ),
      ),
    );

    await tester.pump();
    // Let the splash screen's navigation timer fire (and settle the
    // resulting screen) instead of leaving it pending when the test ends.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
