import 'package:speech_to_text/speech_to_text.dart';

/// Thin wrapper around on-device speech recognition (no network call, no
/// API key, works fully offline once the OS language pack is installed).
/// This is deliberately the first, self-contained increment of what the
/// app's flagship AI feature grows into: today it turns speech into text
/// for a single field; a later pass can point the same transcript at an
/// LLM to produce a full structured visit note instead of raw text.
class DictationService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;

  Future<bool> _ensureInitialized() async {
    if (_available) return true;
    _available = await _speech.initialize();
    return _available;
  }

  bool get isListening => _speech.isListening;

  /// Starts listening and streams recognized text (interim + final) to
  /// [onResult]. Returns false if the microphone/speech permission wasn't
  /// granted or no recognizer is available on this device.
  Future<bool> startListening({
    required void Function(String recognizedText, bool isFinal) onResult,
    String? localeId,
  }) async {
    final ready = await _ensureInitialized();
    if (!ready) return false;

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(partialResults: true, localeId: localeId),
    );
    return true;
  }

  Future<void> stopListening() => _speech.stop();
}
