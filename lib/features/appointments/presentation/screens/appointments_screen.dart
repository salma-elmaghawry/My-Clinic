import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dr_ahmed/core/widgets/coming_soon_view.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('nav.appointments'.tr())),
      body: const ComingSoonView(
        titleKey: 'common.coming_soon.title',
        icon: Icons.event_note_outlined,
      ),
    );
  }
}
