import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_clinic/core/storage/json_list_store.dart';
import 'package:my_clinic/features/appointments/data/datasource/appointments_local_datasource_impl.dart';
import 'package:my_clinic/features/appointments/data/models/appointment_model.dart';
import 'package:my_clinic/features/appointments/domain/entities/appointment.dart';
import 'package:my_clinic/features/patients/data/datasource/patients_local_datasource_impl.dart';
import 'package:my_clinic/features/patients/data/models/medical_history_entry_model.dart';
import 'package:my_clinic/features/patients/data/models/next_visit_model.dart';
import 'package:my_clinic/features/patients/data/models/patient_model.dart';
import 'package:my_clinic/features/patients/data/models/treatment_item_model.dart';
import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/prescription/data/datasource/prescriptions_local_datasource_impl.dart';
import 'package:my_clinic/features/prescription/data/models/prescription_drug_model.dart';
import 'package:my_clinic/features/prescription/data/models/prescription_model.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription_status.dart';

/// Fills the app with a realistic, fictional clinic for demo videos and
/// store screenshots. It never runs in a normal build.
///
/// Enable it with a compile-time flag:
///
/// ```bash
/// flutter run --dart-define=DEMO_DATA=true   # seed once, keep later edits
/// flutter run --dart-define=DEMO_DATA=reset  # wipe and re-seed every launch
/// ```
///
/// Every date is relative to the moment of seeding, so "today" always has
/// patients and appointments, and the stats screen always has a busy month.
/// All names and phone numbers are made up.
class DemoDataSeeder {
  static const String mode = String.fromEnvironment('DEMO_DATA');
  static const String _seededFlagKey = 'demo_data_seeded_v1';

  static bool get isEnabled => mode == 'true' || mode == 'reset';

  static Future<void> seedIfRequested(SharedPreferences prefs) async {
    if (!isEnabled) return;
    if (mode == 'true' && (prefs.getBool(_seededFlagKey) ?? false)) return;
    await seed(prefs, now: DateTime.now());
  }

  /// Overwrites patients, prescriptions, appointments and the doctor
  /// profile with the demo clinic.
  static Future<void> seed(SharedPreferences prefs, {DateTime? now}) async {
    final data = _DemoClinic(now ?? DateTime.now()).build();

    await JsonListStore(
      prefs,
      PatientsLocalDataSourceImpl.storageKey,
    ).writeAll(data.patients.map((p) => p.toJson()).toList());
    await JsonListStore(
      prefs,
      PrescriptionsLocalDataSourceImpl.storageKey,
    ).writeAll(data.prescriptions.map((p) => p.toJson()).toList());
    await JsonListStore(
      prefs,
      AppointmentsLocalDataSourceImpl.storageKey,
    ).writeAll(data.appointments.map((a) => a.toJson()).toList());

    // Same keys DoctorProfileLocalDataSourceImpl reads.
    await prefs.setString('doctor_profile_name', 'Dr. Karim Adel');
    await prefs.setString(
      'doctor_profile_specialty',
      'Vascular & Endovascular Surgery',
    );
    await prefs.setString('doctor_profile_clinic_name', 'Vein & Artery Care');
    await prefs.setBool(_seededFlagKey, true);
  }
}

class _DemoData {
  final List<PatientModel> patients;
  final List<PrescriptionModel> prescriptions;
  final List<AppointmentModel> appointments;

  const _DemoData(this.patients, this.prescriptions, this.appointments);
}

/// One treatment plan: a diagnosis and the drugs a vascular surgeon would
/// prescribe for it. Drug ids match the built-in drug list.
class _Plan {
  final String diagnosis;
  final List<PrescriptionDrugModel> drugs;
  final List<String> notes;

  const _Plan(this.diagnosis, this.drugs, [this.notes = const []]);
}

class _DemoPatient {
  final String name;
  final int age;
  final Gender gender;
  final String phone;
  final String reason;
  final List<String> history;
  final int plan;

  const _DemoPatient(
    this.name,
    this.age,
    this.gender,
    this.phone,
    this.reason,
    this.history,
    this.plan,
  );
}

PrescriptionDrugModel _drug(
  String id,
  String name,
  String generic,
  String dose,
  String frequency,
  String duration,
  String when, [
  String? notes,
]) {
  return PrescriptionDrugModel(
    drugId: id,
    drugName: name,
    genericName: generic,
    dose: dose,
    frequency: frequency,
    duration: duration,
    whenToTake: when,
    notes: notes,
  );
}

final _detralex = _drug(
  'd9',
  'Detralex',
  'Diosmin + Hesperidin',
  '500mg',
  'Twice daily',
  '3 months',
  'With meals',
);
final _stockings = _drug(
  'd13',
  'Compression Stockings',
  'Class II stockings',
  '20-30 mmHg',
  'Daily wear',
  '3 months',
  'Apply in the morning',
  'Remove at night',
);
final _xarelto = _drug(
  'd1',
  'Xarelto',
  'Rivaroxaban',
  '20mg',
  'Once daily',
  '3 months',
  'With food',
);
final _cilostazol = _drug(
  'd12',
  'Cilostazol',
  'Cilostazol',
  '100mg',
  'Twice daily',
  '3 months',
  '30 minutes before meals',
);
final _aspirin = _drug(
  'd7',
  'Aspirin',
  'Acetylsalicylic acid',
  '81mg',
  'Once daily',
  'Long term',
  'With food',
);
final _plavix = _drug(
  'd8',
  'Plavix',
  'Clopidogrel',
  '75mg',
  'Once daily',
  'Long term',
  'With or without food',
);
final _silver = _drug(
  'd15',
  'Silver Sulfadiazine Cream',
  'Silver sulfadiazine',
  '1%',
  'Once daily',
  '2 weeks',
  'Apply to clean wound',
);
final _crepe = _drug(
  'd14',
  'Elastic Crepe Bandage',
  'Crepe bandage',
  '10cm',
  'Daily wear',
  '2 weeks',
  'Re-wrap daily',
);
final _augmentin = _drug(
  'd17',
  'Augmentin',
  'Amoxicillin + Clavulanate',
  '1g',
  'Twice daily',
  '7 days',
  'With food',
);
final _voltaren = _drug(
  'd16',
  'Voltaren',
  'Diclofenac sodium',
  '50mg',
  'Twice daily',
  '5 days',
  'With food',
  'Stop if stomach pain',
);
final _clexane = _drug(
  'd4',
  'Clexane',
  'Enoxaparin',
  '40mg',
  'Once daily',
  '10 days',
  'Subcutaneous injection',
);
final _eliquis = _drug(
  'd2',
  'Eliquis',
  'Apixaban',
  '5mg',
  'Twice daily',
  'Long term',
  'With or without food',
);
final _vesselDue = _drug(
  'd10',
  'Vessel Due F',
  'Sulodexide',
  '250 LSU',
  'Once daily',
  '2 months',
  'Before meals',
);
final _pentox = _drug(
  'd11',
  'Pentoxifylline',
  'Pentoxifylline',
  '400mg',
  'Three times daily',
  '2 months',
  'With meals',
);

final List<_Plan> _plans = [
  _Plan(
    'Primary varicose veins, both legs (CEAP C2)',
    [_detralex, _stockings],
    ['Walk 30 minutes daily', 'Elevate legs when resting'],
  ),
  _Plan(
    'Deep vein thrombosis, left popliteal vein',
    [_xarelto, _stockings],
    ['Duplex scan in 4 weeks', 'Avoid long periods of sitting'],
  ),
  _Plan(
    'Peripheral arterial disease with intermittent claudication',
    [_cilostazol, _aspirin],
    ['Stop smoking', 'Supervised walking program'],
  ),
  _Plan(
    'Venous leg ulcer, right medial ankle',
    [_silver, _crepe, _augmentin, _detralex],
    ['Dressing change every 2 days'],
  ),
  _Plan(
    'Diabetic foot infection after debridement',
    [_augmentin, _silver, _voltaren],
    ['Keep HbA1c under 7%'],
  ),
  _Plan('Superficial thrombophlebitis, left great saphenous vein', [
    _clexane,
    _voltaren,
    _stockings,
  ]),
  _Plan(
    'Follow-up after endovenous laser ablation',
    [_clexane, _stockings, _voltaren],
    ['Stockings day and night for 1 week'],
  ),
  _Plan(
    'Atrial fibrillation on long-term anticoagulation',
    [_eliquis],
    ['Kidney function test every 6 months'],
  ),
  _Plan('Chronic venous insufficiency with leg swelling', [
    _vesselDue,
    _detralex,
    _stockings,
  ]),
  _Plan(
    'Carotid artery stenosis after endarterectomy',
    [_aspirin, _plavix],
    ['Carotid duplex in 6 months', 'Control blood pressure'],
  ),
  _Plan('Critical limb ischemia, awaiting angioplasty', [
    _pentox,
    _aspirin,
    _cilostazol,
  ]),
];

const List<_DemoPatient> _people = [
  _DemoPatient(
    'Mona Hassan',
    46,
    Gender.female,
    '0100 214 5567',
    'Heavy, aching legs',
    ['Varicose veins', 'Hypothyroidism'],
    0,
  ),
  _DemoPatient(
    'Ahmed Mostafa',
    58,
    Gender.male,
    '0122 874 1190',
    'Calf pain when walking',
    ['Type 2 diabetes', 'Smoker', 'Hypertension'],
    2,
  ),
  _DemoPatient(
    'Nour Samir',
    33,
    Gender.female,
    '0111 632 4408',
    'Swollen left leg after a long flight',
    ['DVT, left leg'],
    1,
  ),
  _DemoPatient(
    'Youssef Ibrahim',
    67,
    Gender.male,
    '0106 557 2231',
    'Wound on the right ankle',
    ['Chronic venous insufficiency', 'Gout'],
    3,
  ),
  _DemoPatient(
    'Salma Fathy',
    29,
    Gender.female,
    '0128 190 7743',
    'Visible veins, cosmetic concern',
    ['Spider veins'],
    0,
  ),
  _DemoPatient(
    'Omar Khaled',
    61,
    Gender.male,
    '0155 430 9982',
    'Foot ulcer not healing',
    ['Type 2 diabetes', 'Diabetic neuropathy'],
    4,
  ),
  _DemoPatient(
    'Hoda Abdelrahman',
    52,
    Gender.female,
    '0100 778 3321',
    'Painful red cord on the thigh',
    ['Varicose veins'],
    5,
  ),
  _DemoPatient(
    'Mahmoud Saeed',
    44,
    Gender.male,
    '0114 905 6617',
    'Check-up after laser ablation',
    ['Varicose veins', 'EVLA, right leg'],
    6,
  ),
  _DemoPatient(
    'Fatma Ali',
    71,
    Gender.female,
    '0127 316 8854',
    'Anticoagulation review',
    ['Atrial fibrillation', 'Hypertension'],
    7,
  ),
  _DemoPatient(
    'Karim Nabil',
    39,
    Gender.male,
    '0109 662 1028',
    'Leg swelling by evening',
    ['Chronic venous insufficiency'],
    8,
  ),
  _DemoPatient(
    'Rania Magdy',
    48,
    Gender.female,
    '0112 548 9930',
    'Night cramps and heavy legs',
    ['Varicose veins', 'Obesity'],
    8,
  ),
  _DemoPatient(
    'Tarek Hamdy',
    69,
    Gender.male,
    '0120 887 4412',
    'Follow-up after carotid surgery',
    ['Carotid stenosis', 'Ischemic heart disease'],
    9,
  ),
  _DemoPatient(
    'Dina Sherif',
    36,
    Gender.female,
    '0150 223 6675',
    'Post-partum leg swelling',
    ['DVT in pregnancy'],
    1,
  ),
  _DemoPatient(
    'Hassan Farouk',
    74,
    Gender.male,
    '0101 449 3386',
    'Rest pain in the left foot',
    ['Peripheral arterial disease', 'Chronic kidney disease'],
    10,
  ),
  _DemoPatient(
    'Aya Mohamed',
    27,
    Gender.female,
    '0115 870 2249',
    'Varicose veins in pregnancy',
    ['Varicose veins'],
    0,
  ),
  _DemoPatient(
    'Sherif Adel',
    55,
    Gender.male,
    '0128 331 5507',
    'Leg pain while walking',
    ['Hypertension', 'Dyslipidemia'],
    2,
  ),
  _DemoPatient(
    'Mariam Tawfik',
    63,
    Gender.female,
    '0106 124 8890',
    'Ankle wound dressing',
    ['Venous leg ulcer'],
    3,
  ),
  _DemoPatient(
    'Mostafa Gamal',
    50,
    Gender.male,
    '0111 780 6612',
    'Painful vein on the calf',
    ['Superficial thrombophlebitis'],
    5,
  ),
  _DemoPatient(
    'Nadia Hosny',
    58,
    Gender.female,
    '0100 965 3371',
    'Anticoagulation review',
    ['Atrial fibrillation'],
    7,
  ),
  _DemoPatient(
    'Amr Wagdy',
    42,
    Gender.male,
    '0122 509 4480',
    'Aching legs after long shifts',
    ['Chronic venous insufficiency'],
    8,
  ),
  _DemoPatient(
    'Heba Lotfy',
    38,
    Gender.female,
    '0155 612 7734',
    'Check-up after laser ablation',
    ['Varicose veins, left leg'],
    6,
  ),
  _DemoPatient(
    'Ibrahim Zaki',
    66,
    Gender.male,
    '0109 238 5561',
    'Diabetic foot review',
    ['Type 2 diabetes', 'Toe amputation'],
    4,
  ),
  _DemoPatient(
    'Yasmin Reda',
    31,
    Gender.female,
    '0114 457 0093',
    'Visible veins behind the knee',
    ['Spider veins'],
    0,
  ),
  _DemoPatient(
    'Khaled Mansour',
    60,
    Gender.male,
    '0127 804 2215',
    'Follow-up duplex scan',
    ['DVT, right leg', 'Smoker'],
    1,
  ),
  _DemoPatient(
    'Samira Youssef',
    77,
    Gender.female,
    '0101 690 4478',
    'Carotid follow-up',
    ['Carotid stenosis', 'Type 2 diabetes'],
    9,
  ),
  _DemoPatient(
    'Walid Hegazy',
    47,
    Gender.male,
    '0112 145 8826',
    'Swollen ankles',
    ['Chronic venous insufficiency', 'Obesity'],
    8,
  ),
  _DemoPatient(
    'Laila Abbas',
    54,
    Gender.female,
    '0120 376 9954',
    'Heavy legs at the end of the day',
    ['Varicose veins'],
    0,
  ),
  _DemoPatient(
    'Hany Soliman',
    72,
    Gender.male,
    '0150 818 3307',
    'Cold, painful foot',
    ['Peripheral arterial disease', 'Smoker'],
    10,
  ),
  _DemoPatient(
    'Rehab Kamal',
    45,
    Gender.female,
    '0100 531 6620',
    'Red, tender vein',
    ['Superficial thrombophlebitis'],
    5,
  ),
  _DemoPatient(
    'Adel Ramadan',
    64,
    Gender.male,
    '0122 297 1143',
    'Anticoagulation review',
    ['Atrial fibrillation', 'Heart failure'],
    7,
  ),
  _DemoPatient(
    'Ghada Nasser',
    49,
    Gender.female,
    '0111 904 5586',
    'Leg ulcer dressing',
    ['Venous leg ulcer', 'Hypertension'],
    3,
  ),
  _DemoPatient(
    'Bassem Fouad',
    37,
    Gender.male,
    '0128 663 2270',
    'Swelling after football injury',
    ['DVT, left calf'],
    1,
  ),
  _DemoPatient(
    'Eman Salah',
    41,
    Gender.female,
    '0106 715 8839',
    'Varicose veins, second opinion',
    ['Varicose veins'],
    0,
  ),
  _DemoPatient(
    'Ramy Anwar',
    57,
    Gender.male,
    '0155 380 1164',
    'Leg pain on walking',
    ['Type 2 diabetes', 'Smoker'],
    2,
  ),
  _DemoPatient(
    'Noha Ezzat',
    62,
    Gender.female,
    '0109 842 6617',
    'Leg swelling',
    ['Chronic venous insufficiency', 'Hypothyroidism'],
    8,
  ),
  _DemoPatient(
    'Sameh Rizk',
    68,
    Gender.male,
    '0114 526 3398',
    'Carotid follow-up',
    ['Carotid stenosis', 'Hypertension'],
    9,
  ),
  _DemoPatient(
    'Doaa Wahba',
    35,
    Gender.female,
    '0127 219 7741',
    'Check-up after laser ablation',
    ['Varicose veins, right leg'],
    6,
  ),
  _DemoPatient(
    'Magdy Shawky',
    70,
    Gender.male,
    '0101 603 5525',
    'Foot wound review',
    ['Type 2 diabetes', 'Peripheral neuropathy'],
    4,
  ),
];

const List<String> _visitNotes = [
  'Follow-up duplex scan',
  'Wound dressing change',
  'Review test results',
  'Post-op check',
  'First visit',
  'Blood test review',
  'Compression fitting',
];

class _DemoClinic {
  final DateTime now;
  final Random _random = Random(7);

  _DemoClinic(this.now);

  DateTime get _today => DateTime(now.year, now.month, now.day);

  DateTime _at(int daysFromToday, int hour, [int minute = 0]) =>
      _today.add(Duration(days: daysFromToday, hours: hour, minutes: minute));

  _DemoData build() {
    final patients = <PatientModel>[];
    final prescriptions = <PrescriptionModel>[];
    final appointments = <AppointmentModel>[];

    // Who came in today, in the order they were seen.
    const seenToday = {0: 10, 1: 11, 2: 12, 3: 13};
    // Who is booked later today, and when.
    const bookedToday = {4: 16, 5: 17, 6: 18, 7: 19};

    for (var i = 0; i < _people.length; i++) {
      final person = _people[i];
      final plan = _plans[person.plan];
      final id = 'demo-p${(i + 1).toString().padLeft(2, '0')}';

      // Spread first visits over the last ~5 months, a handful this month.
      final firstVisitDaysAgo = i < 4 ? 0 : 3 + _random.nextInt(150);
      final createdAt = i < 4
          ? _at(0, 9, 30)
          : _at(-firstVisitDaysAgo, 9 + _random.nextInt(9));

      // Patients seen today visited today; the rest visited in the past
      // month, the recent-patients list is sorted by this.
      final lastVisitAt = seenToday.containsKey(i)
          ? _at(0, seenToday[i]!, 15)
          : _at(-min(firstVisitDaysAgo, 1 + i ~/ 2), 10 + (i % 8), 30);

      // One or two issued prescriptions per patient, plus older repeats.
      final prescriptionDates = <DateTime>[
        lastVisitAt,
        if (firstVisitDaysAgo > 30) createdAt,
      ];
      for (final date in prescriptionDates) {
        prescriptions.add(
          PrescriptionModel(
            id: 'demo-rx-${prescriptions.length + 1}',
            patientId: id,
            patientName: person.name,
            patientAge: person.age,
            patientGender: person.gender,
            date: date,
            diagnosis: plan.diagnosis,
            drugs: plan.drugs,
            notes: plan.notes,
            status: PrescriptionStatus.generated,
          ),
        );
      }

      // A completed visit on the last visit date keeps the monthly
      // "visits" stat in step with the patient files.
      appointments.add(
        AppointmentModel(
          id: 'demo-ap-${appointments.length + 1}',
          patientId: id,
          patientName: person.name,
          dateTime: lastVisitAt,
          note: _visitNotes[i % _visitNotes.length],
          status: AppointmentStatus.completed,
        ),
      );

      DateTime? nextVisit;
      if (bookedToday.containsKey(i)) {
        nextVisit = _at(0, bookedToday[i]!, i.isEven ? 0 : 30);
      } else if (i % 3 != 2) {
        // Most patients have a follow-up booked over the next two weeks.
        final day = 1 + (i % 13);
        nextVisit = _at(day, 10 + (i % 9), i.isEven ? 0 : 30);
      }
      if (nextVisit != null) {
        appointments.add(
          AppointmentModel(
            id: 'demo-ap-${appointments.length + 1}',
            patientId: id,
            patientName: person.name,
            dateTime: nextVisit,
            note: _visitNotes[(i + 3) % _visitNotes.length],
          ),
        );
      }

      patients.add(
        PatientModel(
          id: id,
          name: person.name,
          age: person.age,
          gender: person.gender,
          phone: person.phone,
          reasonForVisit: person.reason,
          lastVisitAt: lastVisitAt,
          medicalHistory: [
            for (var h = 0; h < person.history.length; h++)
              MedicalHistoryEntryModel(
                condition: person.history[h],
                date: createdAt.subtract(Duration(days: 365 * (h + 1) + 40)),
              ),
          ],
          currentTreatments: plan.drugs
              .map(
                // Same shape NewPrescriptionCubit writes on issue.
                (d) => TreatmentItemModel(
                  drugName: '${d.drugName} ${d.dose}',
                  frequency: d.frequency,
                  notes: d.notes,
                ),
              )
              .toList(),
          nextVisit: nextVisit == null
              ? null
              : NextVisitModel(dateTime: nextVisit, reminderSet: true),
          createdAt: createdAt,
        ),
      );
    }

    // A couple of unfinished drafts to show the draft workflow.
    for (final i in [8, 15]) {
      final person = _people[i];
      prescriptions.add(
        PrescriptionModel(
          id: 'demo-rx-draft-$i',
          patientId: 'demo-p${(i + 1).toString().padLeft(2, '0')}',
          patientName: person.name,
          patientAge: person.age,
          patientGender: person.gender,
          date: _at(0, 9, 45),
          diagnosis: _plans[person.plan].diagnosis,
          drugs: _plans[person.plan].drugs.take(1).toList(),
          status: PrescriptionStatus.draft,
        ),
      );
    }

    // One cancelled booking so the status styles all show up.
    appointments.add(
      AppointmentModel(
        id: 'demo-ap-cancelled',
        patientId: 'demo-p20',
        patientName: _people[19].name,
        dateTime: _at(0, 15),
        note: 'Patient called to reschedule',
        status: AppointmentStatus.cancelled,
      ),
    );

    patients.sort((a, b) => b.lastVisitAt.compareTo(a.lastVisitAt));
    return _DemoData(patients, prescriptions, appointments);
  }
}
