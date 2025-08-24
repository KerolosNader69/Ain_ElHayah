import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  static final AudioRecorder _audioRecorder = AudioRecorder();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static final SpeechToText _speechToText = SpeechToText();
  static bool _isInitialized = false;

  /// Initialize voice service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Microphone permission not granted');
      }

      // Initialize speech recognition
      await _speechToText.initialize();
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize voice service: $e');
    }
  }

  /// Start recording voice note
  static Future<void> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('VoiceService: Starting voice note recording...');
      
      // Check if already recording
      if (await _audioRecorder.isRecording()) {
        print('VoiceService: Already recording, stopping previous recording...');
        await stopRecording();
      }

      // Get temporary directory for recording
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/voice_note_$timestamp.m4a';
      
      print('VoiceService: Recording to file: $filePath');

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );
      
      print('VoiceService: Voice note recording started successfully');
    } catch (e) {
      print('VoiceService: Error starting recording: $e');
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Stop recording voice note
  static Future<String?> stopRecording() async {
    try {
      print('VoiceService: Stopping voice note recording...');
      
      if (await _audioRecorder.isRecording()) {
        final path = await _audioRecorder.stop();
        print('VoiceService: Voice note recording stopped. File path: $path');
        return path;
      } else {
        print('VoiceService: No active recording to stop');
        return null;
      }
    } catch (e) {
      print('VoiceService: Error stopping recording: $e');
      throw Exception('Failed to stop recording: $e');
    }
  }

  /// Play voice note
  static Future<void> playVoiceNote(String filePath) async {
    try {
      await _audioPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      throw Exception('Failed to play voice note: $e');
    }
  }

  /// Stop playing voice note
  static Future<void> stopPlaying() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      throw Exception('Failed to stop playing: $e');
    }
  }

  /// Convert speech to text with clarity check
  static Future<SpeechResult> convertSpeechToText({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US', // Can be made configurable
      );

      // Wait for final result
      await Future.delayed(const Duration(seconds: 30));
      
      return SpeechResult(
        recognizedWords: '',
        finalResult: true,
        confidence: 0.0,
      );
    } catch (e) {
      onError('Speech recognition failed: $e');
      rethrow;
    }
  }

  /// Check speech clarity
  static bool isSpeechClear(String text, double confidence) {
    // Check if text is not empty and has reasonable confidence
    if (text.trim().isEmpty) return false;
    if (confidence < 0.3) return false;
    
    // Check for common unclear speech patterns
    final unclearPatterns = [
      RegExp(r'\b(um|uh|ah|er|hmm)\b', caseSensitive: false),
      RegExp(r'\b(what|huh|pardon|sorry)\b', caseSensitive: false),
      RegExp(r'[.]{3,}'), // Multiple dots indicating hesitation
    ];
    
    for (final pattern in unclearPatterns) {
      if (pattern.hasMatch(text)) {
        return false;
      }
    }
    
    // Check minimum word count
    final words = text.trim().split(' ').where((word) => word.length > 1).length;
    if (words < 2) return false;
    
    return true;
  }

  /// Dispose resources
  static Future<void> dispose() async {
    try {
      await _audioRecorder.dispose();
      await _audioPlayer.dispose();
    } catch (e) {
      // Ignore disposal errors
    }
  }
}

/// Simple speech result class
class SpeechResult {
  final String recognizedWords;
  final bool finalResult;
  final double confidence;

  SpeechResult({
    required this.recognizedWords,
    required this.finalResult,
    required this.confidence,
  });
}
