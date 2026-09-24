import 'package:flutter/material.dart';
import 'package:my_clinic/core/utils/app_text_styles.dart';

class AuthSwitchPrompt extends StatelessWidget {
  final String prompt;
  final String actionLabel;
  final VoidCallback? onPressed;

  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: AppTextStyles.font14Normal.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            actionLabel,
            style: AppTextStyles.font14SemiBold.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
