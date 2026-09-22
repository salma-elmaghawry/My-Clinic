import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/animations/animations.dart';

class NewPrescriptionCtaButton extends StatelessWidget {
  final VoidCallback onTap;

  const NewPrescriptionCtaButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedButton(
      height: 56.h,
      borderRadius: BorderRadius.circular(16.r),
      backgroundColor: theme.colorScheme.secondary,
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_circle_outline, color: Colors.white),
          SizedBox(width: 8.w),
          Text(
            'home.cta'.tr(),
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
