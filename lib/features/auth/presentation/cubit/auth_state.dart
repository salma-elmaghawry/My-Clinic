import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/auth/domain/entities/sign_up_outcome.dart';

enum AuthAction {
  signIn,
  signUp,
  verifyEmail,
  resendCode,
  sendResetCode,
  resetPassword,
  signOut,
}

class AuthState extends BaseState {
  final AuthAction? action;
  final Failure? failure;
  final SignUpOutcome? signUpOutcome;

  const AuthState({
    super.status = Status.initial,
    super.message,
    this.action,
    this.failure,
    this.signUpOutcome,
  });

  bool isLoadingFor(AuthAction target) => isLoading && action == target;

  bool succeeded(AuthAction target) => isSuccess && action == target;

  @override
  List<Object?> get props => [status, message, action, failure, signUpOutcome];
}
