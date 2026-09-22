import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/theme/app_colors.dart';
import 'package:my_clinic/core/widgets/coming_soon_view.dart';

import 'quick_nav_tile.dart';

class QuickNavGrid extends StatelessWidget {
  final VoidCallback onPatientRecordsTap;

  const QuickNavGrid({super.key, required this.onPatientRecordsTap});

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
        onTap: () => _openComingSoon(
          context,
          'home.quick_nav.appointments',
        ),
      ),
      QuickNavTile(
        icon: Icons.medication_liquid_outlined,
        label: 'home.quick_nav.drug_database'.tr(),
        color: AppColors.third,
        onTap: () => _openComingSoon(
          context,
          'home.quick_nav.drug_database',
        ),
      ),
      QuickNavTile(
        icon: Icons.insights_outlined,
        label: 'home.quick_nav.notes_stats'.tr(),
        color: AppColors.success,
        onTap: () => _openComingSoon(
          context,
          'home.quick_nav.notes_stats',
        ),
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

  void _openComingSoon(BuildContext context, String titleKey) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(titleKey.tr())),
          body: ComingSoonView(titleKey: titleKey),
        ),
      ),
    );
  }
}
