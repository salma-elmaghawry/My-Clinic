import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_clinic/core/animations/animations.dart';

class PrescriptionShareButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isBusy;

  const PrescriptionShareButton({
    super.key,
    required this.onPressed,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: 'prescription.preview.share'.tr(),
      child: AnimatedTap(
        onTap: isBusy ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          child: isBusy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Icon(Icons.ios_share, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}
