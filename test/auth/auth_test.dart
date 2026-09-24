import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/error_handling/error_mapper.dart';
import 'package:my_clinic/core/error_handling/exceptions.dart';
import 'package:my_clinic/core/error_handling/failures.dart';
import 'package:my_clinic/core/injection/injection_container.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:my_clinic/features/auth/data/models/auth_user_model.dart';
import 'package:my_clinic/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:my_clinic/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:my_clinic/features/auth/presentation/cubit/auth_state.dart';
import 'package:my_clinic/features/auth/presentation/screens/login_screen.dart';
import 'package:my_clinic/features/auth/repository/auth_repository_impl.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class FakeAuthDataSource implements AuthRemoteDataSource {
  static const _user = AuthUserModel(id: 'u1', email: 'doc@clinic.com');

  AuthUserModel? signedInUser;
  Object? nextError;
  SignUpOutcome signUpOutcome = SignUpOutcome.needsEmailVerification;

  Future<T> _respond<T>(T value) async {
    final error = nextError;
    nextError = null;
    if (error != null) throw error;
    return value;
  }

  @override
  AuthUserModel? get currentUser => signedInUser;

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _respond(_user);
    signedInUser = user;
    return user;
  }

  @override
  Future<SignUpOutcome> signUp({
    required String name,
    required String email,
    required String password,
  }) => _respond(signUpOutcome);

  @override
  Future<AuthUserModel> verifySignUpCode({
    required String email,
    required String code,
  }) => _respond(_user);

  @override
  Future<void> resendSignUpCode(String email) => _respond(null);

  @override
  Future<void> sendPasswordResetCode(String email) => _respond(null);

  @override
  Future<AuthUserModel> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _respond(_user);

  @override
  Future<void> signOut() async {
    await _respond(null);
    signedInUser = null;
  }
}

void main() {
  group('ErrorMapper auth branches', () {
    test('maps Supabase auth error codes to typed failures', () {
      expect(
        ErrorMapper.map(
          const supabase.AuthApiException('x', code: 'invalid_credentials'),
        ),
        isA<InvalidCredentialsFailure>(),
      );
      expect(
        ErrorMapper.map(
          const supabase.AuthApiException('x', code: 'email_not_confirmed'),
        ),
        isA<EmailNotConfirmedFailure>(),
      );
      expect(
        ErrorMapper.map(
          const supabase.AuthApiException('x', code: 'otp_expired'),
        ),
        isA<InvalidOtpFailure>(),
      );
      expect(
        ErrorMapper.map(
          const supabase.AuthApiException(
            'x',
            code: 'over_email_send_rate_limit',
          ),
        ),
        isA<TooManyRequestsFailure>(),
      );
      expect(
        ErrorMapper.map(supabase.AuthRetryableFetchException()),
        isA<NetworkFailure>(),
      );
      expect(
        ErrorMapper.map(const EmailAlreadyInUseException()),
        isA<EmailAlreadyInUseFailure>(),
      );
    });
  });

  group('AuthCubit', () {
    late FakeAuthDataSource dataSource;
    late AuthCubit cubit;

    setUp(() {
      dataSource = FakeAuthDataSource();
      cubit = AuthCubit(AuthRepositoryImpl(dataSource));
    });

    tearDown(() => cubit.close());

    test('signIn succeeds and marks the user signed in', () async {
      expect(cubit.isSignedIn, isFalse);
      await cubit.signIn(email: 'doc@clinic.com', password: 'secret123');
      expect(cubit.state.succeeded(AuthAction.signIn), isTrue);
      expect(cubit.isSignedIn, isTrue);
      expect(cubit.currentEmail, 'doc@clinic.com');
    });

    test(
      'signIn failure carries a typed failure, never an exception',
      () async {
        dataSource.nextError = const supabase.AuthApiException(
          'Invalid login credentials',
          code: 'invalid_credentials',
        );
        await cubit.signIn(email: 'doc@clinic.com', password: 'wrong');
        expect(cubit.state.status, Status.failure);
        expect(cubit.state.action, AuthAction.signIn);
        expect(cubit.state.failure, isA<InvalidCredentialsFailure>());
      },
    );

    test('signUp reports whether email verification is needed', () async {
      await cubit.signUp(name: 'Dr. A', email: 'a@b.com', password: '12345678');
      expect(cubit.state.signUpOutcome, SignUpOutcome.needsEmailVerification);

      dataSource.signUpOutcome = SignUpOutcome.signedIn;
      await cubit.signUp(name: 'Dr. A', email: 'a@b.com', password: '12345678');
      expect(cubit.state.signUpOutcome, SignUpOutcome.signedIn);
    });

    test('loading state clears a previous failure message', () async {
      dataSource.nextError = const supabase.AuthApiException('x');
      await cubit.signIn(email: 'a@b.com', password: '123456');
      expect(cubit.state.message, isNotNull);

      final states = <AuthState>[];
      final sub = cubit.stream.listen(states.add);
      await cubit.sendResetCode('a@b.com');
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(states.first.isLoading, isTrue);
      expect(states.first.message, isNull);
      expect(states.last.succeeded(AuthAction.sendResetCode), isTrue);
    });

    test('signOut clears the session', () async {
      await cubit.signIn(email: 'doc@clinic.com', password: 'secret123');
      await cubit.signOut();
      expect(cubit.state.succeeded(AuthAction.signOut), isTrue);
      expect(cubit.isSignedIn, isFalse);
    });
  });

  group('LoginScreen', () {
    Future<FakeAuthDataSource> pumpLogin(
      WidgetTester tester,
      String locale,
    ) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});
      await EasyLocalization.ensureInitialized();
      await getIt.reset();
      await setupInjection();

      final dataSource = FakeAuthDataSource();
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          fallbackLocale: const Locale('en'),
          startLocale: Locale(locale),
          saveLocale: false,
          path: 'assets/translations',
          child: Builder(
            builder: (context) => ScreenUtilInit(
              designSize: const Size(360, 690),
              builder: (_, _) => MaterialApp(
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                routes: {
                  Routes.main: (_) => const Scaffold(body: Text('MAIN')),
                },
                home: MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => getIt<DoctorProfileCubit>()),
                    BlocProvider(
                      create: (_) => AuthCubit(AuthRepositoryImpl(dataSource)),
                    ),
                  ],
                  child: const LoginScreen(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return dataSource;
    }

    testWidgets('validates, shows a localized error, then signs in', (
      tester,
    ) async {
      final dataSource = await pumpLogin(tester, 'en');

      await tester.tap(find.text('Sign in').last);
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'doc@clinic.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');
      dataSource.nextError = const supabase.AuthApiException(
        'Invalid login credentials',
        code: 'invalid_credentials',
      );
      await tester.tap(find.text('Sign in').last);
      await tester.pumpAndSettle();
      expect(find.text('Invalid login credentials'), findsOneWidget);

      await tester.tap(find.text('Sign in').last);
      await tester.pumpAndSettle();
      expect(find.text('MAIN'), findsOneWidget);
    });

    testWidgets('renders in Arabic without layout errors', (tester) async {
      await pumpLogin(tester, 'ar');
      expect(find.text('مرحباً بعودتك'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
