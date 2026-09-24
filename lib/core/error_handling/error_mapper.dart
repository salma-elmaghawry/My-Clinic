import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

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

    if (error is EmailAlreadyInUseException) {
      return EmailAlreadyInUseFailure(message: 'auth.errors.email_in_use'.tr());
    }

    if (error is supabase.AuthException) {
      return _mapAuthException(error);
    }

    if (error is supabase.PostgrestException) {
      return ServerFailure(message: 'errors.server_error'.tr());
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

  static Failure _mapAuthException(supabase.AuthException error) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    if (error is supabase.AuthRetryableFetchException ||
        message.contains('network') ||
        message.contains('failed host lookup')) {
      return NetworkFailure(message: 'errors.network_error'.tr());
    }
    if (error is supabase.AuthWeakPasswordException ||
        code == 'weak_password') {
      return WeakPasswordFailure(message: 'auth.errors.weak_password'.tr());
    }
    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return InvalidCredentialsFailure(
        message: 'auth.errors.invalid_credentials'.tr(),
      );
    }
    if (code == 'email_exists' ||
        code == 'user_already_exists' ||
        message.contains('already registered')) {
      return EmailAlreadyInUseFailure(message: 'auth.errors.email_in_use'.tr());
    }
    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return EmailNotConfirmedFailure(
        message: 'auth.errors.email_not_confirmed'.tr(),
      );
    }
    if (code == 'otp_expired' ||
        code == 'otp_disabled' ||
        message.contains('token has expired') ||
        message.contains('invalid token')) {
      return InvalidOtpFailure(message: 'auth.errors.invalid_otp'.tr());
    }
    if (code == 'same_password') {
      return SamePasswordFailure(message: 'auth.errors.same_password'.tr());
    }
    if (code.startsWith('over_') || message.contains('rate limit')) {
      return TooManyRequestsFailure(
        message: 'auth.errors.rate_limit_exceeded'.tr(),
      );
    }
    return UnexpectedFailure(message: 'errors.unexpected_error'.tr());
  }
}
