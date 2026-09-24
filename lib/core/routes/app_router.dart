import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/injection/injection_container.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointment_form_cubit.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:my_clinic/features/appointments/presentation/screens/appointment_form_args.dart';
import 'package:my_clinic/features/appointments/presentation/screens/appointment_form_screen.dart';
import 'package:my_clinic/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:my_clinic/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:my_clinic/features/auth/presentation/screens/login_screen.dart';
import 'package:my_clinic/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:my_clinic/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:my_clinic/features/drug_database/presentation/cubit/drug_database_cubit.dart';
import 'package:my_clinic/features/drug_database/presentation/screens/drug_database_screen.dart';
import 'package:my_clinic/features/patients/domain/entities/patient.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_detail_cubit.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_form_cubit.dart';
import 'package:my_clinic/features/patients/presentation/screens/patient_form_screen.dart';
import 'package:my_clinic/features/patients/presentation/screens/patient_detail_screen.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:my_clinic/features/prescription/presentation/cubit/new_prescription_cubit.dart';
import 'package:my_clinic/features/prescription/presentation/screens/new_prescription_args.dart';
import 'package:my_clinic/features/prescription/presentation/screens/new_prescription_screen.dart';
import 'package:my_clinic/features/prescription/presentation/screens/prescription_preview_screen.dart';
import 'package:my_clinic/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:my_clinic/features/shell/presentation/screens/main_shell_screen.dart';
import 'package:my_clinic/features/splash/presentation/screens/splash_screen.dart';
import 'package:my_clinic/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:my_clinic/features/stats/presentation/screens/stats_screen.dart';

class AppRouter {
  // Nullable on purpose: returning null for an unmatched route name lets
  // MaterialApp.onUnknownRoute be the single real "page not found" handler
  // instead of this switch showing a raw, unstyled fallback screen itself.
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => _withAuthCubit(const SplashScreen()),
        );

      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => _withAuthCubit(const LoginScreen()),
        );

      case Routes.signUp:
        return MaterialPageRoute(
          builder: (_) => _withAuthCubit(const SignUpScreen()),
        );

      case Routes.verifyEmail:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => _withAuthCubit(VerifyEmailScreen(email: email)),
        );

      case Routes.forgotPassword:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) =>
              _withAuthCubit(ForgotPasswordScreen(initialEmail: email)),
        );

      case Routes.main:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());

      case Routes.patientDetail:
        final patientId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<PatientDetailCubit>(
                create: (_) => getIt<PatientDetailCubit>(),
              ),
              // Backs the appointment actions on the patient's Visits tab.
              BlocProvider<AppointmentsCubit>(
                create: (_) => getIt<AppointmentsCubit>(),
              ),
            ],
            child: PatientDetailScreen(patientId: patientId),
          ),
        );

      case Routes.patientForm:
        final patient = settings.arguments as Patient?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PatientFormCubit>(
            create: (_) => getIt<PatientFormCubit>(),
            child: PatientFormScreen(patient: patient),
          ),
        );

      case Routes.appointmentForm:
        final args =
            settings.arguments as AppointmentFormArgs? ??
            const AppointmentFormArgs();
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AppointmentFormCubit>(
            create: (_) => getIt<AppointmentFormCubit>(),
            child: AppointmentFormScreen(args: args),
          ),
        );

      case Routes.drugDatabase:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<DrugDatabaseCubit>(
            create: (_) => getIt<DrugDatabaseCubit>(),
            child: const DrugDatabaseScreen(),
          ),
        );

      case Routes.stats:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<StatsCubit>(
            create: (_) => getIt<StatsCubit>(),
            child: const StatsScreen(),
          ),
        );

      case Routes.newPrescription:
        final args = settings.arguments as NewPrescriptionArgs?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<NewPrescriptionCubit>(
            create: (_) => getIt<NewPrescriptionCubit>()..init(args),
            child: const NewPrescriptionScreen(),
          ),
        );

      case Routes.prescriptionPreview:
        final prescription = settings.arguments as Prescription;
        return MaterialPageRoute(
          builder: (_) => PrescriptionPreviewScreen(prescription: prescription),
        );

      case Routes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      default:
        return null;
    }
  }

  Widget _withAuthCubit(Widget screen) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: screen,
    );
  }
}
