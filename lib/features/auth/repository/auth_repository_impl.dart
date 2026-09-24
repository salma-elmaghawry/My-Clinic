import 'package:dartz/dartz.dart';
import 'package:my_clinic/core/error_handling/error_mapper.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:my_clinic/features/auth/domain/entities/auth_user.dart';
import 'package:my_clinic/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:my_clinic/features/auth/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  AuthUser? get currentUser => _remoteDataSource.currentUser?.toEntity();

  @override
  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, SignUpOutcome>> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _guard(
      () => _remoteDataSource.signUp(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, AuthUser>> verifySignUpCode({
    required String email,
    required String code,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.verifySignUpCode(
        email: email,
        code: code,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> resendSignUpCode(String email) {
    return _guard(() async {
      await _remoteDataSource.resendSignUpCode(email);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetCode(String email) {
    return _guard(() async {
      await _remoteDataSource.sendPasswordResetCode(email);
      return unit;
    });
  }

  @override
  Future<Either<Failure, AuthUser>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> signOut() {
    return _guard(() async {
      await _remoteDataSource.signOut();
      return unit;
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
