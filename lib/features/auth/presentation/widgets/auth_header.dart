import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/utils/app_text_styles.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final logoAssetPath = context.select(
      (DoctorProfileCubit cubit) => cubit.state.profile.logoAssetPath,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Image.asset(
            logoAssetPath,
            width: 72.w,
            height: 72.w,
            fit: BoxFit.cover,
          ),
        ).fadeInScale(),
        verticalSpace(20),
        Text(
          title,
          style: AppTextStyles.font24Bold,
        ).fadeInSlideUp(delay: AppAnimations.staggerDelay),
        verticalSpace(6),
        Text(
          subtitle,
          style: AppTextStyles.font14Normal.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ).fadeInSlideUp(delay: AppAnimations.sectionDelay),
      ],
    );
  }
}
