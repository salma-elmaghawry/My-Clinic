import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/theme/app_colors.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/routes/routes.dart';

import 'quick_nav_tile.dart';

class QuickNavGrid extends StatelessWidget {
  final VoidCallback onPatientRecordsTap;
  final VoidCallback onAppointmentsTap;

  const QuickNavGrid({
    super.key,
    required this.onPatientRecordsTap,
    required this.onAppointmentsTap,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      QuickNavTile(
        icon: Icons.folder_shared_outlined,
        label: 'home.quick_nav.patient_records'.tr(),
        color: AppColors.primary,
        onTap: onPatientRecordsTap,
      ),
      QuickNavTile(
        icon: Icons.event_note_outlined,
        label: 'home.quick_nav.appointments'.tr(),
        color: AppColors.secondary,
        onTap: onAppointmentsTap,
      ),
      QuickNavTile(
        icon: Icons.medication_liquid_outlined,
        label: 'home.quick_nav.drug_database'.tr(),
        color: AppColors.third,
        onTap: () => context.pushNamed(Routes.drugDatabase),
      ),
      QuickNavTile(
        icon: Icons.insights_outlined,
        label: 'home.quick_nav.notes_stats'.tr(),
        color: AppColors.success,
        onTap: () => context.pushNamed(Routes.stats),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.5,
      children: AnimationBuilder.staggerColumn(children: tiles),
    );
  }
}
