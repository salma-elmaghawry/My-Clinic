import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // `.tr()` alone doesn't subscribe this widget to locale changes, so read
    // the locale here to rebuild the labels as soon as the language switches.
    context.locale;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: 'nav.home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people_alt_outlined),
          activeIcon: const Icon(Icons.people_alt),
          label: 'nav.patients'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.add_circle_outline),
          activeIcon: const Icon(Icons.add_circle),
          label: 'nav.prescription'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.event_note_outlined),
          activeIcon: const Icon(Icons.event_note),
          label: 'nav.appointments'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: 'nav.settings'.tr(),
        ),
      ],
    );
  }
}
