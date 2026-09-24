import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/auth/domain/entities/auth_user.dart';
import 'package:my_clinic/features/auth/domain/entities/sign_up_outcome.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;

  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, SignUpOutcome>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser>> verifySignUpCode({
    required String email,
    required String code,
  });

  Future<Either<Failure, Unit>> resendSignUpCode(String email);

  Future<Either<Failure, Unit>> sendPasswordResetCode(String email);

  Future<Either<Failure, AuthUser>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<Either<Failure, Unit>> signOut();
}
