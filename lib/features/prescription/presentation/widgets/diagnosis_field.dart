import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/widgets/dictation_mic_button.dart';

/// The diagnosis field also carries the app's voice-dictation entry point
/// (the mic button) — the first increment of the AI ambient-scribe feature:
/// speak the diagnosis instead of typing it. A [TextEditingController] owns
/// the displayed text so both typing and live dictation results can update
/// it the same way, then [onChanged] keeps the cubit's state in sync.
class DiagnosisField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const DiagnosisField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<DiagnosisField> createState() => _DiagnosisFieldState();
}

class _DiagnosisFieldState extends State<DiagnosisField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setText(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final localeId = context.locale.languageCode == 'ar' ? 'ar-EG' : 'en-US';
    return TextFormField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLines: 2,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: 'prescription.new.diagnosis_label'.tr(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        suffixIcon: DictationMicButton(
          localeId: localeId,
          onTranscript: _setText,
        ),
      ),
    );
  }
}
