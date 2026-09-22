import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_clinic/core/animations/animations.dart';

/// Disabled/stub action — no real PDF export/share this pass.
class PrescriptionShareButton extends StatelessWidget {
  const PrescriptionShareButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedTap(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('prescription.preview.share_coming_soon'.tr())),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.ios_share, color: theme.colorScheme.onSurface),
      ),
    );
  }
}
