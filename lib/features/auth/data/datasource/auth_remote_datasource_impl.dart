import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_clinic/core/error_handling/exceptions.dart';
import 'package:my_clinic/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:my_clinic/features/auth/data/models/auth_user_model.dart';
import 'package:my_clinic/features/auth/domain/entities/sign_up_outcome.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl(this._client);

  GoTrueClient get _auth => _client.auth;

  @override
  AuthUserModel? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : AuthUserModel.fromSupabaseUser(user);
  }

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return _requireUser(response.user);
  }

  @override
  Future<SignUpOutcome> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim()},
    );
    _requireUser(response.user);
    final identities = response.user?.identities;
    if (identities != null && identities.isEmpty) {
      throw const EmailAlreadyInUseException();
    }
    return response.session != null
        ? SignUpOutcome.signedIn
        : SignUpOutcome.needsEmailVerification;
  }

  @override
  Future<AuthUserModel> verifySignUpCode({
    required String email,
    required String code,
  }) async {
    final response = await _auth.verifyOTP(
      email: email.trim(),
      token: code.trim(),
      type: OtpType.signup,
    );
    return _requireUser(response.user);
  }

  @override
  Future<void> resendSignUpCode(String email) async {
    await _auth.resend(email: email.trim(), type: OtpType.signup);
  }

  @override
  Future<void> sendPasswordResetCode(String email) async {
    await _auth.resetPasswordForEmail(email.trim());
  }

  @override
  Future<AuthUserModel> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _auth.verifyOTP(
      email: email.trim(),
      token: code.trim(),
      type: OtpType.recovery,
    );
    final response = await _auth.updateUser(
      UserAttributes(password: newPassword),
    );
    return _requireUser(response.user);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AuthUserModel _requireUser(User? user) {
    if (user == null) throw const AuthException('No user returned');
    return AuthUserModel.fromSupabaseUser(user);
  }
}
