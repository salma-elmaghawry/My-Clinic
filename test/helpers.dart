import 'package:my_clinic/core/storage/clinic_data_events.dart';
import 'package:my_clinic/core/storage/json_list_store.dart';
import 'package:my_clinic/features/appointments/data/datasource/appointments_local_datasource_impl.dart';
import 'package:my_clinic/features/appointments/repository/appointments_repository_impl.dart';
import 'package:my_clinic/features/patients/data/datasource/patients_local_datasource_impl.dart';
import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';
import 'package:my_clinic/features/patients/repository/patients_repository_impl.dart';
import 'package:my_clinic/features/prescription/data/datasource/drugs_local_datasource_impl.dart';
import 'package:my_clinic/features/prescription/data/datasource/prescriptions_local_datasource_impl.dart';
import 'package:my_clinic/features/prescription/repository/drugs_repository_impl.dart';
import 'package:my_clinic/features/prescription/repository/prescriptions_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real repositories over mock SharedPreferences, so tests exercise the
/// same persistence code the app uses.
class TestRepos {
  final SharedPreferences prefs;
  final ClinicDataEvents events = ClinicDataEvents();
  late final PatientsRepositoryImpl patients = PatientsRepositoryImpl(
    PatientsLocalDataSourceImpl(
      JsonListStore(prefs, PatientsLocalDataSourceImpl.storageKey),
    ),
    events,
  );
  late final PrescriptionsRepositoryImpl prescriptions =
      PrescriptionsRepositoryImpl(
        PrescriptionsLocalDataSourceImpl(
          JsonListStore(prefs, PrescriptionsLocalDataSourceImpl.storageKey),
        ),
        events,
      );
  late final AppointmentsRepositoryImpl appointments =
      AppointmentsRepositoryImpl(
        AppointmentsLocalDataSourceImpl(
          JsonListStore(prefs, AppointmentsLocalDataSourceImpl.storageKey),
        ),
        events,
      );
  late final DrugsRepositoryImpl drugs = DrugsRepositoryImpl(
    DrugsLocalDataSourceImpl(
      JsonListStore(prefs, DrugsLocalDataSourceImpl.customDrugsStorageKey),
    ),
  );

  TestRepos(this.prefs);

  static Future<TestRepos> create() async {
    SharedPreferences.setMockInitialValues({});
    return TestRepos(await SharedPreferences.getInstance());
  }
}

Patient testPatient({
  String id = 'p1',
  String name = 'Mona Hassan',
  String? phone = '0100 123 4567',
  DateTime? lastVisitAt,
}) {
  final date = lastVisitAt ?? DateTime(2026, 1, 1);
  return Patient(
    id: id,
    name: name,
    age: 40,
    gender: Gender.female,
    phone: phone,
    lastVisitAt: date,
    createdAt: date,
  );
}
