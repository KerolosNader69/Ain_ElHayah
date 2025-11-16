import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class MobileAudioRecorder {
  final AudioRecorder _recorder = AudioRecorder();

  void dispose() {
    _recorder.dispose();
  }

  Future<void> startRecording() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission denied');
    }

    // Start recording with WAV format, 16kHz, mono
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: '', // Empty path = auto-generate
    );

    debugPrint('Recording started');
  }

  Future<Uint8List?> stopRecording() async {
    debugPrint('Stopping recording...');
    
    // Stop recording
    final path = await _recorder.stop();

    if (path == null) {
      throw Exception('Recording failed - no audio file');
    }

    debugPrint('Recording saved to: $path');

    // Read audio file
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Audio file not found');
    }

    final audioBytes = await file.readAsBytes();

    // Clean up audio file
    try {
      await file.delete();
      debugPrint('Audio file deleted');
    } catch (e) {
      debugPrint('Failed to delete audio file: $e');
    }

    return audioBytes;
  }
}
