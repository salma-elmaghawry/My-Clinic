import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:my_clinic/features/auth/presentation/cubit/auth_state.dart';
import 'package:my_clinic/features/auth/repository/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState());

  bool get isSignedIn => _repository.currentUser != null;

  String? get currentEmail => _repository.currentUser?.email;

  Future<void> signIn({required String email, required String password}) {
    return _run(
      AuthAction.signIn,
      () => _repository.signIn(email: email, password: password),
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _run<SignUpOutcome>(
      AuthAction.signUp,
      () => _repository.signUp(name: name, email: email, password: password),
      onSuccess: (outcome) => AuthState(
        status: Status.success,
        action: AuthAction.signUp,
        signUpOutcome: outcome,
      ),
    );
  }

  Future<void> verifyEmail({required String email, required String code}) {
    return _run(
      AuthAction.verifyEmail,
      () => _repository.verifySignUpCode(email: email, code: code),
    );
  }

  Future<void> resendCode(String email) {
    return _run(
      AuthAction.resendCode,
      () => _repository.resendSignUpCode(email),
    );
  }

  Future<void> sendResetCode(String email) {
    return _run(
      AuthAction.sendResetCode,
      () => _repository.sendPasswordResetCode(email),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _run(
      AuthAction.resetPassword,
      () => _repository.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      ),
    );
  }

  Future<void> signOut() => _run(AuthAction.signOut, _repository.signOut);

  Future<void> _run<T>(
    AuthAction action,
    Future<Either<Failure, T>> Function() request, {
    AuthState Function(T value)? onSuccess,
  }) async {
    emit(AuthState(status: Status.loading, action: action));
    final result = await request();
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AuthState(
          status: Status.failure,
          action: action,
          message: failure.message,
          failure: failure,
        ),
        (value) =>
            onSuccess?.call(value) ??
            AuthState(status: Status.success, action: action),
      ),
    );
  }
}
