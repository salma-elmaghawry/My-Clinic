import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_clinic/app.dart';
import 'package:my_clinic/core/config/supabase_config.dart';
import 'package:my_clinic/core/demo/demo_data_seeder.dart';
import 'package:my_clinic/core/injection/injection_container.dart';
import 'package:my_clinic/core/services/daily_reminder_service.dart';
import 'package:my_clinic/core/theme/controller/theme_cubit.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Skipped until the Supabase URL and publishable key are passed via
  // --dart-define (see docs/SUPABASE_SETUP.md). When skipped, auth is
  // bypassed and the app runs fully on-device.
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  await setupInjection();

  // Only with --dart-define=DEMO_DATA=true|reset, for demo videos and
  // screenshots. A normal build skips this entirely.
  await DemoDataSeeder.seedIfRequested(getIt<SharedPreferences>());

  // Re-arm the daily reminder if the doctor had already turned it on — the
  // OS can drop scheduled notifications across an app update or reboot.
  unawaited(getIt<DailyReminderService>().rescheduleIfEnabled());

  final savedLocaleCode = getIt<SharedPreferences>().getString('app_locale');
  final startLocale = (savedLocaleCode != null) ? Locale(savedLocaleCode) : null;

  runApp(
    EasyLocalization(
      startLocale: startLocale,
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (context) => getIt<ThemeCubit>()),
          BlocProvider<DoctorProfileCubit>(
            create: (context) => getIt<DoctorProfileCubit>(),
          ),
        ],
        child: const MyClinicApp(),
      ),
    ),
  );
}
