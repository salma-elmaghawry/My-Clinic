import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/services/dictation_service.dart';

/// A mic button that starts/stops on-device dictation and streams the
/// recognized text back through [onTranscript] as the doctor speaks.
/// Self-contained: owns its own [DictationService] instance and listening
/// state, so it can be dropped into any text field without the parent
/// needing to know about speech recognition at all.
class DictationMicButton extends StatefulWidget {
  final ValueChanged<String> onTranscript;
  final String localeId;

  const DictationMicButton({
    super.key,
    required this.onTranscript,
    required this.localeId,
  });

  @override
  State<DictationMicButton> createState() => _DictationMicButtonState();
}

class _DictationMicButtonState extends State<DictationMicButton> {
  final _service = DictationService();
  bool _listening = false;
  bool _unavailable = false;

  Future<void> _toggle() async {
    if (_listening) {
      await _service.stopListening();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final started = await _service.startListening(
      localeId: widget.localeId,
      onResult: (text, isFinal) {
        widget.onTranscript(text);
        if (isFinal && mounted) setState(() => _listening = false);
      },
    );

    if (!mounted) return;
    setState(() {
      _listening = started;
      _unavailable = !started;
    });
  }

  @override
  void dispose() {
    if (_listening) {
      _service.stopListening();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: _toggle,
      icon: Icon(
        _listening ? Icons.mic : Icons.mic_none_outlined,
        color: _listening
            ? theme.colorScheme.error
            : (_unavailable ? theme.disabledColor : theme.colorScheme.primary),
        size: 22.sp,
      ),
    );
  }
}
