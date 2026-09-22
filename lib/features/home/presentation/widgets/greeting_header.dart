import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/features/profile/presentation/cubit/doctor_profile_cubit.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = context.watch<DoctorProfileCubit>().state;

    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () => Navigator.of(context).pushNamed(Routes.editProfile),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Image.asset(
              profileState.profile.logoAssetPath,
              width: 52.w,
              height: 52.w,
              fit: BoxFit.cover,
            ),
          ),
          horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home.greeting'.tr(args: [profileState.displayName]),
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.start,
                ),
                Text(
                  profileState.displaySpecialty,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
