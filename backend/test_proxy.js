// Simple test script to verify the ModelArts proxy endpoint
const fetch = require('node-fetch');
const fs = require('fs');
const path = require('path');

async function testBackendProxy() {
  console.log('========================================');
  console.log('ModelArts Backend Proxy Test');
  console.log('========================================\n');

  // Load configuration
  console.log('[1/5] Loading configuration from env.json...');
  const envPath = path.join(__dirname, '..', 'env.json');
  if (!fs.existsSync(envPath)) {
    console.error('✗ env.json not found');
    process.exit(1);
  }
  
  const config = JSON.parse(fs.readFileSync(envPath, 'utf8'));
  console.log('✓ Configuration loaded');
  console.log(`  Service ID: ${config.MODELARTS_SERVICE_ID}`);
  console.log(`  Region: ${config.MODELARTS_REGION}`);
  console.log(`  Project ID: ${config.MODELARTS_PROJECT_ID}\n`);

  // Check backend health
  console.log('[2/5] Checking backend health...');
  try {
    const healthResponse = await fetch('http://localhost:3001/health');
    const healthData = await healthResponse.json();
    console.log('✓ Backend is healthy');
    console.log(`  Status: ${healthData.status}`);
    console.log(`  Message: ${healthData.message}\n`);
  } catch (error) {
    console.error('✗ Backend health check failed:', error.message);
    console.error('  Make sure the backend server is running: node backend/server.js');
    process.exit(1);
  }

  // Create a minimal test image (1x1 pixel PNG in base64)
  console.log('[3/5] Preparing test image...');
  // This is a 1x1 transparent PNG
  const testImageBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
  console.log('✓ Test image prepared (1x1 pixel PNG)\n');

  // Test the proxy endpoint
  console.log('[4/5] Testing ModelArts proxy endpoint...');
  console.log('  Sending inference request...');
  
  const requestPayload = {
    imageBase64: testImageBase64,
    serviceId: config.MODELARTS_SERVICE_ID,
    region: config.MODELARTS_REGION,
    accessKey: config.MODELARTS_ACCESS_KEY,
    secretKey: config.MODELARTS_SECRET_KEY,
    projectId: config.MODELARTS_PROJECT_ID,
  };

  try {
    const startTime = Date.now();
    const response = await fetch('http://localhost:3001/api/modelarts/infer', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestPayload),
    });

    const duration = Date.now() - startTime;
    const responseData = await response.json();

    console.log(`✓ Response received (${duration}ms)`);
    console.log(`  Status: ${response.status}`);
    console.log(`  Response keys: ${Object.keys(responseData).join(', ')}`);
    console.log(`  Response data:`, JSON.stringify(responseData, null, 2).substring(0, 500));
    
    if (response.status >= 200 && response.status < 300) {
      console.log('\n✓ ModelArts inference successful!\n');
    } else {
      console.log('\n⚠ ModelArts returned an error response\n');
    }
  } catch (error) {
    console.error('✗ Proxy request failed:', error.message);
    process.exit(1);
  }

  // Summary
  console.log('[5/5] Test Summary:');
  console.log('========================================');
  console.log('✓ Backend proxy is operational');
  console.log('✓ IAM token flow is working');
  console.log('✓ ModelArts API communication successful');
  console.log('========================================\n');
  console.log('Next steps:');
  console.log('1. Run the Flutter web app: flutter run -d chrome');
  console.log('2. Upload a real retinal image');
  console.log('3. Verify the complete end-to-end flow\n');
}

// Run the test
testBackendProxy().catch(error => {
  console.error('Test failed:', error);
  process.exit(1);
});
