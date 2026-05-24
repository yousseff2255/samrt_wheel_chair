import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  // Prevents the same session from firing a command more than once
  bool _commandFired = false;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;

  // ── Init ────────────────────────────────────────────────────────────────

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('VoiceService error: ${error.errorMsg}'),
      onStatus: (status) => debugPrint('VoiceService status: $status'),
    );
    return _isInitialized;
  }

  // ── Start listening ──────────────────────────────────────────────────────
  //
  // Behavior changes from v1:
  //  - Auto-stops the moment a valid command is recognized
  //  - Dual path: fast (high-confidence partial) + normal (final result)
  //  - Ignores low-confidence results entirely
  //  - _commandFired flag prevents duplicate firings in one session
  //
  Future<void> startListening({
    required void Function(String command) onCommand,
    void Function(String text)? onTranscript,
  }) async {
    if (!_isInitialized || _speech.isListening) return;

    _commandFired = false; // reset for new session

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        if (_commandFired) return; // already handled this session

        final rawText = result.recognizedWords;
        final normalized = _normalize(rawText);

        // Always update the live transcript in the UI
        onTranscript?.call(rawText);

        // Confidence: use 1.0 as default when not rated (avoids false rejects)
        final confidence = result.hasConfidenceRating ? result.confidence : 1.0;

        // ── Fast path: high-confidence partial result ──────────────────────
        // Fires before the user finishes speaking for snappier response.
        if (!result.finalResult && confidence >= 0.85) {
          final command = _parseCommand(normalized);
          if (command != null) {
            _commandFired = true;
            onCommand(command);
            stopListening(); // auto-stop
            return;
          }
        }

        // ── Normal path: final result ──────────────────────────────────────
        // Lower threshold acceptable because STT engine has committed.
        if (result.finalResult && confidence >= 0.5) {
          final command = _parseCommand(normalized);
          if (command != null) {
            _commandFired = true;
            onCommand(command);
            stopListening(); // auto-stop
          }
          // If no valid command found on final result → session ends naturally,
          // the caller's _isListening flag is updated via the returned future.
        }
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 10), // max recording window
        pauseFor: const Duration(seconds: 3), // silence timeout
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  // ── Stop ────────────────────────────────────────────────────────────────

  Future<void> stopListening() async {
    if (_speech.isListening) await _speech.stop();
  }

  void dispose() {
    _speech.cancel();
  }

  // ── Text normalization ───────────────────────────────────────────────────
  //
  // Lowercases, trims, removes punctuation (keeps Arabic Unicode range).
  // This prevents "Forward!" or "forward," from failing to match.
  //
  static String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r"[^\w\s\u0600-\u06FF]"), '');
  }

  // ── Command keywords (English + Arabic) ─────────────────────────────────

  static const Map<String, List<String>> _commandKeywords = {
    'forward': [
      'forward',
      'go',
      'ahead',
      'move',
      'advance',
      'أمام',
      'للأمام',
      'قدام',
      'امشي',
      'تقدم',
      'روح',
    ],
    'backward': [
      'backward',
      'back',
      'reverse',
      'retreat',
      'خلف',
      'للخلف',
      'ورا',
      'وراء',
      'تراجع',
      'ارجع',
    ],
    'left': [
      'left',
      'يسار',
      'لليسار',
      'شمال',
    ],
    'right': [
      'right',
      'يمين',
      'لليمين',
    ],
    'stop': [
      'stop',
      'halt',
      'pause',
      'freeze',
      'cancel',
      'وقف',
      'قف',
      'توقف',
      'ايه',
      'إيقاف',
    ],
  };

  // ── Command parser ───────────────────────────────────────────────────────
  //
  // Two passes:
  //  1. Exact word match — avoids "rights" matching "right"
  //  2. Contains match  — fallback for Arabic compound words
  //
  static String? _parseCommand(String text) {
    final words = text.split(RegExp(r'\s+'));

    // Pass 1: whole-word match
    for (final entry in _commandKeywords.entries) {
      for (final keyword in entry.value) {
        if (words.contains(keyword)) return entry.key;
      }
    }

    // Pass 2: substring match (Arabic)
    for (final entry in _commandKeywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) return entry.key;
      }
    }

    return null; // no valid command found
  }
}
