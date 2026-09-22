import 'package:dr_ahmed/core/error_handling/exceptions.dart';
import 'package:dr_ahmed/features/patients/data/models/medical_history_entry_model.dart';
import 'package:dr_ahmed/features/patients/data/models/next_visit_model.dart';
import 'package:dr_ahmed/features/patients/data/models/patient_model.dart';
import 'package:dr_ahmed/features/patients/data/models/treatment_item_model.dart';
import 'package:dr_ahmed/features/patients/domain/entities/gender.dart';

import 'patients_local_datasource.dart';

class PatientsLocalDataSourceImpl implements PatientsLocalDataSource {
  // Session-only in-memory seed. Resets on app restart — acceptable for
  // this pass; a future Supabase datasource is a drop-in swap for this file.
  static final List<PatientModel> _patients = _seedPatients();

  @override
  Future<List<PatientModel>> getPatients() async {
    return List.unmodifiable(_patients);
  }

  @override
  Future<List<PatientModel>> searchPatients(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return List.unmodifiable(_patients);
    return _patients
        .where((p) => p.name.toLowerCase().contains(normalized))
        .toList();
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (_) {
      throw const PatientNotFoundException();
    }
  }

  @override
  Future<List<PatientModel>> getRecentPatients({int limit = 5}) async {
    final sorted = List<PatientModel>.from(_patients)
      ..sort((a, b) => b.lastVisitAt.compareTo(a.lastVisitAt));
    return sorted.take(limit).toList();
  }

  static List<PatientModel> _seedPatients() {
    final now = DateTime.now();
    return [
      PatientModel(
        id: 'p1',
        name: 'Mahmoud El-Sayed',
        age: 58,
        gender: Gender.male,
        phone: '+20 100 123 4567',
        reasonForVisit: 'Chronic venous insufficiency follow-up',
        lastVisitAt: now.subtract(const Duration(days: 2)),
        medicalHistory: [
          MedicalHistoryEntryModel(
            condition: 'Deep vein thrombosis (right leg)',
            date: now.subtract(const Duration(days: 400)),
          ),
          MedicalHistoryEntryModel(
            condition: 'Type 2 diabetes',
            date: now.subtract(const Duration(days: 900)),
          ),
        ],
        currentTreatments: [
          const TreatmentItemModel(
            drugName: 'Xarelto (Rivaroxaban) 20mg',
            frequency: 'Once daily',
          ),
          const TreatmentItemModel(
            drugName: 'Detralex 500mg',
            frequency: 'Twice daily',
            notes: 'With meals',
          ),
        ],
        nextVisit: NextVisitModel(
          dateTime: now.add(const Duration(days: 14)),
          reminderSet: true,
        ),
        createdAt: now.subtract(const Duration(days: 900)),
      ),
      PatientModel(
        id: 'p2',
        name: 'Fatma Abdel Rahman',
        age: 45,
        gender: Gender.female,
        phone: '+20 101 234 5678',
        reasonForVisit: 'Varicose veins consultation',
        lastVisitAt: now.subtract(const Duration(days: 5)),
        medicalHistory: [
          MedicalHistoryEntryModel(
            condition: 'Varicose veins (bilateral)',
            date: now.subtract(const Duration(days: 200)),
          ),
        ],
        currentTreatments: [
          const TreatmentItemModel(
            drugName: 'Vessel Due F (Sulodexide)',
            frequency: 'Once daily',
          ),
          const TreatmentItemModel(
            drugName: 'Compression Stockings (Class II)',
            frequency: 'Daily wear',
          ),
        ],
        nextVisit: NextVisitModel(
          dateTime: now.add(const Duration(days: 30)),
          reminderSet: false,
        ),
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      PatientModel(
        id: 'p3',
        name: 'Youssef Ibrahim',
        age: 67,
        gender: Gender.male,
        phone: '+20 102 345 6789',
        reasonForVisit: 'Diabetic foot ulcer dressing change',
        lastVisitAt: now.subtract(const Duration(days: 1)),
        medicalHistory: [
          MedicalHistoryEntryModel(
            condition: 'Type 2 diabetes',
            date: now.subtract(const Duration(days: 1500)),
          ),
          MedicalHistoryEntryModel(
            condition: 'Peripheral arterial disease',
            date: now.subtract(const Duration(days: 600)),
          ),
          MedicalHistoryEntryModel(
            condition: 'Hypertension',
            date: now.subtract(const Duration(days: 1200)),
          ),
        ],
        currentTreatments: [
          const TreatmentItemModel(
            drugName: 'Silver Sulfadiazine Cream',
            frequency: 'Once daily',
            notes: 'Apply to wound, cover with dressing',
          ),
          const TreatmentItemModel(
            drugName: 'Pentoxifylline 400mg',
            frequency: 'Three times daily',
          ),
        ],
        nextVisit: NextVisitModel(
          dateTime: now.add(const Duration(days: 3)),
          reminderSet: true,
        ),
        createdAt: now.subtract(const Duration(days: 1500)),
      ),
      PatientModel(
        id: 'p4',
        name: 'Mona Hassan',
        age: 39,
        gender: Gender.female,
        phone: '+20 103 456 7890',
        reasonForVisit: 'Post-op DVT prophylaxis review',
        lastVisitAt: now.subtract(const Duration(days: 10)),
        medicalHistory: [
          MedicalHistoryEntryModel(
            condition: 'Recent knee replacement surgery',
            date: now.subtract(const Duration(days: 45)),
          ),
        ],
        currentTreatments: [
          const TreatmentItemModel(
            drugName: 'Clexane (Enoxaparin) 40mg',
            frequency: 'Once daily (subcutaneous)',
          ),
        ],
        nextVisit: NextVisitModel(
          dateTime: now.add(const Duration(days: 7)),
          reminderSet: true,
        ),
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      PatientModel(
        id: 'p5',
        name: 'Ahmed Farouk',
        age: 72,
        gender: Gender.male,
        phone: '+20 104 567 8901',
        reasonForVisit: 'Peripheral arterial disease follow-up',
        lastVisitAt: now.subtract(const Duration(days: 20)),
        medicalHistory: [
          MedicalHistoryEntryModel(
            condition: 'Peripheral arterial disease',
            date: now.subtract(const Duration(days: 800)),
          ),
          MedicalHistoryEntryModel(
            condition: 'Coronary artery disease',
            date: now.subtract(const Duration(days: 2000)),
          ),
        ],
        currentTreatments: [
          const TreatmentItemModel(
            drugName: 'Cilostazol 100mg',
            frequency: 'Twice daily',
          ),
          const TreatmentItemModel(
            drugName: 'Aspirin 81mg',
            frequency: 'Once daily',
          ),
        ],
        nextVisit: null,
        createdAt: now.subtract(const Duration(days: 2000)),
      ),
      PatientModel(
        id: 'p6',
        name: 'Nadia Kamal',
        age: 51,
        gender: Gender.female,
        phone: '+20 105 678 9012',
        reasonForVisit: 'Leg swelling and skin changes',
        lastVisitAt: now.subtract(const Duration(days: 3)),
        medicalHistory: [
          MedicalHistoryEntryModel(
            condition: 'Chronic venous insufficiency',
            date: now.subtract(const Duration(days: 300)),
          ),
        ],
        currentTreatments: [
          const TreatmentItemModel(
            drugName: 'Elastic Crepe Bandage',
            frequency: 'Daily wear',
          ),
          const TreatmentItemModel(
            drugName: 'Detralex 500mg',
            frequency: 'Twice daily',
          ),
        ],
        nextVisit: NextVisitModel(
          dateTime: now.add(const Duration(days: 21)),
          reminderSet: false,
        ),
        createdAt: now.subtract(const Duration(days: 300)),
      ),
      PatientModel(
        id: 'p7',
        name: 'Karim Adel',
        age: 34,
        gender: Gender.male,
        phone: '+20 106 789 0123',
        reasonForVisit: 'Superficial wound infection',
        lastVisitAt: now.subtract(const Duration(days: 7)),
        medicalHistory: [
          MedicalHistoryEntryModel(
            condition: 'Minor leg trauma',
            date: now.subtract(const Duration(days: 14)),
          ),
        ],
        currentTreatments: [
          const TreatmentItemModel(
            drugName: 'Augmentin 1g',
            frequency: 'Twice daily',
            notes: 'Complete full 7-day course',
          ),
          const TreatmentItemModel(
            drugName: 'Voltaren 50mg',
            frequency: 'Twice daily',
          ),
        ],
        nextVisit: NextVisitModel(
          dateTime: now.add(const Duration(days: 5)),
          reminderSet: true,
        ),
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      PatientModel(
        id: 'p8',
        name: 'Salma Tarek',
        age: 62,
        gender: Gender.female,
        phone: '+20 107 890 1234',
        reasonForVisit: 'Atrial fibrillation anticoagulation review',
        lastVisitAt: now.subtract(const Duration(days: 15)),
        medicalHistory: [
          MedicalHistoryEntryModel(
            condition: 'Atrial fibrillation',
            date: now.subtract(const Duration(days: 500)),
          ),
          MedicalHistoryEntryModel(
            condition: 'Hypertension',
            date: now.subtract(const Duration(days: 1100)),
          ),
        ],
        currentTreatments: [
          const TreatmentItemModel(
            drugName: 'Eliquis (Apixaban) 5mg',
            frequency: 'Twice daily',
          ),
        ],
        nextVisit: NextVisitModel(
          dateTime: now.add(const Duration(days: 45)),
          reminderSet: false,
        ),
        createdAt: now.subtract(const Duration(days: 1100)),
      ),
    ];
  }
}
