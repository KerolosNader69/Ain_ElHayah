import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../services/voice_service.dart';
import 'api_key_loader.dart';

class AIChatService {
  static GenerativeModel? _model;
  static ChatSession? _chat;
  static bool _isInitialized = false;
  static String _preferredLanguageCode = 'en';

  /// Set preferred language code, e.g., 'ar' or 'en'.
  static void setPreferredLanguageCode(String languageCode) {
    _preferredLanguageCode = languageCode.toLowerCase();
  }

  static bool get _useArabic => _preferredLanguageCode.startsWith('ar');

  /// Initialize the AI model
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load the API key from --dart-define or fallback env.json
      final apiKey = await ApiKeyLoader.loadGoogleApiKey();
      if (apiKey.isEmpty) {
        print('Warning: No API key found, using fallback mode');
        _isInitialized = true; // Mark as initialized to use fallback
        return;
      }

      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.text(
          """
You are an ophthalmology (eye) assistant.

Language: Always respond in the user's language (Arabic or English) and be brief, friendly, and clear.

Assumptions:
- Default to treating the user's message as eye-related unless it is clearly unrelated (e.g., cars, programming, banking). If clearly unrelated, politely say it's outside your scope and invite an eye question.
- If a message contains known eye terms (e.g., retina, retinal, macula, optic nerve, cataract, glaucoma, uveitis, conjunctivitis, keratoconus, retinitis pigmentosa, diabetic retinopathy, AMD), ALWAYS treat it as eye-related.

Guidance for eye-related queries:
- Provide concise, practical information: likely causes, warning signs, and next steps.
- Prefer bullet lists when naming conditions.
- End with: 'It is very important to visit an ophthalmologist for accurate diagnosis.'
          """,
        ),
      );
      _chat = _model!.startChat(history: []);
      _isInitialized = true;
      print('AI model initialized successfully');
    } catch (e) {
      print('AI initialization error: $e, using fallback mode');
      _isInitialized = true; // Mark as initialized to use fallback
    }
  }

  /// Send a text message to the AI chatbot
  static Future<String> sendMessage(String message) async {
    if (!_isInitialized) {
      try {
        await initialize();
      } catch (e) {
        // If initialization fails (no API key), use fallback responses
        return _getFallbackResponse(message);
      }
    }

    try {
      // If model/chat is unavailable (e.g., missing API key), fallback gracefully
      if (_chat == null) {
        return _getFallbackResponse(message);
      }
      // Handle greetings locally without calling the model
      if (_isGreeting(message)) {
        final isArabic = _useArabic;
        return isArabic
            ? '👋 أهلاً! أنا مساعد مختص بأمراض العين. اسألني عن أعراضك أو أرسل صورة للعين وسأحاول المساعدة.'
            : '👋 Hi! I\'m an eye-health assistant. Ask me about eye symptoms or send an eye image and I will help.';
      }

      final content = _createTextPrompt(message);
      final response = await _chat!.sendMessage(content);
      return response.text ?? '⚠️ No response.';
    } catch (e) {
      // If AI service fails, use fallback responses
      return _getFallbackResponse(message);
    }
  }

  /// Send image to AI chatbot
  static Future<String> sendImage(Uint8List imageBytes) async {
    // Pure Gemini analysis as an AI agent (no local retina model influence)
    if (!_isInitialized) {
      try {
        await initialize();
      } catch (e) {
        return 'AI service is not configured. Provide a valid GOOGLE_API_KEY to enable image analysis.';
      }
    }

    try {
      if (_model == null) {
        return 'AI service is not configured. Provide a valid GOOGLE_API_KEY to enable image analysis.';
      }
      final prompt = _useArabic
          ? '''
أنت مساعد ذكاء اصطناعي مختص بطب العيون. حلّل صورة العين المرفقة.

قدّم إجابة نهائية موجزة فقط تتضمن:
- أهم الملاحظات التي تراها
- أكثر الاحتمالات تشخيصًا (بنقاط)
- سبب مختصر
- نصائح منزلية وخطوات تالية
- علامات الخطر التي تستدعي التوجّه العاجل للطبيب

اختم بـ: "⚠️ من المهم جدًا زيارة طبيب عيون للتشخيص الدقيق."
'''
          : '''
You are an ophthalmology AI assistant. Analyze the provided eye image.

Provide ONLY a concise final answer with:
- Findings you observe
- Most likely conditions (bulleted)
- Brief reasoning
- Home care tips and next steps
- Red flags that need urgent care

End with: "It is very important to visit an ophthalmologist for accurate diagnosis."
''';

      final content = [
        Content.text(prompt),
        Content.data('image/jpeg', imageBytes),
      ];

      final response = await _model!.generateContent(content);
      return response.text ?? 'Unable to analyze the image. Please try again.';
    } catch (e) {
      // Common invalid key messages from client or server
      final msg = e.toString();
      if (msg.contains('API key not valid') || msg.contains('permission') || msg.contains('unauthorized')) {
        return 'Unable to analyze the image. API key not valid. Please pass a valid API key.';
      }
      return 'Unable to analyze the image. $e';
    }
  }

  /// Analyze questionnaire by building a concise instruction and returning model text.
  static Future<String> analyzeQuestionnaire(String prompt) async {
    if (!_isInitialized) {
      try {
        await initialize();
      } catch (e) {
        return _useArabic
            ? 'الخدمة غير مفعلة. يرجى ضبط مفتاح GOOGLE_API_KEY.'
            : 'Service not configured. Please set GOOGLE_API_KEY.';
      }
    }

    try {
      // Guard against missing model/chat when running without API key
      if (_chat == null) {
        return _useArabic
            ? 'الخدمة غير مفعلة. يرجى ضبط مفتاح GOOGLE_API_KEY.'
            : 'Service not configured. Please set GOOGLE_API_KEY.';
      }
      final response = await _chat!.sendMessage(Content.text(prompt));
      return response.text ?? (_useArabic ? 'لا توجد إجابة.' : 'No response.');
    } catch (e) {
      return _useArabic
          ? 'تعذر إجراء التحليل: $e'
          : 'Unable to analyze: $e';
    }
  }

  /// Agent that returns structured JSON with probable conditions and probabilities.
  static Future<Map<String, dynamic>> analyzeQuestionnaireStructured({
    required Map<String, dynamic> answers,
  }) async {
    if (!_isInitialized) {
      try {
        await initialize();
      } catch (e) {
        return {
          'error': _useArabic
              ? 'الخدمة غير مفعلة. يرجى ضبط مفتاح GOOGLE_API_KEY.'
              : 'Service not configured. Please set GOOGLE_API_KEY.'
        };
      }
    }

    // If the model is not available (e.g., missing API key), return a clear error
    if (_model == null) {
      return {
        'error': _useArabic
            ? 'الخدمة غير مفعلة. يرجى ضبط مفتاح GOOGLE_API_KEY.'
            : 'Service not configured. Please set GOOGLE_API_KEY.'
      };
    }

    final system = _useArabic
        ? 'أنت وكيل ذكاء اصطناعي مختص بطب العيون. حلّل المدخلات وقدّم نتيجة منظمة بصيغة JSON فقط.'
        : 'You are an ophthalmology AI agent. Analyze inputs and return JSON only.';

    final instruction = _useArabic
        ? '''اقرأ الإجابات التالية وارجع JSON فقط بهذا الشكل:
{
  "conditions": [
    {"name": "اسم المرض", "probability": 0.83, "rationale": "سبب مختصر"}
  ],
  "recommendations": ["نصيحة قصيرة"],
  "red_flags": ["علامة خطر إن وجدت"]
}
يجب أن يكون الاحتمال بين 0 و1. لا تضف نصاً خارج JSON.'''
        : '''Read the answers and return JSON only with:
{
  "conditions": [
    {"name": "Condition", "probability": 0.83, "rationale": "short reason"}
  ],
  "recommendations": ["short advice"],
  "red_flags": ["if any"]
}
Probabilities 0..1. No text outside JSON.''';

    final content = [
      Content.text(system),
      Content.text('Inputs:\n${answers.toString()}'),
      Content.text(instruction),
    ];

    try {
      final response = await _model!.generateContent(content);
      final raw = response.text ?? '';
      // Try to find JSON in the response
      final jsonStart = raw.indexOf('{');
      final jsonEnd = raw.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonStr = raw.substring(jsonStart, jsonEnd + 1);
        return _tryParseJson(jsonStr);
      }
      return {'error': _useArabic ? 'تعذر解析 الرد' : 'Failed to parse response'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Map<String, dynamic> _tryParseJson(String s) {
    try {
      final decoded = convert.jsonDecode(s);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'error': 'invalid_json'};
    } catch (_) {
      return {'error': 'invalid_json'};
    }
  }

  /// Pick and send an image
  static Future<String?> pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (x == null) return null;
      
      final bytes = await x.readAsBytes();
      return await sendImage(bytes);
    } catch (e) {
      return '❌ Error picking image: $e';
    }
  }

  /// Local fallback analysis using the on-device/hosted retina model
  // Removed local retina fallbacks per request to rely solely on Gemini for chat image analysis

  /// Create text prompt for the AI
  static Content _createTextPrompt(String userText) {
    final isArabic = _useArabic;
    final prompt = isArabic
        ? """
الرسالة: $userText
اعتبر الرسالة متعلقة بالعين ما لم تكن بوضوح في مجال آخر (سيارات، برمجة...).
لو كانت متعلقة بالعين: أجب بنقاط موجزة (أسباب/احتمالات/نصائح بسيطة)، ثم اختم فقط عندها بـ:
'⚠️ مهم جدًا زيارة طبيب عيون للتشخيص الدقيق.'
لو كانت بوضوح غير متعلقة بالعين: اعتذر باختصار وادعُ المستخدم لسؤال يخص العين.
"""
        : """
Message: $userText
Assume it is eye-related unless it is clearly unrelated (cars, programming, banking...).
If eye-related: give concise bullets (likely causes, red flags, next steps) and then end with:
'It is very important to visit an ophthalmologist for accurate diagnosis.'
If clearly unrelated: politely say it's outside scope and invite an eye question.
""";
    return Content.text(prompt);
  }

  /// Create image prompt for the AI
  static Content _createImagePrompt(Uint8List bytes) {
    return Content.multi([
      TextPart("""
🔬 Analyze this image for eye-related issues ONLY.
- Is the eye normal or not?
- If abnormal, name likely conditions (e.g., cataract, glaucoma, inflammation, redness, dryness).
- Short reasoning.
- End with: "⚠️ It is very important to visit an ophthalmologist for accurate diagnosis."
"""),
      DataPart('image/jpeg', bytes),
    ]);
  }

  /// Check if message is a greeting
  static bool _isGreeting(String text) {
    final s = text.toLowerCase();
    final en = [
      'hi', 'hello', 'hey', 'how are you', 'good morning', 'good evening',
      'good afternoon'
    ];
    final ar = [
      'ازيك', 'إزيك', 'كيف حالك', 'السلام عليكم', 'اهلا', 'أهلاً', 'اهلاً',
      'مرحبا', 'مرحبًا', 'صباح الخير', 'مساء الخير', 'هاي'
    ];
    return en.any((k) => s.contains(k)) || ar.any((k) => text.contains(k));
  }

  /// Test connection to the AI service
  static Future<bool> testConnection() async {
    try {
      await initialize();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset the chat session
  static void resetChat() {
    if (_model != null) {
      _chat = _model!.startChat(history: []);
    }
  }

  /// Get fallback response when AI service is not available
  static String _getFallbackResponse(String message) {
    final isArabic = _useArabic;
    
    // Check if it's a greeting
    if (_isGreeting(message)) {
      return isArabic
          ? '👋 أهلاً! أنا مساعد مختص بأمراض العين. اسألني عن أعراضك أو أرسل صورة للعين وسأحاول المساعدة.'
          : '👋 Hi! I\'m an eye-health assistant. Ask me about eye symptoms or send an eye image and I will help.';
    }

    // Check if it's eye-related
    final eyeKeywords = isArabic 
        ? [
            'عين','العين','ألم','ألم العين','احمرار','جفاف','رؤية','ضبابية','صداع','حكة','التهاب',
            'قرنية','شبكية','الشبكية','عدسة','جلوكوما','زرق','كتاركت','ماء بيضاء','التهاب القزحية','التهاب الملتحمة',
            'التهاب الجفن','حساسية العين','اعتلال الشبكية السكري','تنكس بقعي','القرنية المخروطية','التهاب القرنية',
            'رتينيتس بيغمينتوزا','التهاب الصلبة','انسداد القناة الدمعية'
          ]
        : [
            'eye','ocular','vision','blur','red','dry','itch','burning','sore','headache','tearing','pain',
            'retina','retinal','macula','optic','cornea','lens','uveitis','conjunctivitis','blepharitis',
            'keratoconus','glaucoma','cataract','diabetic retinopathy','amd','age-related macular degeneration',
            'retinitis pigmentosa','iritis','keratitis','scleritis','dacryocystitis'
          ];
    
    final hasEyeKeywords = eyeKeywords.any((keyword) => 
        message.toLowerCase().contains(keyword.toLowerCase()));
    
    if (hasEyeKeywords) {
      if (isArabic) {
        return '''أعراض العين التي ذكرتها قد تشير إلى:

• التهاب الملتحمة (احمرار العين)
• جفاف العين
• إجهاد العين
• التهاب الجفن
• حساسية العين

⚠️ من المهم جداً زيارة طبيب عيون للتشخيص الدقيق.''';
      } else {
        return '''The eye symptoms you mentioned may indicate:

• Conjunctivitis (red eye)
• Dry eye syndrome
• Eye strain
• Blepharitis
• Eye allergy

⚠️ It is very important to visit an ophthalmologist for accurate diagnosis.''';
      }
    } else {
      return isArabic
          ? 'أنا أجيب فقط على الأسئلة المتعلقة بالعين.'
          : 'I only answer eye-related health questions.';
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
