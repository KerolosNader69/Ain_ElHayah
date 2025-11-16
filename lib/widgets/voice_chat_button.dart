import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:record/record.dart';
import 'dart:io' show File, Platform;

/// Voice chat button widget for recording and sending voice messages
/// Click once to start recording, click again to stop and send
class VoiceChatButton extends StatefulWidget {
  final String backendUrl;
  final Function(String userText, String botReply)? onResponse;
  final Function(String error)? onError;

  const VoiceChatButton({
    super.key,
    required this.backendUrl,
    this.onResponse,
    this.onError,
  });

  @override
  State<VoiceChatButton> createState() => _VoiceChatButtonState();
}

class _VoiceChatButtonState extends State<VoiceChatButton> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isSending = false;
  String? _audioPath;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isSending) return; // Ignore taps while sending
    
    if (_isRecording) {
      // Stop recording and send
      await _stopAndSend();
    } else {
      // Start recording
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      // Check and request permission
      if (await _recorder.hasPermission()) {
        // Configure recording settings
        const config = RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        );

        // Start recording
        // For web, path can be empty string; for mobile, it will generate a temp path
        await _recorder.start(config, path: '');

        setState(() {
          _isRecording = true;
        });
        
        debugPrint('Recording started successfully');
      } else {
        _showError('Microphone permission denied. Please enable it in your browser/device settings.');
      }
    } catch (e) {
      _showError('Failed to start recording: $e');
      debugPrint('Recording error: $e');
    }
  }

  Future<void> _stopAndSend() async {
    if (!_isRecording) return;

    setState(() {
      _isRecording = false;
      _isSending = true;
    });

    try {
      // Stop recording
      final path = await _recorder.stop();
      debugPrint('Recording stopped. Path: $path');

      Uint8List? audioBytes;

      if (kIsWeb) {
        // For web, the path is actually a blob URL or the audio data
        // The record package returns the audio data directly on web
        if (path != null && path.isNotEmpty) {
          // On web, we need to fetch the blob data
          try {
            final response = await http.get(Uri.parse(path));
            audioBytes = response.bodyBytes;
          } catch (e) {
            debugPrint('Error fetching web audio: $e');
            _showError('Failed to get audio data from browser');
            return;
          }
        }
      } else {
        // For mobile, read the file
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            audioBytes = await file.readAsBytes();
            // Clean up the file
            await file.delete();
          }
        }
      }

      if (audioBytes == null || audioBytes.isEmpty) {
        throw Exception('No audio data recorded');
      }

      debugPrint('Audio data size: ${audioBytes.length} bytes');

      // Send to backend
      debugPrint('Sending audio to backend: ${widget.backendUrl}/api/voice-chat');
      final response = await http.post(
        Uri.parse('${widget.backendUrl}/api/voice-chat'),
        headers: {
          'Content-Type': 'audio/wav',
        },
        body: audioBytes,
      );

      // Parse response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final userText = data['userText'] ?? '';
          final botReply = data['botReply'] ?? '';

          debugPrint('Transcription: $userText');
          debugPrint('Bot reply: $botReply');

          if (widget.onResponse != null) {
            widget.onResponse!(userText, botReply);
          }
        } else {
          throw Exception(data['error'] ?? 'Voice chat failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to process voice message: $e');
      debugPrint('Error processing voice: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showError(String message) {
    if (widget.onError != null) {
      widget.onError!(message);
    } else {
      // Fallback: show snackbar if no error handler provided
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isRecording
              ? Colors.red
              : Theme.of(context).primaryColor,
          boxShadow: _isRecording
              ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: _isSending
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 24,
              ),
      ),
    );
  }
}
