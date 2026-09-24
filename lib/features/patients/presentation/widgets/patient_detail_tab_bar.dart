import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientDetailTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController controller;

  const PatientDetailTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      indicatorColor: theme.colorScheme.primary,
      tabs: [
        Tab(text: 'patients.detail.tabs.medical_history'.tr()),
        Tab(text: 'patients.detail.tabs.current_treatment'.tr()),
        Tab(text: 'patients.detail.tabs.visits'.tr()),
        Tab(text: 'patients.detail.tabs.prescriptions'.tr()),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
