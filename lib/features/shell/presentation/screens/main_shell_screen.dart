import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/injection/injection_container.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:my_clinic/features/appointments/presentation/screens/appointments_screen.dart';
import 'package:my_clinic/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_clinic/features/home/presentation/screens/home_screen.dart';
import 'package:my_clinic/features/patients/presentation/cubit/patients_cubit.dart';
import 'package:my_clinic/features/patients/presentation/screens/patients_list_screen.dart';
import 'package:my_clinic/features/settings/presentation/screens/settings_screen.dart';

import '../widgets/main_bottom_nav_bar.dart';

/// Plain [StatefulWidget] — the active tab index has no async/error state,
/// so it doesn't need a Cubit of its own.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _goToPatientsTab() {
    setState(() => _currentIndex = 1);
  }

  void _goToAppointmentsTab() {
    setState(() => _currentIndex = 3);
  }

  void _onTap(int index) {
    if (index == 2) {
      context.pushNamed(Routes.newPrescription);
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      BlocProvider(
        create: (_) => getIt<HomeCubit>(),
        child: HomeScreen(
          onNavigateToPatients: _goToPatientsTab,
          onNavigateToAppointments: _goToAppointmentsTab,
        ),
      ),
      BlocProvider(
        create: (_) => getIt<PatientsCubit>(),
        child: const PatientsListScreen(),
      ),
      const SizedBox.shrink(), // Prescription tab pushes a route instead.
      BlocProvider(
        create: (_) => getIt<AppointmentsCubit>(),
        child: const AppointmentsScreen(),
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
