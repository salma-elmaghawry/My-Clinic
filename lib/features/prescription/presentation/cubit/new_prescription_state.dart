import 'package:dr_ahmed/core/bloc/base_bloc.dart';
import 'package:dr_ahmed/core/error_handling/failures.dart';
import 'package:dr_ahmed/features/patients/domain/entities/patient.dart';
import 'package:dr_ahmed/features/prescription/domain/entities/drug.dart';
import 'package:dr_ahmed/features/prescription/domain/entities/prescription.dart';
import 'package:dr_ahmed/features/prescription/domain/entities/prescription_drug.dart';
import 'package:dr_ahmed/features/prescription/presentation/screens/new_prescription_args.dart';

enum NewPrescriptionAction { searchPatients, searchDrugs, saveDraft, generate }

class NewPrescriptionState extends BaseState {
  final NewPrescriptionArgs? patient;
  final String patientQuery;
  final List<Patient> patientResults;
  final String diagnosis;
  final List<PrescriptionDrug> selectedDrugs;
  final String drugQuery;
  final List<Drug> drugResults;
  final Prescription? generatedPrescription;
  final Failure? failure;
  final NewPrescriptionAction? action;

  const NewPrescriptionState({
    super.status,
    super.message,
    this.patient,
    this.patientQuery = '',
    this.patientResults = const [],
    this.diagnosis = '',
    this.selectedDrugs = const [],
    this.drugQuery = '',
    this.drugResults = const [],
    this.generatedPrescription,
    this.failure,
    this.action,
  });

  NewPrescriptionState copyWith({
    Status? status,
    String? message,
    NewPrescriptionArgs? patient,
    bool clearPatient = false,
    String? patientQuery,
    List<Patient>? patientResults,
    String? diagnosis,
    List<PrescriptionDrug>? selectedDrugs,
    String? drugQuery,
    List<Drug>? drugResults,
    Prescription? generatedPrescription,
    Failure? failure,
    NewPrescriptionAction? action,
  }) {
    return NewPrescriptionState(
      status: status ?? this.status,
      message: message ?? this.message,
      patient: clearPatient ? null : (patient ?? this.patient),
      patientQuery: patientQuery ?? this.patientQuery,
      patientResults: patientResults ?? this.patientResults,
      diagnosis: diagnosis ?? this.diagnosis,
      selectedDrugs: selectedDrugs ?? this.selectedDrugs,
      drugQuery: drugQuery ?? this.drugQuery,
      drugResults: drugResults ?? this.drugResults,
      generatedPrescription: generatedPrescription ?? this.generatedPrescription,
      failure: failure ?? this.failure,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    patient,
    patientQuery,
    patientResults,
    diagnosis,
    selectedDrugs,
    drugQuery,
    drugResults,
    generatedPrescription,
    failure,
    action,
  ];
}
