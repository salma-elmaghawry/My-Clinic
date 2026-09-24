import 'package:my_clinic/features/auth/data/models/auth_user_model.dart';
import 'package:my_clinic/features/auth/domain/entities/sign_up_outcome.dart';

abstract class AuthRemoteDataSource {
  AuthUserModel? get currentUser;

  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  });

  Future<SignUpOutcome> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthUserModel> verifySignUpCode({
    required String email,
    required String code,
  });

  Future<void> resendSignUpCode(String email);

  Future<void> sendPasswordResetCode(String email);

  Future<AuthUserModel> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> signOut();
}
