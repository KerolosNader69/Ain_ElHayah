import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/ai_chat_service.dart';
import '../screens/chat_screen.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  Function(String)? _onAIMessageReceived;

  ChatProvider() {
    // Add a welcome message when the provider is created
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text: '👋 Hi! I\'m your AI Eye Health Assistant. Ask me about eye symptoms, upload eye images, or just say hello!',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(welcomeMessage);
  }

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  void setOnAIMessageReceived(Function(String) callback) {
    _onAIMessageReceived = callback;
  }

  void addMessage(String text, bool isUser, {DateTime? timestamp, Uint8List? imageBytes}) {
    final message = ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: timestamp,
      imageBytes: imageBytes,
    );
    _messages.add(message);
    notifyListeners();
  }

  /// Send message to AI chatbot
  Future<void> sendMessageToAI(String message) async {
    try {
      _isTyping = true;
      notifyListeners();

      final response = await AIChatService.sendMessage(message);
      
      addMessage(response, false);
      
      // Notify callback when AI message is received
      if (_onAIMessageReceived != null) {
        _onAIMessageReceived!(response);
      }
    } catch (e) {
      final errorMessage = 'Sorry, I encountered an error: $e';
      addMessage(errorMessage, false);
      
      // Notify callback for error messages too
      if (_onAIMessageReceived != null) {
        _onAIMessageReceived!(errorMessage);
      }
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  /// Send image to AI chatbot
  Future<void> sendImageToAI(Uint8List imageBytes) async {
    try {
      _isTyping = true;
      notifyListeners();

      final response = await AIChatService.sendImage(imageBytes);
      
      addMessage(response, false);
      
      // Notify callback when AI message is received
      if (_onAIMessageReceived != null) {
        _onAIMessageReceived!(response);
      }
    } catch (e) {
      final errorMessage = 'Sorry, I encountered an error processing the image: $e';
      addMessage(errorMessage, false);
      
      // Notify callback for error messages too
      if (_onAIMessageReceived != null) {
        _onAIMessageReceived!(errorMessage);
      }
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  /// Pick and send image
  Future<void> pickAndSendImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        addMessage('', true, imageBytes: bytes);
        
        // Send image to AI
        await sendImageToAI(bytes);
      }
    } catch (e) {
      addMessage('Failed to pick image: $e', false);
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void markMessageAsRead(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages[index] = ChatMessage(
        text: _messages[index].text,
        isUser: _messages[index].isUser,
        timestamp: _messages[index].timestamp,
        isRead: true,
        imageBytes: _messages[index].imageBytes,
      );
      notifyListeners();
    }
  }

  void markAllMessagesAsRead() {
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].isUser && !_messages[i].isRead) {
        _messages[i] = ChatMessage(
          text: _messages[i].text,
          isUser: _messages[i].isUser,
          timestamp: _messages[i].timestamp,
          isRead: true,
          imageBytes: _messages[i].imageBytes,
        );
      }
    }
    notifyListeners();
  }
}

