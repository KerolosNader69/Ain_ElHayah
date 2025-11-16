import 'package:flutter/material.dart';
import '../widgets/voice_chat_button.dart';

/// Demo screen showing how to use the VoiceChatButton widget
/// This can be integrated into your existing chat screen
class VoiceChatDemoScreen extends StatefulWidget {
  const VoiceChatDemoScreen({super.key});

  @override
  State<VoiceChatDemoScreen> createState() => _VoiceChatDemoScreenState();
}

class _VoiceChatDemoScreenState extends State<VoiceChatDemoScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  // TODO: Replace with your actual backend URL
  // For local testing: 'http://192.168.1.X:3001' (your computer's IP)
  // For emulator: 'http://10.0.2.2:3001' (Android) or 'http://localhost:3001' (iOS)
  static const String backendUrl = 'http://10.0.2.2:3001';

  void _handleVoiceResponse(String userText, String botReply) {
    setState(() {
      // Add user message
      _messages.add(ChatMessage(
        text: userText,
        isUser: true,
        isVoice: true,
      ));

      // Add bot reply
      _messages.add(ChatMessage(
        text: botReply,
        isUser: false,
        isVoice: false,
      ));
    });
  }

  void _handleVoiceError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        isVoice: false,
      ));

      // Placeholder bot reply for text messages
      _messages.add(ChatMessage(
        text: 'Text message received: "$text"',
        isUser: false,
        isVoice: false,
      ));
    });

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Chat Demo'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic_none,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Long press the microphone to record',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Text input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendTextMessage(),
                  ),
                ),
                const SizedBox(width: 8),

                // Send button
                IconButton(
                  onPressed: _sendTextMessage,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),

                // Voice chat button
                VoiceChatButton(
                  backendUrl: backendUrl,
                  onResponse: _handleVoiceResponse,
                  onError: _handleVoiceError,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isVoice;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.isVoice,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.isVoice)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.mic,
                  size: 16,
                  color: message.isUser ? Colors.white : Colors.black54,
                ),
              ),
            Flexible(
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
