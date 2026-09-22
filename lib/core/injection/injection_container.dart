import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dr_ahmed/core/routes/app_router.dart';
import 'package:dr_ahmed/core/theme/controller/theme_cubit.dart';
import 'package:dr_ahmed/features/home/presentation/cubit/home_cubit.dart';
import 'package:dr_ahmed/features/patients/data/datasource/patients_local_datasource.dart';
import 'package:dr_ahmed/features/patients/data/datasource/patients_local_datasource_impl.dart';
import 'package:dr_ahmed/features/patients/presentation/cubit/patient_detail_cubit.dart';
import 'package:dr_ahmed/features/patients/presentation/cubit/patients_cubit.dart';
import 'package:dr_ahmed/features/patients/repository/patients_repository.dart';
import 'package:dr_ahmed/features/patients/repository/patients_repository_impl.dart';
import 'package:dr_ahmed/features/prescription/data/datasource/drugs_local_datasource.dart';
import 'package:dr_ahmed/features/prescription/data/datasource/drugs_local_datasource_impl.dart';
import 'package:dr_ahmed/features/prescription/data/datasource/prescriptions_local_datasource.dart';
import 'package:dr_ahmed/features/prescription/data/datasource/prescriptions_local_datasource_impl.dart';
import 'package:dr_ahmed/features/prescription/presentation/cubit/new_prescription_cubit.dart';
import 'package:dr_ahmed/features/prescription/repository/drugs_repository.dart';
import 'package:dr_ahmed/features/prescription/repository/drugs_repository_impl.dart';
import 'package:dr_ahmed/features/prescription/repository/prescriptions_repository.dart';
import 'package:dr_ahmed/features/prescription/repository/prescriptions_repository_impl.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt()));

  // Patients feature
  getIt.registerLazySingleton<PatientsLocalDataSource>(
    () => PatientsLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<PatientsRepository>(
    () => PatientsRepositoryImpl(getIt()),
  );
  getIt.registerFactory<PatientsCubit>(() => PatientsCubit(getIt()));
  getIt.registerFactory<PatientDetailCubit>(() => PatientDetailCubit(getIt()));

  // Prescription feature (drugs + prescriptions data layers)
  getIt.registerLazySingleton<DrugsLocalDataSource>(
    () => DrugsLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<DrugsRepository>(
    () => DrugsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<PrescriptionsLocalDataSource>(
    () => PrescriptionsLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<PrescriptionsRepository>(
    () => PrescriptionsRepositoryImpl(getIt()),
  );
  getIt.registerFactory<NewPrescriptionCubit>(
    () => NewPrescriptionCubit(getIt(), getIt(), getIt()),
  );

  // Home feature (reuses PatientsRepository)
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt()));
}
