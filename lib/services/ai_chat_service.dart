import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/voice_service.dart';
import 'api_key_loader.dart';
import 'huawei_ai_service.dart';

class AIChatService {
  static GenerativeModel? _model;
  static ChatSession? _chat;
  static bool _isInitialized = false;
  static HuaweiAiService? _huawei;
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
      // Prefer Huawei AI if configured
      final huaCfg = await ApiKeyLoaderHuaweiAi.loadHuaweiAiConfig();
      if (huaCfg != null) {
        _huawei = HuaweiAiService(config: huaCfg);
        _isInitialized = true;
        print('Huawei AI enabled');
        return;
      }

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
You are Dr. EyeWise, a specialized ophthalmology AI assistant with extensive knowledge in eye health and diseases.

PERSONALITY & APPROACH:
- Be warm, empathetic, and professional like a caring doctor
- Show genuine concern for the patient's wellbeing
- Ask follow-up questions to better understand symptoms
- Provide detailed, helpful responses while being clear and accessible
- Always respond in the user's language (Arabic or English)

INTERACTION STYLE:
- Start by acknowledging their concern with empathy
- Ask specific follow-up questions to gather more details:
  * Duration of symptoms (when did it start?)
  * Severity (mild, moderate, severe?)
  * Associated symptoms (pain, discharge, vision changes?)
  * Previous episodes or family history
  * Current medications or treatments tried
- Provide comprehensive information including:
  * Multiple possible causes (most likely to less common)
  * Detailed symptom analysis
  * Risk factors and warning signs
  * Home care recommendations when appropriate
  * When to seek immediate medical attention

EYE HEALTH EXPERTISE:
- Cover all aspects: anterior segment, posterior segment, neuro-ophthalmology, pediatric ophthalmology
- Include both common conditions (dry eye, conjunctivitis) and serious diseases (glaucoma, retinal detachment)
- Explain medical terms in simple language
- Mention relevant anatomy when helpful

SAFETY & DISCLAIMERS:
- Always end with: "It is very important to visit an ophthalmologist for accurate diagnosis and proper treatment."
- For emergency symptoms (sudden vision loss, severe pain, flashing lights), emphasize URGENT medical attention
- Never provide specific medication recommendations or dosages

SCOPE:
- Focus primarily on eye-related health questions
- If clearly unrelated to eyes, politely redirect: "I specialize in eye health. Could you tell me about any eye symptoms or concerns you have?"
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
      if (_huawei != null) {
        final content = await _huawei!.chat(
          messages: [
            {'role': 'system', 'content': _useArabic ? 'أنت مساعد مختص بطب العيون.' : 'You are an ophthalmology assistant.'},
            {'role': 'user', 'content': message},
          ],
        );
        return content;
      }

      // If model/chat is unavailable (e.g., missing API key), fallback gracefully
      if (_chat == null) {
        return _getFallbackResponse(message);
      }
      // Handle greetings with more interactive response
      if (_isGreeting(message)) {
        final isArabic = _useArabic;
        return isArabic
            ? '''👋 أهلاً وسهلاً! أنا د.عين الحياة، مساعدك المتخصص في صحة العيون.

🔍 يمكنني مساعدتك في:
• تحليل أعراض العين والمشاكل البصرية
• شرح أمراض العيون وأسبابها
• تقديم نصائح للعناية بصحة العين
• توجيهك لأفضل خطوات العلاج

💬 أخبرني: ما هي مشكلة العين التي تواجهها؟ أو هل لديك أي أعراض تقلقك؟

📸 يمكنك أيضاً إرسال صورة للعين إذا كان لديك أي تغيرات مرئية.'''
            : '''👋 Hello! I'm Dr. EyeWise, your specialized eye health assistant.

🔍 I can help you with:
• Analyzing eye symptoms and vision problems
• Explaining eye diseases and their causes
• Providing eye care tips and recommendations
• Guiding you to the best treatment steps

💬 Tell me: What eye problem are you experiencing? Or do you have any symptoms that concern you?

📸 You can also send an eye image if you notice any visible changes.''';
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

  /// Given model probabilities and the original image, ask DeepSeek to provide
  /// a brief second opinion and reasoning. Returns a short text.
  static Future<String> reasonWithModelOutputs({
    required Uint8List imageBytes,
    required Map<String, double> probabilities,
  }) async {
    if (!_isInitialized) {
      try {
        await initialize();
      } catch (e) {
        return _useArabic
            ? 'الخدمة غير مفعلة (لا يوجد HUAWEI_AI_API_KEY).'
            : 'AI service not configured (missing HUAWEI_AI_API_KEY).';
      }
    }

    // Prefer Huawei AI (DeepSeek) if available
    if (_huawei != null) {
      final isArabic = _useArabic;
      final probsList = probabilities.entries
          .map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(1)}%')
          .join(isArabic ? '، ' : ', ');

      final prompt = isArabic
          ? '''هذه هي مخرجات نموذج التنبؤ (احتمالات تقديرية):
$probsList

أنت مساعد ذكاء اصطناعي مختص بطب العيون. قيّم مخرجات النموذج وقدّم رأياً موجزاً:

(1) ما الاحتمال الأكبر ولماذا؟
(2) توصية عملية قصيرة

اختم بـ: "من المهم جدًا زيارة طبيب عيون للتشخيص الدقيق."

ملاحظة: الصورة تم تحليلها بالفعل بواسطة النموذج، والمخرجات أعلاه هي النتيجة.'''
          : '''These are the model output probabilities:
$probsList

You are an ophthalmology AI assistant. Evaluate the model outputs and provide a brief second opinion:

(1) What is the most likely condition and why?
(2) One practical recommendation

End with: "It is very important to visit an ophthalmologist for accurate diagnosis."

Note: The image has already been analyzed by the model, and the outputs above are the result.''';

      try {
        final response = await _huawei!.chat(
          messages: [
            {
              'role': 'system',
              'content': isArabic
                  ? 'أنت مساعد ذكاء اصطناعي مختص بطب العيون. قدم آراء طبية موجزة ومفيدة.'
                  : 'You are an ophthalmology AI assistant. Provide brief and helpful medical opinions.'
            },
            {'role': 'user', 'content': prompt},
          ],
        );
        return response;
      } catch (e) {
        return isArabic ? 'تعذر الحصول على رأي ثانٍ: $e' : 'Unable to get second opinion: $e';
      }
    }

    // Fallback to Gemini if Huawei AI not available
    if (_model == null) {
      return _useArabic
          ? 'الخدمة غير مفعلة (لا يوجد HUAWEI_AI_API_KEY أو GOOGLE_API_KEY).'
          : 'AI service not configured (missing HUAWEI_AI_API_KEY or GOOGLE_API_KEY).';
    }

    final isArabic = _useArabic;
    final probsList = probabilities.entries
        .map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(1)}%')
        .join(isArabic ? '، ' : ', ');

    final head = isArabic
        ? 'هذه هي مخرجات نموذج التنبؤ (احتمالات تقديرية):\n$probsList\n\nقيّم الصورة والمخرجات وقدّم رأياً موجزاً:'
        : 'These are the model output probabilities:\n$probsList\n\nEvaluate the image and outputs and provide a brief second opinion:';

    final tail = isArabic
        ? '\nاختصر الجواب: (1) ما الاحتمال الأكبر ولماذا؟ (2) توصية عملية قصيرة\nاختم بـ: "من المهم جدًا زيارة طبيب عيون للتشخيص الدقيق."'
        : '\nKeep it short: (1) most likely condition and why (2) one practical recommendation\nEnd with: "It is very important to visit an ophthalmologist for accurate diagnosis."';

    final content = [
      Content.text(head + tail),
      Content.data('image/jpeg', imageBytes),
    ];

    try {
      final response = await _model!.generateContent(content);
      return response.text ?? (isArabic ? 'لا توجد إجابة.' : 'No response.');
    } catch (e) {
      return isArabic ? 'تعذر الحصول على رأي ثانٍ: $e' : 'Unable to get second opinion: $e';
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
    // Try backend API first
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/api/questionnaire/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode({'answers': answers}),
      );

      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['success'] == true) {
          return data;
        }
      }
    } catch (e) {
      print('Backend questionnaire API failed: $e, falling back to AI');
    }

    // Fallback to AI if backend fails
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
أنت د.عين الحياة، طبيب عيون متخصص ومتعاطف. المريض يقول: "$userText"

⚠️ تعليمات إلزامية - يجب اتباعها بدقة:

إذا كانت الرسالة متعلقة بالعين (حتى لو كانت بسيطة مثل "عيني وجعاني"):

🔹 ابدأ دائماً بالتعاطف والاهتمام:
"أفهم قلقك بشأن ما تشعر به في عينك" أو "أقدر مشاركتك لهذه المعلومات المهمة"

🔹 اطرح أسئلة متابعة مفصلة (يجب طرح 4-6 أسئلة على الأقل):
• متى بدأت هذه الأعراض بالضبط؟ (اليوم، أمس، منذ أسبوع؟)
• هل المشكلة في العين اليمنى أم اليسرى أم كلاهما؟
• كيف تصف الألم أو الانزعاج؟ (خفيف، متوسط، شديد، مستمر، متقطع)
• هل تشعر بأعراض أخرى مثل: احمرار، حكة، إفرازات، تشويش في الرؤية، حساسية للضوء؟
• هل جربت أي علاج أو قطرات عين؟ وما كانت النتيجة؟
• هل تعاني من أي أمراض مزمنة (سكري، ضغط دم) أو تتناول أدوية؟
• هل تعرضت لأي إصابة أو مادة كيميائية في العين مؤخراً؟

🔹 قدم تحليلاً طبياً مفصلاً:
• اذكر 3-5 أسباب محتملة مرتبة من الأكثر احتمالاً للأقل
• اشرح كل حالة بطريقة مبسطة وواضحة
• اذكر علامات الخطر التي تستدعي زيارة الطوارئ فوراً
• قدم نصائح للعناية المنزلية الآمنة إذا كانت مناسبة

🔹 اختم دائماً بـ: "من المهم جداً زيارة طبيب عيون للتشخيص الدقيق والعلاج المناسب."

إذا كانت الرسالة غير متعلقة بالعين:
"أنا د.عين الحياة، متخصص في صحة العيون. هل لديك أي مشاكل أو أسئلة تخص العين يمكنني مساعدتك بها؟"

⚠️ مهم جداً: لا تعطِ تشخيص نهائي أو تقول "هذا هو التشخيص" - دائماً اطرح أسئلة أولاً واذكر أنها احتمالات تحتاج لفحص طبي.
"""
        : """
You are Dr. EyeWise, a specialized and empathetic ophthalmologist. The patient says: "$userText"

⚠️ MANDATORY INSTRUCTIONS - Follow precisely:

If the message is eye-related (even simple like "my eye hurts"):

🔹 Always start with empathy and care:
"I understand your concern about what you're experiencing with your eye" or "I appreciate you sharing this important information with me"

🔹 Ask detailed follow-up questions (MUST ask 4-6 questions minimum):
• When exactly did these symptoms start? (today, yesterday, a week ago?)
• Is the problem in your right eye, left eye, or both?
• How would you describe the pain or discomfort? (mild, moderate, severe, constant, intermittent)
• Do you have any other symptoms like: redness, itching, discharge, vision changes, light sensitivity?
• Have you tried any treatments or eye drops? What was the result?
• Do you have any chronic conditions (diabetes, high blood pressure) or take medications?
• Have you had any recent eye injury or exposure to chemicals?

🔹 Provide detailed medical analysis:
• List 3-5 possible causes ranked from most likely to least likely
• Explain each condition in simple, clear terms
• Mention warning signs that require immediate emergency care
• Provide safe home care tips if appropriate

🔹 Always end with: "It is very important to visit an ophthalmologist for accurate diagnosis and proper treatment."

If clearly unrelated to eyes:
"I'm Dr. EyeWise, specializing in eye health. Do you have any eye problems or questions I can help you with?"

⚠️ CRITICAL: Never give definitive diagnosis or say "this is the diagnosis" - always ask questions first and mention these are possibilities that need medical examination.
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
      print('Chat conversation reset with updated instructions');
    }
  }

  /// Force reinitialize the AI model with updated instructions
  static Future<void> forceReinitialize() async {
    _isInitialized = false;
    _model = null;
    _chat = null;
    await initialize();
    print('AI model forcefully reinitialized with new instructions');
  }

  /// Get fallback response when AI service is not available
  static String _getFallbackResponse(String message) {
    final isArabic = _useArabic;
    
    // Check if it's a greeting
    if (_isGreeting(message)) {
      return isArabic
          ? '''👋 أهلاً وسهلاً! أنا د.عين الحياة، مساعدك المتخصص في صحة العيون.

🔍 يمكنني مساعدتك في:
• تحليل أعراض العين والمشاكل البصرية
• شرح أمراض العيون وأسبابها
• تقديم نصائح للعناية بصحة العين
• توجيهك لأفضل خطوات العلاج

💬 أخبرني: ما هي مشكلة العين التي تواجهها؟ أو هل لديك أي أعراض تقلقك؟

📸 يمكنك أيضاً إرسال صورة للعين إذا كان لديك أي تغيرات مرئية.'''
          : '''👋 Hello! I'm Dr. EyeWise, your specialized eye health assistant.

🔍 I can help you with:
• Analyzing eye symptoms and vision problems
• Explaining eye diseases and their causes
• Providing eye care tips and recommendations
• Guiding you to the best treatment steps

💬 Tell me: What eye problem are you experiencing? Or do you have any symptoms that concern you?

📸 You can also send an eye image if you notice any visible changes.''';
    }

    // Check if it's eye-related
    final eyeKeywords = isArabic 
        ? [
            'عين','العين','عيني','عينى','ألم','ألم العين','وجع','وجعان','وجعاني','احمرار','احمر','حمرا',
            'جفاف','جافة','رؤية','ضبابية','ضباب','غباش','صداع','حكة','حكان','التهاب','ملتهبة',
            'قرنية','شبكية','الشبكية','عدسة','جلوكوما','زرق','كتاركت','ماء بيضاء','ماء أبيض',
            'التهاب القزحية','التهاب الملتحمة','التهاب الجفن','حساسية العين','حساسية',
            'اعتلال الشبكية السكري','تنكس بقعي','القرنية المخروطية','التهاب القرنية',
            'رتينيتس بيغمينتوزا','التهاب الصلبة','انسداد القناة الدمعية','دموع','دمع',
            'تعب العين','إجهاد','تعبانة','مؤلمة','تحرق','حرقان','حرقة','لسعة','وخز',
            'إفرازات','صديد','عماص','غمص','تورم','انتفاخ','منتفخة','متورمة',
            'زغللة','عدم وضوح','تشويش','ظلال','نقاط','بقع','خيوط','ذباب','فلاش'
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
        return '''أفهم قلقك بشأن أعراض العين التي تواجهها. 

🔍 الأعراض التي ذكرتها قد تشير إلى عدة حالات محتملة:

**الأسباب الشائعة:**
• التهاب الملتحمة - احمرار وإفرازات
• جفاف العين - حكة وحرقان
• إجهاد العين - من الشاشات والقراءة
• التهاب الجفن - تورم وألم في الجفون
• حساسية العين - حكة موسمية

**لفهم حالتك أكثر، أحتاج معرفة:**
• متى بدأت هذه الأعراض؟
• هل الأعراض في عين واحدة أم الاثنتين؟
• هل تشعر بألم أم مجرد انزعاج؟
• هل لاحظت أي تغيرات في الرؤية؟
• هل جربت أي قطرات أو علاجات؟

**علامات تستدعي زيارة طبيب فورية:**
🚨 ألم شديد مفاجئ
🚨 فقدان الرؤية أو تشويش شديد
🚨 رؤية أضواء وامضة
🚨 إفرازات صفراء أو خضراء كثيفة

⚠️ من المهم جداً زيارة طبيب عيون للتشخيص الدقيق والعلاج المناسب.''';
      } else {
        return '''I understand your concern about the eye symptoms you're experiencing.

🔍 The symptoms you mentioned may indicate several possible conditions:

**Common causes:**
• Conjunctivitis - redness and discharge
• Dry eye syndrome - itching and burning
• Eye strain - from screens and reading
• Blepharitis - swelling and pain in eyelids
• Eye allergy - seasonal itching

**To better understand your condition, I need to know:**
• When did these symptoms start?
• Are the symptoms in one eye or both?
• Do you feel pain or just discomfort?
• Have you noticed any vision changes?
• Have you tried any drops or treatments?

**Warning signs requiring immediate medical attention:**
🚨 Sudden severe pain
🚨 Vision loss or severe blurriness
🚨 Flashing lights
🚨 Heavy yellow or green discharge

⚠️ It is very important to visit an ophthalmologist for accurate diagnosis and proper treatment.''';
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
