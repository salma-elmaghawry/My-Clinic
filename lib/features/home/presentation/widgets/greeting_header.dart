import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/constants/doctor_profile.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Image.asset(
            kDoctorProfile.logoAssetPath,
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
                'home.greeting'.tr(args: [kDoctorProfile.name]),
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.start,
              ),
              Text(
                kDoctorProfile.titleKey.tr(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
