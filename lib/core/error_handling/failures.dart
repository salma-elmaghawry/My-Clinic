import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

// Auth Failures

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({required super.message});
}

class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure({required super.message});
}

class EmailNotConfirmedFailure extends Failure {
  const EmailNotConfirmedFailure({required super.message});
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure({required super.message});
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure({required super.message});
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure({required super.message});
}

class SamePasswordFailure extends Failure {
  const SamePasswordFailure({required super.message});
}

// Network failures

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// Server failures

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// Unexpected failures

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}

// Not-found failures

class PatientNotFoundFailure extends Failure {
  const PatientNotFoundFailure({required super.message});
}

class DrugNotFoundFailure extends Failure {
  const DrugNotFoundFailure({required super.message});
}
