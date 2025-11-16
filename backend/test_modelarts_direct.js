// Test ModelArts API directly to diagnose issues
const fetch = require('node-fetch');
const fs = require('fs');
const path = require('path');

// Load env.json
const envPath = path.join(__dirname, '..', 'env.json');
const envData = JSON.parse(fs.readFileSync(envPath, 'utf8'));

const {
  MODELARTS_USERNAME,
  MODELARTS_PASSWORD,
  MODELARTS_DOMAIN,
  MODELARTS_PROJECT_ID,
  MODELARTS_SERVICE_ID,
  MODELARTS_REGION,
} = envData;

console.log('\n========================================');
console.log('ModelArts Direct API Test');
console.log('========================================\n');

console.log('Configuration:');
console.log(`  Username: ${MODELARTS_USERNAME}`);
console.log(`  Domain: ${MODELARTS_DOMAIN || MODELARTS_USERNAME}`);
console.log(`  Project ID: ${MODELARTS_PROJECT_ID}`);
console.log(`  Service ID: ${MODELARTS_SERVICE_ID}`);
console.log(`  Region: ${MODELARTS_REGION}`);
console.log('');

async function getIAMToken() {
  console.log('[1/3] Obtaining IAM token...');
  const iamUrl = `https://iam.${MODELARTS_REGION}.myhuaweicloud.com/v3/auth/tokens`;
  
  const domain = MODELARTS_DOMAIN || MODELARTS_USERNAME;
  console.log(`  Authenticating as: ${MODELARTS_USERNAME}@${domain}`);
  
  const body = {
    auth: {
      identity: {
        methods: ['password'],
        password: {
          user: {
            name: MODELARTS_USERNAME,
            password: MODELARTS_PASSWORD,
            domain: { name: domain }
          }
        }
      },
      scope: {
        project: { id: MODELARTS_PROJECT_ID }
      }
    }
  };

  try {
    const response = await fetch(iamUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });

    const token = response.headers.get('x-subject-token');
    
    if (token) {
      console.log('  ✓ IAM token obtained successfully');
      console.log(`  Token: ${token.substring(0, 20)}...`);
      return token;
    }

    // Failed to get token
    console.error('  ✗ Failed to get IAM token');
    console.error('  Response status:', response.status);
    const errorBody = await response.text();
    console.error('  Response body:', errorBody);
    return null;
  } catch (error) {
    console.error('  ✗ Error obtaining IAM token:', error.message);
    return null;
  }
}

async function testModelArtsInference(token) {
  console.log('\n[2/3] Testing ModelArts inference...');
  
  // Create a small test image (1x1 pixel PNG in base64)
  const testImage = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
  
  const modelArtsUrl = `https://infer-modelarts-${MODELARTS_REGION}.modelarts-infer.com/v1/infers/${MODELARTS_SERVICE_ID}`;
  
  console.log(`  URL: ${modelArtsUrl}`);
  console.log(`  Payload: {"image": "<base64_image>"}`);
  
  if (!token) {
    console.error('  ✗ No IAM token available, cannot test inference');
    return false;
  }
  
  try {
    const headers = {
      'Content-Type': 'application/json',
      'X-Auth-Token': token,
      'X-Project-Id': MODELARTS_PROJECT_ID,
    };
    
    console.log('  Using IAM token authentication');

    const response = await fetch(modelArtsUrl, {
      method: 'POST',
      headers: headers,
      body: JSON.stringify({
        image: testImage,
      }),
    });

    console.log(`  Response status: ${response.status}`);
    
    const responseData = await response.json();
    console.log('  Response body:', JSON.stringify(responseData, null, 2));
    
    if (response.status >= 200 && response.status < 300) {
      console.log('  ✓ ModelArts inference successful');
      return true;
    } else {
      console.error('  ✗ ModelArts inference failed');
      
      if (response.status === 401 || response.status === 403) {
        console.log('\n  Authentication issue detected.');
        console.log('  ModelArts real-time services typically require:');
        console.log('    1. IAM token (X-Auth-Token header), OR');
        console.log('    2. AK/SK signature authentication');
        console.log('\n  Your service might be configured for a specific auth method.');
        console.log('  Check the service configuration in ModelArts console.');
      }
      
      return false;
    }
  } catch (error) {
    console.error('  ✗ Error calling ModelArts:', error.message);
    return false;
  }
}

async function checkServiceStatus(token) {
  console.log('\n[3/3] Checking service deployment status...');
  
  // Try to get service details
  const serviceUrl = `https://modelarts.${MODELARTS_REGION}.myhuaweicloud.com/v1/${MODELARTS_PROJECT_ID}/services/${MODELARTS_SERVICE_ID}`;
  
  try {
    const response = await fetch(serviceUrl, {
      method: 'GET',
      headers: {
        'X-Auth-Token': token,
      },
    });

    if (response.status === 200) {
      const serviceData = await response.json();
      console.log('  Service details:', JSON.stringify(serviceData, null, 2));
      
      if (serviceData.status) {
        console.log(`  Service status: ${serviceData.status}`);
        if (serviceData.status === 'running') {
          console.log('  ✓ Service is running');
        } else {
          console.log(`  ⚠ Service is not running (status: ${serviceData.status})`);
        }
      }
    } else {
      console.log(`  Could not get service details (status: ${response.status})`);
      const errorBody = await response.text();
      console.log('  Response:', errorBody);
    }
  } catch (error) {
    console.log('  Could not check service status:', error.message);
  }
}

async function main() {
  const token = await getIAMToken();
  
  if (!token) {
    console.log('\n========================================');
    console.log('FAILED: Could not obtain IAM token');
    console.log('========================================\n');
    console.log('Please check:');
    console.log('  1. Username is correct in env.json');
    console.log('  2. Password is correct in env.json');
    console.log('  3. Domain is correct in env.json');
    console.log('  4. Project ID is correct');
    console.log('');
    process.exit(1);
  }

  const inferenceSuccess = await testModelArtsInference(token);
  await checkServiceStatus(token);
  
  console.log('\n========================================');
  console.log('Test Summary');
  console.log('========================================\n');
  
  if (inferenceSuccess) {
    console.log('✓ All tests passed!');
    console.log('  ModelArts service is working correctly.');
    console.log('');
  } else {
    console.log('✗ Tests failed');
    console.log('');
    console.log('Common issues:');
    console.log('  1. Authentication method not supported for this region');
    console.log('  2. Service requires specific authentication configuration');
    console.log('  3. Model expects different input format');
    console.log('  4. Service ID or region mismatch');
    console.log('');
    console.log('Recommendations:');
    console.log('  1. Check ModelArts service authentication settings');
    console.log('  2. Verify the service is configured for IAM token auth');
    console.log('  3. Check if service requires AK/SK signature');
    console.log('  4. Review service logs in ModelArts console');
    console.log('  5. Test with a sample request from ModelArts console');
    console.log('');
  }
}

main().catch(error => {
  console.error('\nUnexpected error:', error);
  process.exit(1);
});
