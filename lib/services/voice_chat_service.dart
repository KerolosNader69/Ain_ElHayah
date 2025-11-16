import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for voice chat that communicates with backend API
/// All SIS communication is handled securely on the backend
class VoiceChatService {
  final String backendUrl;

  VoiceChatService({required this.backendUrl});

  /// Send audio to backend for transcription and chatbot response
  /// Returns a map with 'userText' and 'botReply' on success
  /// Throws exception on error
  Future<Map<String, dynamic>> sendVoiceMessage(Uint8List audioBytes) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/voice-chat'),
        headers: {
          'Content-Type': 'audio/wav',
        },
        body: audioBytes,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'userText': data['userText'] ?? '',
            'botReply': data['botReply'] ?? '',
          };
        } else {
          throw Exception(data['error'] ?? 'Voice chat failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send voice message: $e');
    }
  }
}
