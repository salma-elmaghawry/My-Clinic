import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dr_ahmed/core/injection/injection_container.dart';
import 'package:dr_ahmed/core/routes/routes.dart';
import 'package:dr_ahmed/features/patients/presentation/cubit/patient_detail_cubit.dart';
import 'package:dr_ahmed/features/patients/presentation/screens/patient_detail_screen.dart';
import 'package:dr_ahmed/features/prescription/domain/entities/prescription.dart';
import 'package:dr_ahmed/features/prescription/presentation/cubit/new_prescription_cubit.dart';
import 'package:dr_ahmed/features/prescription/presentation/screens/new_prescription_args.dart';
import 'package:dr_ahmed/features/prescription/presentation/screens/new_prescription_screen.dart';
import 'package:dr_ahmed/features/prescription/presentation/screens/prescription_preview_screen.dart';
import 'package:dr_ahmed/features/shell/presentation/screens/main_shell_screen.dart';
import 'package:dr_ahmed/features/splash/presentation/screens/splash_screen.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
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

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
