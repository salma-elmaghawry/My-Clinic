/// Raw exceptions thrown by datasources. Repositories catch these and map
/// them into typed [Failure]s via [ErrorMapper] — they never cross the
/// repository boundary.
class PatientNotFoundException implements Exception {
  final String message;
  const PatientNotFoundException([this.message = 'Patient not found']);
}

class DrugNotFoundException implements Exception {
  final String message;
  const DrugNotFoundException([this.message = 'Drug not found']);
}
