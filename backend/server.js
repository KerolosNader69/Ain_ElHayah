const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');
const { register, login } = require('./authController');

const app = express();
const PORT = 3001;

// Middleware
app.use(cors()); // Enable CORS for all origins
app.use(express.json()); // Parse JSON request bodies

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Server is running',
    timestamp: new Date().toISOString(),
  });
});

// Signup endpoint - uses authController
app.post('/api/signup', register);

// ModelArts IAM Token Cache
let tokenCache = null;
let tokenExpiresAt = 0;

async function getIAMToken(username, password, domain, projectId, region) {
  const now = Date.now();
  if (tokenCache && now < tokenExpiresAt) {
    console.log(`[${new Date().toISOString()}] Using cached IAM token`);
    return tokenCache;
  }

  console.log(`[${new Date().toISOString()}] Obtaining new IAM token...`);
  console.log(`[${new Date().toISOString()}] Authenticating as: ${username}@${domain}`);
  const iamUrl = `https://iam.${region}.myhuaweicloud.com/v3/auth/tokens`;
  
  // Use password method with username/password/domain
  const body = {
    auth: {
      identity: {
        methods: ['password'],
        password: {
          user: {
            name: username,
            password: password,
            domain: { name: domain }
          }
        }
      },
      scope: { project: { id: projectId } }
    }
  };

  const response = await fetch(iamUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });

  const token = response.headers.get('x-subject-token') || response.headers.get('X-Subject-Token');
  
  if (!token) {
    const errorText = await response.text();
    console.error(`[${new Date().toISOString()}] IAM authentication failed (status: ${response.status})`);
    console.error(`[${new Date().toISOString()}] Error: ${errorText}`);
    throw new Error(`Failed to obtain IAM token (status: ${response.status}): ${errorText}`);
  }

  // Cache token for 23 hours
  tokenCache = token;
  tokenExpiresAt = now + 23 * 3600 * 1000;
  console.log(`[${new Date().toISOString()}] IAM token obtained successfully`);
  return token;
}

// Load env.json for ModelArts configuration
const fs = require('fs');
const path = require('path');
let envConfig = {};
try {
  const envPath = path.join(__dirname, '..', 'env.json');
  const envData = fs.readFileSync(envPath, 'utf8');
  envConfig = JSON.parse(envData);
  console.log(`[${new Date().toISOString()}] Loaded env.json configuration`);
} catch (error) {
  console.warn(`[${new Date().toISOString()}] Warning: Could not load env.json:`, error.message);
}

// ModelArts inference proxy endpoint with IAM authentication
app.post('/api/modelarts/infer', async (req, res) => {
  try {
    let { imageBase64, serviceId, region, accessKey, secretKey, projectId } = req.body;

    // If credentials not provided in request, use env.json
    if (!serviceId || !region || !projectId) {
      console.log(`[${new Date().toISOString()}] Using credentials from env.json`);
      serviceId = serviceId || envConfig.MODELARTS_SERVICE_ID;
      region = region || envConfig.MODELARTS_REGION;
      projectId = projectId || envConfig.MODELARTS_PROJECT_ID;
    }

    // Get username/password/domain from env.json
    const username = envConfig.MODELARTS_USERNAME;
    const password = envConfig.MODELARTS_PASSWORD;
    const domain = envConfig.MODELARTS_DOMAIN || username;

    if (!imageBase64 || !serviceId || !region || !projectId || !username || !password) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields for ModelArts inference',
        details: {
          hasImage: !!imageBase64,
          hasServiceId: !!serviceId,
          hasRegion: !!region,
          hasProjectId: !!projectId,
          hasUsername: !!username,
          hasPassword: !!password,
        },
      });
    }

    console.log(`[${new Date().toISOString()}] POST /api/modelarts/infer - Service: ${serviceId}, Region: ${region}`);

    // Get IAM token using username/password
    const token = await getIAMToken(username, password, domain, projectId, region);

    // Construct ModelArts URL
    const modelArtsUrl = `https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/c3ea302b-d98b-4f80-85bb-552e9ca8e0c9`;

    // Prepare headers
    const headers = {
      'Content-Type': 'application/json',
      'X-Project-Id': projectId,
    };

    // Only add IAM token if we have one
    if (token) {
      headers['X-Auth-Token'] = token;
      console.log(`[${new Date().toISOString()}] Using IAM token for authentication`);
    } else {
      console.log(`[${new Date().toISOString()}] Attempting ModelArts call without IAM token`);
    }

    // Forward request to ModelArts
    const response = await fetch(modelArtsUrl, {
      method: 'POST',
      headers: headers,
      body: JSON.stringify({
        image: imageBase64,
      }),
    });

    const responseData = await response.json();
    console.log(`[${new Date().toISOString()}] ModelArts Response Status: ${response.status}`);
    console.log(`[${new Date().toISOString()}] ModelArts Response:`, JSON.stringify(responseData).substring(0, 500));

    // If ModelArts returned an error, log it in detail
    if (response.status >= 400) {
      console.error(`[${new Date().toISOString()}] ModelArts Error Details:`, JSON.stringify(responseData, null, 2));
    }

    res.status(response.status).json(responseData);
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Error in /api/modelarts/infer:`, error.message);
    console.error(`[${new Date().toISOString()}] Error stack:`, error.stack);
    res.status(500).json({
      success: false,
      error: 'ModelArts inference failed',
      message: error.message,
    });
  }
});

// Voice Chat endpoint - SIS integration
const SisWebSocketManager = require('./sis_websocket_manager');

// Middleware for raw audio data
app.use('/api/voice-chat', express.raw({ type: 'audio/wav', limit: '10mb' }));

app.post('/api/voice-chat', async (req, res) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] POST /api/voice-chat - Received audio data`);

  try {
    // Validate audio data
    if (!req.body || req.body.length === 0) {
      console.error(`[${timestamp}] No audio data received`);
      return res.status(400).json({
        success: false,
        error: 'No audio data provided',
      });
    }

    console.log(`[${timestamp}] Audio data size: ${req.body.length} bytes`);

    // Get SIS configuration from env.json
    const sisEndpoint = envConfig.SIS_ENDPOINT;
    const sisProjectId = envConfig.SIS_PROJECT_ID;
    const sisProperty = envConfig.SIS_PROPERTY || 'english_16k_general';
    
    // Get credentials for IAM token
    const username = envConfig.MODELARTS_USERNAME;
    const password = envConfig.MODELARTS_PASSWORD;
    const domain = envConfig.MODELARTS_DOMAIN || username;
    const region = envConfig.MODELARTS_REGION;

    if (!sisEndpoint || !sisProjectId || !username || !password) {
      console.error(`[${timestamp}] Missing SIS configuration`);
      return res.status(500).json({
        success: false,
        error: 'SIS configuration incomplete',
        details: {
          hasEndpoint: !!sisEndpoint,
          hasProjectId: !!sisProjectId,
          hasUsername: !!username,
          hasPassword: !!password,
        },
      });
    }

    // Get IAM token for SIS authentication
    console.log(`[${timestamp}] Obtaining IAM token for SIS...`);
    const iamToken = await getIAMToken(username, password, domain, sisProjectId, region);

    // Strip WAV header if present (SIS expects raw PCM data)
    let audioData = req.body;
    if (audioData.length > 44 && 
        audioData.toString('utf8', 0, 4) === 'RIFF' &&
        audioData.toString('utf8', 8, 12) === 'WAVE') {
      console.log(`[${timestamp}] Detected WAV file, stripping 44-byte header`);
      console.log(`[${timestamp}] Original size: ${audioData.length} bytes`);
      audioData = audioData.slice(44);
      console.log(`[${timestamp}] PCM data size: ${audioData.length} bytes`);
    } else {
      console.log(`[${timestamp}] No WAV header detected, using audio data as-is`);
    }

    // Create SIS WebSocket manager
    const sisManager = new SisWebSocketManager(sisEndpoint, sisProjectId, iamToken);

    // Transcribe audio
    console.log(`[${timestamp}] Starting transcription with property: ${sisProperty}`);
    const transcribedText = await sisManager.transcribe(audioData, sisProperty);
    console.log(`[${timestamp}] Transcription result: "${transcribedText}"`);

    // TODO: Send transcribed text to chatbot service
    // For now, return a placeholder bot reply
    const botReply = `You said: "${transcribedText}". Chatbot integration coming soon!`;

    // Return response
    res.status(200).json({
      success: true,
      userText: transcribedText,
      botReply: botReply,
    });

  } catch (error) {
    const errorTimestamp = new Date().toISOString();
    console.error(`[${errorTimestamp}] Error in /api/voice-chat:`, error.message);
    console.error(`[${errorTimestamp}] Error stack:`, error.stack);

    // Determine appropriate status code
    let statusCode = 500;
    let errorMessage = 'Voice chat processing failed';

    if (error.message.includes('timeout')) {
      statusCode = 504;
      errorMessage = 'Transcription timeout';
    } else if (error.message.includes('WebSocket')) {
      statusCode = 503;
      errorMessage = 'SIS service unavailable';
    } else if (error.message.includes('SIS Error')) {
      statusCode = 502;
      errorMessage = 'Transcription failed';
    } else if (error.message.includes('IAM token')) {
      statusCode = 500;
      errorMessage = 'Authentication failed';
    }

    res.status(statusCode).json({
      success: false,
      error: errorMessage,
      details: {
        message: error.message,
        stage: 'transcription',
      },
    });
  }
});

// Login endpoint - uses authController
app.post('/api/login', login);

// Questionnaire Analysis API with DeepSeek AI
app.post('/api/questionnaire/analyze', async (req, res) => {
  try {
    const { answers } = req.body;
    console.log(`[${new Date().toISOString()}] POST /api/questionnaire/analyze`);

    if (!answers) {
      return res.status(400).json({
        success: false,
        error: 'Missing questionnaire answers',
      });
    }

    // Try DeepSeek AI analysis first
    const huaweiApiKey = envConfig.HUAWEI_AI_API_KEY;
    const huaweiBaseUrl = envConfig.HUAWEI_AI_BASE_URL || 'https://api.huawei-competition.ai';
    const huaweiModel = envConfig.HUAWEI_AI_MODEL || 'deepseek-v3.1';

    if (huaweiApiKey) {
      try {
        console.log(`[${new Date().toISOString()}] Using DeepSeek AI for questionnaire analysis`);
        
        // Build comprehensive prompt for DeepSeek
        const age = answers.age || {};
        const totalAge = (age.years || 0) + (age.months || 0) / 12;
        const isArabic = answers.locale === 'ar';
        
        const prompt = isArabic ? `أنت طبيب عيون متخصص. حلل الاستبيان التالي وقدم تشخيصاً دقيقاً.

**معلومات المريض:**
- العمر: ${age.years} سنة ${age.months} شهر
- النوع: ${answers.gender === 'male' ? 'ذكر' : 'أنثى'}
- إصابة حديثة: ${answers.recent_injury}
- تدخين 10+ سنوات: ${answers.smoking_10y}
- تاريخ عائلي للحساسية: ${answers.family_allergy}
- السمنة: ${answers.obesity}
- السكري: ${answers.diabetes}
- ارتفاع ضغط الدم: ${answers.hypertension}
- نوع الصداع: ${answers.headache?.type || 'لا يوجد'}
- شدة الصداع: ${answers.headache?.severity || 'لا يوجد'}
- أعراض أخرى: ${answers.other_symptoms || 'لا يوجد'}
- البلد: ${answers.country || 'غير محدد'}

**المطلوب:**
قدم تحليلاً طبياً شاملاً بصيغة JSON فقط (بدون نص إضافي):

{
  "conditions": [
    {"name": "اسم الحالة", "probability": 0.85, "rationale": "السبب الطبي"}
  ],
  "recommendations": ["نصيحة طبية 1", "نصيحة 2"],
  "red_flags": ["علامة خطر إن وجدت"]
}

**ملاحظات:**
- probability بين 0 و 1
- ركز على أمراض العيون فقط
- اذكر 3-7 حالات محتملة
- رتب حسب الاحتمالية (الأعلى أولاً)
- اذكر علامات الخطر إن وجدت` : `You are a specialized ophthalmologist. Analyze the following questionnaire and provide an accurate diagnosis.

**Patient Information:**
- Age: ${age.years} years ${age.months} months
- Gender: ${answers.gender}
- Recent injury: ${answers.recent_injury}
- Smoking 10+ years: ${answers.smoking_10y}
- Family allergy history: ${answers.family_allergy}
- Obesity: ${answers.obesity}
- Diabetes: ${answers.diabetes}
- Hypertension: ${answers.hypertension}
- Headache type: ${answers.headache?.type || 'none'}
- Headache severity: ${answers.headache?.severity || 'none'}
- Other symptoms: ${answers.other_symptoms || 'none'}
- Country: ${answers.country || 'not specified'}

**Required:**
Provide a comprehensive medical analysis in JSON format ONLY (no additional text):

{
  "conditions": [
    {"name": "Condition Name", "probability": 0.85, "rationale": "Medical reasoning"}
  ],
  "recommendations": ["Medical advice 1", "Advice 2"],
  "red_flags": ["Warning sign if any"]
}

**Notes:**
- probability between 0 and 1
- Focus on eye conditions only
- List 3-7 probable conditions
- Sort by probability (highest first)
- Mention red flags if any`;

        const deepseekResponse = await fetch(`${huaweiBaseUrl}/v1/chat/completions`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${huaweiApiKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            model: huaweiModel,
            messages: [
              {
                role: 'system',
                content: isArabic 
                  ? 'أنت طبيب عيون متخصص. قدم تحليلاً طبياً دقيقاً بصيغة JSON فقط.'
                  : 'You are a specialized ophthalmologist. Provide accurate medical analysis in JSON format only.'
              },
              {
                role: 'user',
                content: prompt
              }
            ],
            temperature: 0.7,
          }),
        });

        if (deepseekResponse.ok) {
          const data = await deepseekResponse.json();
          const content = data.choices?.[0]?.message?.content;
          
          if (content) {
            console.log(`[${new Date().toISOString()}] DeepSeek response received`);
            
            // Extract JSON from response
            const jsonMatch = content.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
              const analysis = JSON.parse(jsonMatch[0]);
              
              // Validate and format response
              if (analysis.conditions && Array.isArray(analysis.conditions)) {
                const response = {
                  success: true,
                  conditions: analysis.conditions,
                  recommendations: analysis.recommendations || [],
                  red_flags: analysis.red_flags || [],
                  disclaimer: isArabic
                    ? 'هذا تقييم أولي بمساعدة الذكاء الاصطناعي. استشر دائماً طبيب عيون مؤهل للتشخيص الدقيق والعلاج.'
                    : 'This is an AI-assisted preliminary assessment. Always consult with a qualified ophthalmologist for accurate diagnosis and treatment.',
                  ai_powered: true,
                  model: 'DeepSeek AI',
                };
                
                console.log(`[${new Date().toISOString()}] DeepSeek analysis complete: ${analysis.conditions.length} conditions`);
                return res.json(response);
              }
            }
          }
        }
        
        console.log(`[${new Date().toISOString()}] DeepSeek analysis failed, falling back to rule-based`);
      } catch (aiError) {
        console.error(`[${new Date().toISOString()}] DeepSeek AI error:`, aiError.message);
        console.log(`[${new Date().toISOString()}] Falling back to rule-based analysis`);
      }
    } else {
      console.log(`[${new Date().toISOString()}] No Huawei AI key, using rule-based analysis`);
    }

    // Fallback: Rule-based analysis
    const age = answers.age || {};
    const totalAge = (age.years || 0) + (age.months || 0) / 12 + (age.days || 0) / 365;
    const symptoms = answers.other_symptoms || '';
    const headache = answers.headache || {};
    const conditions = [];
    
    if (answers.diabetes === 'yes') {
      conditions.push({
        name: 'Diabetic Retinopathy Risk',
        probability: 0.65,
        rationale: 'Patient has diabetes, which increases risk of retinal damage',
      });
    }
    
    if (answers.hypertension === 'yes') {
      conditions.push({
        name: 'Hypertensive Retinopathy Risk',
        probability: 0.55,
        rationale: 'High blood pressure can affect retinal blood vessels',
      });
    }
    
    if (headache.type === 'Eye strain' || symptoms.toLowerCase().includes('strain') || symptoms.toLowerCase().includes('tired')) {
      conditions.push({
        name: 'Computer Vision Syndrome',
        probability: 0.70,
        rationale: 'Symptoms suggest eye strain from prolonged screen use',
      });
    }
    
    if (headache.type === 'Migraine') {
      conditions.push({
        name: 'Migraine-Associated Visual Disturbances',
        probability: 0.60,
        rationale: 'Migraines can cause temporary vision changes',
      });
    }
    
    if (symptoms.toLowerCase().includes('dry') || symptoms.toLowerCase().includes('irritat')) {
      conditions.push({
        name: 'Dry Eye Syndrome',
        probability: 0.65,
        rationale: 'Symptoms consistent with dry eye condition',
      });
    }
    
    if (answers.family_allergy === 'yes' && (symptoms.toLowerCase().includes('itch') || symptoms.toLowerCase().includes('red'))) {
      conditions.push({
        name: 'Allergic Conjunctivitis',
        probability: 0.60,
        rationale: 'Family history of allergies with eye symptoms',
      });
    }
    
    if (totalAge > 40) {
      conditions.push({
        name: 'Presbyopia',
        probability: 0.50,
        rationale: 'Age-related difficulty focusing on near objects',
      });
    }
    
    if (totalAge > 60) {
      conditions.push({
        name: 'Age-Related Macular Degeneration Risk',
        probability: 0.40,
        rationale: 'Increased risk with age, especially if smoking history',
      });
    }
    
    if (totalAge > 40 && (answers.diabetes === 'yes' || answers.hypertension === 'yes')) {
      conditions.push({
        name: 'Glaucoma Risk',
        probability: 0.45,
        rationale: 'Age and systemic conditions increase glaucoma risk',
      });
    }
    
    if (conditions.length === 0) {
      conditions.push({
        name: 'General Eye Examination Recommended',
        probability: 0.80,
        rationale: 'Routine eye check recommended based on symptoms',
      });
    }
    
    conditions.sort((a, b) => b.probability - a.probability);
    
    const recommendations = [
      'Schedule a comprehensive eye examination with an ophthalmologist',
    ];
    
    if (answers.diabetes === 'yes' || answers.hypertension === 'yes') {
      recommendations.push('Regular eye screenings are crucial for managing systemic conditions');
    }
    
    if (headache.type === 'Eye strain') {
      recommendations.push('Follow the 20-20-20 rule: Every 20 minutes, look at something 20 feet away for 20 seconds');
      recommendations.push('Ensure proper lighting and screen positioning');
    }
    
    if (symptoms.toLowerCase().includes('dry')) {
      recommendations.push('Use artificial tears and maintain good hydration');
      recommendations.push('Consider a humidifier in dry environments');
    }
    
    const redFlags = [];
    
    if (answers.recent_injury === 'yes') {
      redFlags.push('⚠️ Recent eye injury requires immediate medical attention');
    }
    
    if (symptoms.toLowerCase().includes('sudden') || symptoms.toLowerCase().includes('loss')) {
      redFlags.push('⚠️ Sudden vision changes require urgent evaluation');
    }
    
    if (headache.severity === 'Severe') {
      redFlags.push('⚠️ Severe headaches with vision symptoms need prompt assessment');
    }
    
    const response = {
      success: true,
      conditions,
      recommendations,
      red_flags: redFlags,
      disclaimer: 'This is an AI-assisted preliminary assessment. Always consult with a qualified ophthalmologist for accurate diagnosis and treatment.',
      ai_powered: false,
      model: 'Rule-based',
    };
    
    console.log(`[${new Date().toISOString()}] Rule-based analysis complete: ${conditions.length} conditions identified`);
    res.json(response);
    
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Error in /api/questionnaire/analyze:`, error);
    res.status(500).json({
      success: false,
      error: 'Questionnaire analysis failed',
      message: error.message,
    });
  }
});

// Mock Retinal Analysis API (since ModelArts isn't working)
app.post('/api/retinal/analyze', async (req, res) => {
  try {
    const { imageBase64 } = req.body;
    console.log(`[${new Date().toISOString()}] POST /api/retinal/analyze`);

    if (!imageBase64) {
      return res.status(400).json({
        success: false,
        error: 'Missing retinal image',
      });
    }

    // Simulate processing delay
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Mock analysis result
    const mockResult = {
      success: true,
      confidence: 0.87,
      conditions: [
        {
          name: 'Diabetic Retinopathy',
          severity: 'Mild',
          confidence: 0.72,
          description: 'Early signs of diabetic retinopathy detected',
        },
        {
          name: 'Microaneurysms',
          severity: 'Mild',
          confidence: 0.68,
          description: 'Small vascular abnormalities present',
        },
      ],
      recommendations: [
        'Schedule follow-up examination in 6 months',
        'Maintain good blood sugar control',
        'Regular monitoring recommended',
        'Consult with ophthalmologist for detailed assessment',
      ],
      analysis_date: new Date().toISOString(),
      model_version: 'mock-v1.0',
      disclaimer: '⚠️ This is a MOCK result for testing purposes. Real ModelArts integration is not active.',
    };

    console.log(`[${new Date().toISOString()}] Mock retinal analysis complete`);
    res.json(mockResult);
    
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Error in /api/retinal/analyze:`, error);
    res.status(500).json({
      success: false,
      error: 'Retinal analysis failed',
      message: error.message,
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log('\n' + '='.repeat(60));
  console.log('🚀 Eye Wise Connect Backend Server');
  console.log('='.repeat(60));
  console.log(`📍 Server URL:        http://localhost:${PORT}`);
  console.log(`🏥 Health Check:       http://localhost:${PORT}/health`);
  console.log(`📝 Available Endpoints:`);
  console.log(`   - GET  /health`);
  console.log(`   - POST /api/signup (with bcrypt password hashing)`);
  console.log(`   - POST /api/login (with bcrypt password verification)`);
  console.log(`   - POST /api/modelarts/infer`);
  console.log(`   - POST /api/voice-chat (SIS speech-to-text + chatbot)`);
  console.log(`   - POST /api/questionnaire/analyze (NEW - AI questionnaire analysis)`);
  console.log(`   - POST /api/retinal/analyze (NEW - Mock retinal analysis)`);
  console.log('='.repeat(60));
  console.log(`✅ Server is running on port ${PORT}\n`);
});

