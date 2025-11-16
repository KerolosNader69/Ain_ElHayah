import 'dart:typed_data';
import 'package:flutter/material.dart';

class MobileAudioRecorder {
  void dispose() {
    // No-op for web
  }

  Future<void> startRecording() async {
    throw UnsupportedError('Audio recording is not supported on web');
  }

  Future<Uint8List?> stopRecording() async {
    throw UnsupportedError('Audio recording is not supported on web');
  }
}
