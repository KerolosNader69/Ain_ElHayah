// Use built-in fetch (Node 18+) or fallback to https
let fetch;
try {
  fetch = globalThis.fetch;
  if (!fetch) throw new Error('No fetch');
} catch (e) {
  console.log('Using https module for requests...');
  const https = require('https');
  const http = require('http');
  
  fetch = (url, options = {}) => {
    return new Promise((resolve, reject) => {
      const urlObj = new URL(url);
      const protocol = urlObj.protocol === 'https:' ? https : http;
      
      const req = protocol.request({
        hostname: urlObj.hostname,
        port: urlObj.port,
        path: urlObj.pathname,
        method: options.method || 'GET',
        headers: options.headers || {},
      }, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          resolve({
            status: res.statusCode,
            statusCode: res.statusCode,
            json: async () => JSON.parse(data),
          });
        });
      });
      
      req.on('error', reject);
      if (options.body) req.write(options.body);
      req.end();
    });
  };
}

console.log('\n🧪 Testing New APIs\n');

// Test 1: Questionnaire Analysis
async function testQuestionnaireAnalysis() {
  console.log('='.repeat(60));
  console.log('Test 1: Questionnaire Analysis API');
  console.log('='.repeat(60));

  const sampleAnswers = {
    for_whom: 'self',
    gender: 'male',
    age: { years: 45, months: 0, days: 0 },
    recent_injury: 'no',
    smoking_10y: 'no',
    family_allergy: 'yes',
    obesity: 'no',
    diabetes: 'yes',
    hypertension: 'yes',
    headache: { type: 'Eye strain', severity: 'Moderate' },
    other_symptoms: 'Blurry vision, dry eyes, redness',
    country: 'Egypt',
    locale: 'en',
  };

  try {
    const response = await fetch('http://localhost:3001/api/questionnaire/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ answers: sampleAnswers }),
    });

    const data = await response.json();
    console.log(`\nStatus: ${response.status}`);
    console.log('\nResponse:');
    console.log(JSON.stringify(data, null, 2));

    if (data.success && data.conditions) {
      console.log(`\n✅ Test PASSED - Found ${data.conditions.length} conditions`);
    } else {
      console.log('\n❌ Test FAILED - Invalid response format');
    }
  } catch (error) {
    console.log(`\n❌ Test FAILED - Error: ${error.message}`);
  }
}

// Test 2: Mock Retinal Analysis
async function testRetinalAnalysis() {
  console.log('\n' + '='.repeat(60));
  console.log('Test 2: Mock Retinal Analysis API');
  console.log('='.repeat(60));

  // Create a small base64 image (1x1 pixel PNG)
  const mockImageBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

  try {
    const response = await fetch('http://localhost:3001/api/retinal/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ imageBase64: mockImageBase64 }),
    });

    const data = await response.json();
    console.log(`\nStatus: ${response.status}`);
    console.log('\nResponse:');
    console.log(JSON.stringify(data, null, 2));

    if (data.success && data.conditions) {
      console.log(`\n✅ Test PASSED - Found ${data.conditions.length} conditions`);
      console.log(`   Confidence: ${(data.confidence * 100).toFixed(1)}%`);
    } else {
      console.log('\n❌ Test FAILED - Invalid response format');
    }
  } catch (error) {
    console.log(`\n❌ Test FAILED - Error: ${error.message}`);
  }
}

// Run all tests
async function runAllTests() {
  console.log('Make sure backend is running: cd backend && node server.js\n');
  
  await testQuestionnaireAnalysis();
  await testRetinalAnalysis();

  console.log('\n' + '='.repeat(60));
  console.log('All tests complete!');
  console.log('='.repeat(60));
  console.log('\n💡 Next steps:');
  console.log('1. Run Flutter app: flutter run -d chrome');
  console.log('2. Try the questionnaire feature');
  console.log('3. Try the retinal diagnosis feature');
  console.log('');
}

runAllTests();
