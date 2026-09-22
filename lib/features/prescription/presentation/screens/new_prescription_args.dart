import 'package:equatable/equatable.dart';
import 'package:dr_ahmed/features/patients/domain/entities/gender.dart';

/// Route arguments for [Routes.newPrescription]. Pushed pre-filled from
/// Patient Detail's "New Prescription" button, or left null when navigated
/// from Home's global CTA — in which case the screen shows a lightweight
/// patient picker instead. Also doubles as the in-cubit representation of
/// the currently selected patient once chosen from that picker.
class NewPrescriptionArgs extends Equatable {
  final String patientId;
  final String patientName;
  final int patientAge;
  final Gender patientGender;

  const NewPrescriptionArgs({
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
  });

  @override
  List<Object?> get props => [patientId, patientName, patientAge, patientGender];
}
