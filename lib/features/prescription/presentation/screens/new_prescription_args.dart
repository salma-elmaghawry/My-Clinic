import 'package:equatable/equatable.dart';
import 'package:my_clinic/features/patients/domain/entities/gender.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';

/// Route arguments for [Routes.newPrescription]. Pushed pre-filled from
/// Patient Detail's "New Prescription" button, or left null when navigated
/// from Home's global CTA — in which case the screen shows a lightweight
/// patient picker instead. Also doubles as the in-cubit representation of
/// the currently selected patient once chosen from that picker.
///
/// When [draft] is set, the editor reopens that saved draft instead of
/// starting a blank prescription.
class NewPrescriptionArgs extends Equatable {
  final String patientId;
  final String patientName;
  final int patientAge;
  final Gender patientGender;
  final Prescription? draft;

  const NewPrescriptionArgs({
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    this.draft,
  });

  factory NewPrescriptionArgs.fromDraft(Prescription draft) {
    return NewPrescriptionArgs(
      patientId: draft.patientId,
      patientName: draft.patientName,
      patientAge: draft.patientAge,
      patientGender: draft.patientGender,
      draft: draft,
    );
  }

  @override
  List<Object?> get props => [
    patientId,
    patientName,
    patientAge,
    patientGender,
    draft,
  ];
}
