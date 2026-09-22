import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/injection/injection_container.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patient_detail_cubit.dart';
import 'package:my_clinic/features/patients/presentation/screens/patient_detail_screen.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:my_clinic/features/prescription/presentation/cubit/new_prescription_cubit.dart';
import 'package:my_clinic/features/prescription/presentation/screens/new_prescription_args.dart';
import 'package:my_clinic/features/prescription/presentation/screens/new_prescription_screen.dart';
import 'package:my_clinic/features/prescription/presentation/screens/prescription_preview_screen.dart';
import 'package:my_clinic/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:my_clinic/features/shell/presentation/screens/main_shell_screen.dart';
import 'package:my_clinic/features/splash/presentation/screens/splash_screen.dart';

class AppRouter {
  // Nullable on purpose: returning null for an unmatched route name lets
  // MaterialApp.onUnknownRoute be the single real "page not found" handler
  // instead of this switch showing a raw, unstyled fallback screen itself.
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.main:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());

      case Routes.patientDetail:
        final patientId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PatientDetailCubit>(
            create: (_) => getIt<PatientDetailCubit>(),
            child: PatientDetailScreen(patientId: patientId),
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
}
