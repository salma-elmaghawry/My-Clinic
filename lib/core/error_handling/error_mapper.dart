import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Maps raw exceptions from any layer into typed, localized [Failure]s.
/// Every message goes through `.tr()` so the user always sees a localized error.
class ErrorMapper {
  static Failure map(dynamic error) {
    if (error is PatientNotFoundException) {
      return PatientNotFoundFailure(message: 'errors.patient_not_found'.tr());
    }

    if (error is DrugNotFoundException) {
      return DrugNotFoundFailure(message: 'errors.drug_not_found'.tr());
    }

    if (error is SocketException || error is TimeoutException) {
      return NetworkFailure(message: 'errors.network_error'.tr());
    }

    if (error is HttpException) {
      return ServerFailure(message: 'errors.server_error'.tr());
    }

    if (error is FormatException) {
      return ServerFailure(message: 'errors.server_error'.tr());
    }

    return UnexpectedFailure(message: 'errors.unexpected_error'.tr());
  }
}
