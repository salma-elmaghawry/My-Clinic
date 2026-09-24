import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/utils/app_text_styles.dart';

class AuthSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final int errorCount;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.errorCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final button = AnimatedButton(
      isLoading: isLoading,
      onPressed: onPressed,
      height: 52.h,
      borderRadius: BorderRadius.circular(12.r),
      backgroundColor: colorScheme.primary,
      loadingColor: colorScheme.onPrimary,
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.font14SemiBold.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
    return KeyedSubtree(
      key: ValueKey(errorCount),
      child: errorCount == 0 ? button : button.shake(),
    );
  }
}
