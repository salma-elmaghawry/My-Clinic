import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_clinic/features/home/presentation/cubit/home_state.dart';
import 'package:my_clinic/features/home/presentation/widgets/greeting_header.dart';
import 'package:my_clinic/features/home/presentation/widgets/new_prescription_cta_button.dart';
import 'package:my_clinic/features/home/presentation/widgets/quick_nav_grid.dart';
import 'package:my_clinic/features/home/presentation/widgets/recent_patients_list.dart';
import 'package:my_clinic/features/home/presentation/widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToPatients;

  const HomeScreen({super.key, required this.onNavigateToPatients});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().loadHome(),
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  const GreetingHeader().fadeInSlideUp(),
                  verticalSpace(20),
                  if (state.isLoading && state.recentPatients.isEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedSkeleton(
                            width: double.infinity,
                            height: 100.h,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        horizontalSpace(12),
                        Expanded(
                          child: AnimatedSkeleton(
                            width: double.infinity,
                            height: 100.h,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.people_alt_outlined,
                            value: state.todayPatientsCount,
                            label: 'home.stats.today_patients'.tr(),
                            color: theme.colorScheme.primary,
                          ).fadeInSlideUp(delay: 50.ms),
                        ),
                        horizontalSpace(12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.event_available_outlined,
                            value: state.appointmentsCount,
                            label: 'home.stats.appointments'.tr(),
                            color: theme.colorScheme.secondary,
                          ).fadeInSlideUp(delay: 100.ms),
                        ),
                      ],
                    ),
                  verticalSpace(20),
                  NewPrescriptionCtaButton(
                    onTap: () => context.pushNamed(Routes.newPrescription),
                  ).fadeInSlideUp(delay: 150.ms),
                  verticalSpace(24),
                  Text(
                    'home.quick_nav.title'.tr(),
                    style: theme.textTheme.displaySmall,
                    textAlign: TextAlign.start,
                  ),
                  verticalSpace(12),
                  QuickNavGrid(onPatientRecordsTap: widget.onNavigateToPatients),
                  verticalSpace(24),
                  Text(
                    'home.recent_patients.title'.tr(),
                    style: theme.textTheme.displaySmall,
                    textAlign: TextAlign.start,
                  ),
                  verticalSpace(12),
                  RecentPatientsList(patients: state.recentPatients),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
