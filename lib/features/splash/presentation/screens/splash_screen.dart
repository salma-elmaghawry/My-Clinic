import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        context.pushReplacementNamed(Routes.main);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoAssetPath = context.watch<DoctorProfileCubit>().state.profile.logoAssetPath;
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.asset(
                logoAssetPath,
                width: 120.w,
                height: 120.w,
                fit: BoxFit.cover,
              ),
            ).fadeInScale(),
            verticalSpace(20),
            Text(
              'app_name'.tr(),
              style: theme.textTheme.displayMedium?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ).fadeInSlideUp(delay: 200.ms),
          ],
        ),
      ),
    );
  }
}
