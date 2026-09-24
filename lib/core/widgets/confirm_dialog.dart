import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Destructive-action confirmation. Resolves true only if the doctor taps
/// the confirm button.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel ?? 'common.delete'.tr()),
        ),
      ],
    ),
  );
  return result ?? false;
}
