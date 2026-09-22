import 'package:dr_ahmed/features/prescription/data/models/prescription_model.dart';
import 'package:dr_ahmed/features/prescription/domain/entities/prescription_status.dart';

import 'prescriptions_local_datasource.dart';

class PrescriptionsLocalDataSourceImpl implements PrescriptionsLocalDataSource {
  // Session-only in-memory list; resets on app restart. Not reconciled back
  // into a patient's currentTreatments — flagged as a follow-up for the
  // backend pass (see plan's "Explicitly deferred" section).
  static final List<PrescriptionModel> _prescriptions = [];

  @override
  Future<PrescriptionModel> saveDraft(PrescriptionModel prescription) async {
    final draft = PrescriptionModel(
      id: prescription.id,
      patientId: prescription.patientId,
      patientName: prescription.patientName,
      patientAge: prescription.patientAge,
      patientGender: prescription.patientGender,
      date: prescription.date,
      diagnosis: prescription.diagnosis,
      drugs: prescription.drugs,
      notes: prescription.notes,
      status: PrescriptionStatus.draft,
    );
    _prescriptions.add(draft);
    return draft;
  }

  @override
  Future<PrescriptionModel> generate(PrescriptionModel prescription) async {
    final generated = PrescriptionModel(
      id: prescription.id,
      patientId: prescription.patientId,
      patientName: prescription.patientName,
      patientAge: prescription.patientAge,
      patientGender: prescription.patientGender,
      date: prescription.date,
      diagnosis: prescription.diagnosis,
      drugs: prescription.drugs,
      notes: prescription.notes,
      status: PrescriptionStatus.generated,
    );
    _prescriptions.add(generated);
    return generated;
  }
}
