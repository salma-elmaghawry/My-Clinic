import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HistoryEntryInput {
  final String condition;
  final DateTime date;

  const HistoryEntryInput(this.condition, this.date);
}

/// Asks for a condition and the date it was diagnosed.
Future<HistoryEntryInput?> showAddHistoryEntryDialog(BuildContext context) {
  return showDialog<HistoryEntryInput>(
    context: context,
    builder: (_) => const _AddHistoryEntryDialog(),
  );
}

class _AddHistoryEntryDialog extends StatefulWidget {
  const _AddHistoryEntryDialog();

  @override
  State<_AddHistoryEntryDialog> createState() => _AddHistoryEntryDialogState();
}

class _AddHistoryEntryDialogState extends State<_AddHistoryEntryDialog> {
  final _controller = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('patients.detail.medical_history.add'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'patients.detail.medical_history.condition_label'.tr(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(
              DateFormat.yMMMd(context.locale.toString()).format(_date),
            ),
            subtitle: Text('patients.detail.medical_history.date_label'.tr()),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
        FilledButton(
          onPressed: () {
            if (_controller.text.trim().isEmpty) return;
            Navigator.of(
              context,
            ).pop(HistoryEntryInput(_controller.text, _date));
          },
          child: Text('common.save'.tr()),
        ),
      ],
    );
  }
}
