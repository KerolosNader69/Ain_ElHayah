import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/app_header.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/ai_chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isTyping = false;
  bool _isSpeaking = false;
  bool _speakerEnabled = true; // Global speaker toggle
  String _currentLanguage = 'en-US'; // Default to English
  String? _currentSpeakingText;
  late AnimationController _typingAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _speakerAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _speakerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    // Set up callback for AI messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.setOnAIMessageReceived(_onAIMessageReceived);
      // Sync AI language with app language
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      AIChatService.setPreferredLanguageCode(appProvider.locale.languageCode);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update AI language when locale changes
    final appProvider = Provider.of<AppProvider>(context);
    AIChatService.setPreferredLanguageCode(appProvider.locale.languageCode);
  }

  Future<void> _initializeSpeech() async {
    try {
      print('Initializing speech recognition...');
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          setState(() {
            _speechEnabled = false;
          });
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
        },
        debugLogging: true, // Enable debug logging
      );
      print('Speech recognition initialized: $_speechEnabled');
      
      // Initialize TTS with better configuration
      print('Initializing TTS...');
      
      // Get available languages (commented out to avoid issues)
      // final languages = await _flutterTts.getLanguages;
      // print('Available TTS languages: $languages');
      
      // Get available voices (commented out to avoid issues)
      // final voices = await _flutterTts.getVoices;
      // print('Available TTS voices: $voices');
      
      // Set up TTS with platform-specific configuration
      if (kIsWeb) {
        // Web configuration
        await _flutterTts.setLanguage("en-US");
        await _flutterTts.setSpeechRate(0.8);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);
        print('TTS configured for Web');
      } else if (Platform.isAndroid) {
        // Android configuration - try to set up both languages
        await _flutterTts.setLanguage("en-US");
        await _flutterTts.setSpeechRate(0.8);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);
        
        // Test Arabic language availability
        try {
          await _flutterTts.setLanguage("ar-EG");
          print('Arabic TTS available on Android');
        } catch (e) {
          print('Arabic TTS not available on Android: $e');
        }
        
        // Set back to English
        await _flutterTts.setLanguage("en-US");
        print('TTS configured for Android');
      } else if (Platform.isIOS) {
        // iOS configuration - try to set up both languages
        await _flutterTts.setLanguage("en-US");
        await _flutterTts.setSpeechRate(0.8);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);
        
        // Test Arabic language availability
        try {
          await _flutterTts.setLanguage("ar-EG");
          print('Arabic TTS available on iOS');
        } catch (e) {
          print('Arabic TTS not available on iOS: $e');
        }
        
        // Set back to English
        await _flutterTts.setLanguage("en-US");
        print('TTS configured for iOS');
      } else {
        // Default configuration
        await _flutterTts.setLanguage("en-US");
        await _flutterTts.setSpeechRate(0.8);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);
        print('TTS configured for default platform');
      }
      
      // Test TTS initialization (commented out to avoid issues)
      // final result = await _flutterTts.speak("Test");
      // print('TTS initialization test result: $result');
      
      // Try to get available engines (commented out to avoid issues)
      // try {
      //   final engines = await _flutterTts.getEngines;
      //   print('Available TTS engines: $engines');
      // } catch (e) {
      //   print('Could not get TTS engines: $e');
      // }
      
      // Set up TTS callbacks
      _flutterTts.setStartHandler(() {
        print('TTS started speaking');
        setState(() {
          _isSpeaking = true;
        });
      });
      
      _flutterTts.setCompletionHandler(() {
        print('TTS completed speaking');
        setState(() {
          _isSpeaking = false;
          _currentSpeakingText = null;
        });
      });
      
      _flutterTts.setErrorHandler((msg) {
        print('TTS Error: $msg');
        setState(() {
          _isSpeaking = false;
          _currentSpeakingText = null;
        });
      });
      
      print('TTS initialized successfully');
      
      // Check TTS status
      await _checkTTSStatus();
    } catch (e) {
      print('Failed to initialize speech: $e');
      _speechEnabled = false;
    }
  }

  Future<void> _checkTTSStatus() async {
    try {
      print('Checking TTS status...');
      
      // Note: Flutter TTS doesn't support getting current values
      // We can only set them, not retrieve them
      print('TTS status check completed');
      print('Current language setting: $_currentLanguage');
      
    } catch (e) {
      print('Error checking TTS status: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _pulseAnimationController.dispose();
    _speakerAnimationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Speaker functionality methods
  Future<void> _speakText(String text) async {
    if (!_speakerEnabled || text.isEmpty) return;
    
    print('Attempting to speak text: "$text"');
    
    try {
      // Stop any current speech
      await _flutterTts.stop();
      
      setState(() {
        _currentSpeakingText = text;
      });
      
      // Detect language and set TTS language accordingly
      await _setTTSLanguageForText(text);
      
      // Clean the text for better TTS
      final cleanText = _cleanTextForTTS(text);
      print('Cleaned text for TTS: "$cleanText"');
      
      final result = await _flutterTts.speak(cleanText);
      print('TTS speak result: $result');
    } catch (e) {
      print('Error speaking text: $e');
      setState(() {
        _isSpeaking = false;
        _currentSpeakingText = null;
      });
    }
  }

  Future<void> _speakTextImmediately(String text) async {
    if (!_speakerEnabled || text.isEmpty) return;
    
    print('Attempting to speak text immediately: "$text"');
    
    try {
      setState(() {
        _currentSpeakingText = text;
      });
      
      // Detect language and set TTS language accordingly
      await _setTTSLanguageForText(text);
      
      // Clean the text for better TTS
      final cleanText = _cleanTextForTTS(text);
      print('Cleaned text for TTS: "$cleanText"');
      
      final result = await _flutterTts.speak(cleanText);
      print('TTS speak result: $result');
    } catch (e) {
      print('Error speaking text: $e');
      setState(() {
        _isSpeaking = false;
        _currentSpeakingText = null;
      });
    }
  }

  Future<void> _setTTSLanguageForText(String text) async {
    try {
      bool isArabic = _containsArabic(text);
      String targetLanguage = isArabic ? 'ar-EG' : 'en-US';
      
      print('Text contains Arabic: $isArabic, setting TTS language to: $targetLanguage');
      
      // Set the TTS language based on text content
      await _flutterTts.setLanguage(targetLanguage);
      
      // Update current language state
      setState(() {
        _currentLanguage = targetLanguage;
      });
      
      print('TTS language set to: $targetLanguage');
    } catch (e) {
      print('Error setting TTS language: $e');
      
      // Fallback to English if Arabic fails
      if (_containsArabic(text)) {
        print('Arabic TTS failed, falling back to English');
        try {
          await _flutterTts.setLanguage('en-US');
          setState(() {
            _currentLanguage = 'en-US';
          });
          print('Fallback to English TTS successful');
        } catch (fallbackError) {
          print('Fallback to English TTS also failed: $fallbackError');
        }
      }
    }
  }

  String _cleanTextForTTS(String text) {
    // Detect language and clean accordingly
    bool isArabic = _containsArabic(text);
    
    if (isArabic) {
      // For Arabic text, preserve Arabic characters and basic punctuation
      String cleaned = text
          .replaceAll(RegExp(r'[^\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s.,!?-]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      if (cleaned.isEmpty) {
        cleaned = text;
      }
      
      // Limit text length
      if (cleaned.length > 500) {
        cleaned = cleaned.substring(0, 500) + '...';
      }
      
      return cleaned;
    } else {
      // For English text, preserve English characters and basic punctuation
      String cleaned = text
          .replaceAll(RegExp(r'[^\w\s.,!?-]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      if (cleaned.isEmpty) {
        cleaned = text;
      }
      
      // Limit text length
      if (cleaned.length > 500) {
        cleaned = cleaned.substring(0, 500) + '...';
      }
      
      return cleaned;
    }
  }

  bool _containsArabic(String text) {
    // Check if text contains Arabic characters
    return RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]').hasMatch(text);
  }

  Future<void> _stopSpeaking() async {
    try {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
        _currentSpeakingText = null;
      });
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  void _toggleSpeaker() {
    setState(() {
      _speakerEnabled = !_speakerEnabled;
    });
    
    if (!_speakerEnabled) {
      _stopSpeaking();
    }
  }

  void _onAIMessageReceived(String message) {
    // Automatically speak AI messages if speaker is enabled
    if (_speakerEnabled && message.isNotEmpty) {
      _speakText(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 72,
            collapsedHeight: 72,
            expandedHeight: 72,
            flexibleSpace: const SizedBox.expand(child: AppHeader()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildChatInterface(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.getGlassmorphismDecoration(context, opacity: 0.1),
      child: Column(
        children: [
          // App logo (no background)
          Image.asset(
            'assets/images/Ain Al-Hayah@Logo.png',
            height: 72,
            width: 72,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            l10n.aiEyeHealthAssistant,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            l10n.getInstantAnswers,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Status indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Speech recognition status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _speechEnabled 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _speechEnabled ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  _speechEnabled 
                      ? '🎤 Voice recognition ready'
                      : '❌ Voice recognition not available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _speechEnabled ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // AI Speaking status
              if (_isSpeaking)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accentColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                        ),
                      ),
                      const SizedBox(width: 6),
                                             Text(
                         '🔊 AI Speaking (${_currentLanguage == 'ar-EG' ? 'Arabic' : 'English'})',
                         style: theme.textTheme.bodySmall?.copyWith(
                           color: AppTheme.accentColor,
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Language Selector and Speaker Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.getMutedBackgroundColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language,
                      size: 20,
                      color: AppTheme.getTextColor(context),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Voice Language:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.getTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                _buildLanguageChip(context, 'English', 'en-US', Icons.flag),
                _buildLanguageChip(context, 'العربية', 'ar-EG', Icons.flag_circle),
                
                // Speaker Toggle
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.volume_up,
                      size: 20,
                      color: AppTheme.getTextColor(context),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'AI Speaker:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.getTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                _buildSpeakerToggle(context),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickActionChip(context, l10n.eyePain, Icons.visibility),
              _buildQuickActionChip(context, l10n.blurredVision, Icons.blur_on),
              _buildQuickActionChip(context, l10n.redEyes, Icons.remove_red_eye),
              _buildQuickActionChip(context, l10n.headaches, Icons.headset),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Flexible(
        child: Text(
          text,
          overflow: TextOverflow.visible,
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      ),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: AppTheme.getMutedBackgroundColor(context),
      labelStyle: TextStyle(
        color: AppTheme.getTextColor(context),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: AppTheme.getBorderColor(context),
        width: 1,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildLanguageChip(BuildContext context, String text, String languageCode, IconData icon) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Flexible(
        child: Text(
          text,
          overflow: TextOverflow.visible,
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      ),
      onPressed: () async {
        setState(() {
          _currentLanguage = languageCode;
        });
        
        // Update TTS language
        try {
          print('Setting TTS language to: $languageCode');
          final result = await _flutterTts.setLanguage(languageCode);
          print('TTS language set result: $result');
          
          // Test the new language with an appropriate phrase (commented out to avoid issues)
          // String testPhrase = languageCode == 'ar-EG' 
          //     ? 'مرحبا! اختبار اللغة العربية'
          //     : 'Hello! English language test';
          
          // await _flutterTts.speak(testPhrase);
          print('TTS language set to: $languageCode');
        } catch (e) {
          print('Failed to set TTS language: $e');
        }
      },
      backgroundColor: _currentLanguage == languageCode ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.getMutedBackgroundColor(context),
      labelStyle: TextStyle(
        color: _currentLanguage == languageCode ? AppTheme.primaryColor : AppTheme.getTextColor(context),
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: _currentLanguage == languageCode ? AppTheme.primaryColor : AppTheme.getBorderColor(context),
        width: 1,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildSpeakerToggle(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _speakerAnimationController,
      builder: (context, child) {
        return ActionChip(
          avatar: Icon(
            _speakerEnabled ? Icons.volume_up : Icons.volume_off,
            size: 16,
            color: _speakerEnabled 
                ? (_isSpeaking ? AppTheme.accentColor : AppTheme.getTextColor(context))
                : Colors.grey,
          ),
          label: Flexible(
            child: Text(
              _speakerEnabled ? 'ON' : 'OFF',
              overflow: TextOverflow.visible,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          onPressed: _toggleSpeaker,
          backgroundColor: _speakerEnabled 
              ? (_isSpeaking ? AppTheme.accentColor.withOpacity(0.1) : AppTheme.getMutedBackgroundColor(context))
              : AppTheme.getMutedBackgroundColor(context),
          labelStyle: TextStyle(
            color: _speakerEnabled 
                ? (_isSpeaking ? AppTheme.accentColor : AppTheme.getTextColor(context))
                : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide(
            color: _speakerEnabled 
                ? (_isSpeaking ? AppTheme.accentColor : AppTheme.getBorderColor(context))
                : Colors.grey,
            width: 1,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
    );
  }

  Widget _buildMessageSpeakerControls(BuildContext context, ChatMessage message) {
    final theme = Theme.of(context);
    final isCurrentMessageSpeaking = _isSpeaking && _currentSpeakingText == message.text;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Speaker button
        GestureDetector(
          onTap: () {
            if (isCurrentMessageSpeaking) {
              _stopSpeaking();
            } else {
              _speakTextImmediately(message.text);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isCurrentMessageSpeaking 
                  ? AppTheme.accentColor.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCurrentMessageSpeaking ? Icons.stop : Icons.volume_up,
              size: 16,
              color: isCurrentMessageSpeaking 
                  ? AppTheme.accentColor
                  : AppTheme.getTextColor(context, isMuted: true),
            ),
          ),
        ),
        
        // Speaking indicator
        if (isCurrentMessageSpeaking) ...[
          const SizedBox(width: 4),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChatInterface(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Container(
          height: 600,
          decoration: AppTheme.getGradientDecoration(
            context, 
            isDark: Theme.of(context).brightness == Brightness.dark
          ),
          child: Column(
            children: [
              // Chat Messages
              Expanded(
                child: _buildMessagesList(context, chatProvider),
              ),
              
              // Typing Indicator
              if (_isTyping) _buildTypingIndicator(context),
              
              // Input Section
              _buildInputSection(context, chatProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatProvider chatProvider) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    if (chatProvider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.getTextColor(context, isMuted: true),
            ),
            const SizedBox(height: 16),
            Text(
              'Start chatting with your AI Eye Health Assistant!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.getTextColor(context, isDescription: true),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Type a message below or upload an eye image for analysis.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getTextColor(context, isDescription: true),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return _buildMessageBubble(context, message, index);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, int index) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.aiGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/Ain Al-Hayah@Logo.png',
                height: 20,
                width: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: 0,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppTheme.primaryColor
                    : AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser 
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.imageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        message.imageBytes!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (message.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: (message.imageBytes != null) ? 8 : 0
                      ),
                      child: Text(
                        message.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isUser 
                              ? Colors.white
                              : AppTheme.getTextColor(context),
                          height: 1.4,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isUser 
                              ? Colors.white.withOpacity(0.7)
                              : AppTheme.getTextColor(context, isMuted: true),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 16,
                          color: message.isRead 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white.withOpacity(0.5),
                        ),
                      ],
                      if (!isUser && message.text.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildMessageSpeakerControls(context, message),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.aiGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/images/Ain Al-Hayah@Logo.png',
              height: 20,
              width: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(context, 0),
                const SizedBox(width: 4),
                _buildTypingDot(context, 1),
                const SizedBox(width: 4),
                _buildTypingDot(context, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(BuildContext context, int index) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final animationValue = (_typingAnimationController.value + delay) % 1.0;
        final opacity = (animationValue * 2).clamp(0.0, 1.0);
        
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.getTextColor(context, isMuted: true).withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputSection(BuildContext context, ChatProvider chatProvider) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        border: Border(
          top: BorderSide(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Recording indicator
          if (_isListening) _buildRecordingIndicator(context, chatProvider),
          
          Row(
            children: [
              // Image Button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getMutedBackgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                    chatProvider.pickAndSendImage();
                  },
                  icon: const Icon(Icons.image_outlined),
                  tooltip: 'Send Image',
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Voice Note Button
              AnimatedBuilder(
                animation: _pulseAnimationController,
                builder: (context, child) {
                  final isRecording = _isListening;
                  return Container(
                    decoration: BoxDecoration(
                      color: isRecording
                          ? AppTheme.errorColor.withOpacity(0.1)
                          : AppTheme.getMutedBackgroundColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: isRecording
                          ? Border.all(
                              color: AppTheme.errorColor.withOpacity(0.3),
                              width: 2,
                            )
                          : null,
                    ),
                    child: IconButton(
                      onPressed: isRecording
                          ? () => _stopVoiceNoteRecording(chatProvider)
                          : () => _startVoiceNoteRecording(chatProvider),
                      icon: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        color: isRecording
                            ? AppTheme.errorColor
                            : AppTheme.getTextColor(context),
                      ),
                      tooltip: isRecording
                          ? l10n.stopRecording 
                          : 'Tap to record voice message',
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 12),
              
              // Text Input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.getMutedBackgroundColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.getBorderColor(context),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: l10n.typeYourEyeHealthQuestion,
                      hintStyle: TextStyle(
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Send Button
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  tooltip: l10n.sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator(BuildContext context, ChatProvider chatProvider) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    String languageText = _currentLanguage == 'en-US' ? 'English' : 'العربية';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.mic,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Listening... Speak now',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Language: $languageText',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            l10n.tapToStop,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.errorColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addMessage(text, true);
    _messageController.clear();
    _scrollToBottom();

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    // Send message to AI chatbot
    chatProvider.sendMessageToAI(text).then((_) {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  void _startVoiceNoteRecording(ChatProvider chatProvider) async {
    try {
      // Use real-time speech-to-text
      setState(() {
        _isListening = true;
      });

      await _speechToText.listen(
        onResult: (result) {
          print('Speech recognition result: ${result.recognizedWords} (final: ${result.finalResult})');
          
          // Update the text field with partial results
          if (result.recognizedWords.isNotEmpty) {
            _messageController.text = result.recognizedWords;
          }
          
          // If it's a final result, send the message
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            print('Final result detected, sending message: ${result.recognizedWords}');
            setState(() {
              _isListening = false;
            });
            // Automatically send the message
            _sendMessage();
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        localeId: _currentLanguage,
        partialResults: true,
      );
    } catch (e) {
      print('Error starting voice recording: $e');
      // Handle recording error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _stopVoiceNoteRecording(ChatProvider chatProvider) async {
    try {
      print('Stopping speech recognition...');
      // Stop real-time speech recognition
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
      
      // Check if we have any recognized text and send it
      final recognizedText = _messageController.text.trim();
      print('Recognized text when stopping: "$recognizedText"');
      
      if (recognizedText.isNotEmpty) {
        print('Sending recognized text: $recognizedText');
        _sendMessage();
      } else {
        // Show dialog to manually enter text if speech recognition failed
        print('No text recognized, showing manual input dialog');
        if (mounted) {
          _showManualInputDialog();
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      // Handle recording error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showManualInputDialog() {
    final TextEditingController manualController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Voice Recognition Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Speech was not detected. Please type your message:'),
              const SizedBox(height: 16),
              TextField(
                controller: manualController,
                decoration: const InputDecoration(
                  hintText: 'Type your eye health question...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = manualController.text.trim();
                if (text.isNotEmpty) {
                  _messageController.text = text;
                  _sendMessage();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isRead;
  final Uint8List? imageBytes;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isRead = false,
    this.imageBytes,
  }) : timestamp = timestamp ?? DateTime.now();
}
