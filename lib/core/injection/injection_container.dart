import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_clinic/core/routes/app_router.dart';
import 'package:my_clinic/core/services/daily_reminder_service.dart';
import 'package:my_clinic/core/storage/clinic_data_events.dart';
import 'package:my_clinic/core/storage/json_list_store.dart';
import 'package:my_clinic/features/appointments/data/datasource/appointments_local_datasource.dart';
import 'package:my_clinic/features/appointments/data/datasource/appointments_local_datasource_impl.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointment_form_cubit.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:my_clinic/features/appointments/repository/appointments_repository.dart';
import 'package:my_clinic/features/appointments/repository/appointments_repository_impl.dart';
import 'package:my_clinic/features/drug_database/presentation/cubit/drug_database_cubit.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_form_cubit.dart';
import 'package:my_clinic/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:my_clinic/core/theme/controller/theme_cubit.dart';
import 'package:my_clinic/features/settings/presentation/cubit/daily_reminder_cubit.dart';
import 'package:my_clinic/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_clinic/features/patients/data/datasource/patients_local_datasource.dart';
import 'package:my_clinic/features/patients/data/datasource/patients_local_datasource_impl.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_detail_cubit.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patients_cubit.dart';
import 'package:my_clinic/features/patients/repository/patients_repository.dart';
import 'package:my_clinic/features/patients/repository/patients_repository_impl.dart';
import 'package:my_clinic/features/prescription/data/datasource/drugs_local_datasource.dart';
import 'package:my_clinic/features/prescription/data/datasource/drugs_local_datasource_impl.dart';
import 'package:my_clinic/features/prescription/data/datasource/prescriptions_local_datasource.dart';
import 'package:my_clinic/features/prescription/data/datasource/prescriptions_local_datasource_impl.dart';
import 'package:my_clinic/features/prescription/presentation/cubit/new_prescription_cubit.dart';
import 'package:my_clinic/features/prescription/repository/drugs_repository.dart';
import 'package:my_clinic/features/prescription/repository/drugs_repository_impl.dart';
import 'package:my_clinic/features/prescription/repository/prescriptions_repository.dart';
import 'package:my_clinic/features/prescription/repository/prescriptions_repository_impl.dart';
import 'package:my_clinic/features/profile/data/datasource/doctor_profile_local_datasource.dart';
import 'package:my_clinic/features/profile/data/datasource/doctor_profile_local_datasource_impl.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';
import 'package:my_clinic/features/profile/repository/doctor_profile_repository.dart';
import 'package:my_clinic/features/profile/repository/doctor_profile_repository_impl.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt()));
  getIt.registerLazySingleton<ClinicDataEvents>(() => ClinicDataEvents());

  // Patients feature
  getIt.registerLazySingleton<PatientsLocalDataSource>(
    () => PatientsLocalDataSourceImpl(
      JsonListStore(sharedPreferences, PatientsLocalDataSourceImpl.storageKey),
    ),
  );
  getIt.registerLazySingleton<PatientsRepository>(
    () => PatientsRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory<PatientsCubit>(() => PatientsCubit(getIt(), getIt()));
  getIt.registerFactory<PatientFormCubit>(() => PatientFormCubit(getIt()));
  getIt.registerFactory<PatientDetailCubit>(
    () => PatientDetailCubit(getIt(), getIt(), getIt(), getIt()),
  );

  // Prescription feature (drugs + prescriptions data layers)
  getIt.registerLazySingleton<DrugsLocalDataSource>(
    () => DrugsLocalDataSourceImpl(
      JsonListStore(
        sharedPreferences,
        DrugsLocalDataSourceImpl.customDrugsStorageKey,
      ),
    ),
  );
  getIt.registerLazySingleton<DrugsRepository>(
    () => DrugsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<PrescriptionsLocalDataSource>(
    () => PrescriptionsLocalDataSourceImpl(
      JsonListStore(
        sharedPreferences,
        PrescriptionsLocalDataSourceImpl.storageKey,
      ),
    ),
  );
  getIt.registerLazySingleton<PrescriptionsRepository>(
    () => PrescriptionsRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory<DrugDatabaseCubit>(() => DrugDatabaseCubit(getIt()));
  getIt.registerFactory<NewPrescriptionCubit>(
    () => NewPrescriptionCubit(getIt(), getIt(), getIt()),
  );

  // Appointments feature
  getIt.registerLazySingleton<AppointmentsLocalDataSource>(
    () => AppointmentsLocalDataSourceImpl(
      JsonListStore(
        sharedPreferences,
        AppointmentsLocalDataSourceImpl.storageKey,
      ),
    ),
  );
  getIt.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory<AppointmentsCubit>(
    () => AppointmentsCubit(getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<AppointmentFormCubit>(
    () => AppointmentFormCubit(getIt()),
  );

  // Home and stats (read across patients, prescriptions, appointments)
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt(), getIt(), getIt()));
  getIt.registerFactory<StatsCubit>(
    () => StatsCubit(getIt(), getIt(), getIt()),
  );

  // Profile feature — local SharedPreferences today, a drop-in Supabase
  // datasource behind the same repository interface once accounts ship.
  getIt.registerLazySingleton<DoctorProfileLocalDataSource>(
    () => DoctorProfileLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<DoctorProfileRepository>(
    () => DoctorProfileRepositoryImpl(getIt()),
  );
  getIt.registerFactory<DoctorProfileCubit>(() => DoctorProfileCubit(getIt()));

  // Daily "log today's patients" local reminder notification
  getIt.registerLazySingleton<DailyReminderService>(
    () => DailyReminderService(getIt()),
  );
  getIt.registerFactory<DailyReminderCubit>(() => DailyReminderCubit(getIt()));
}
