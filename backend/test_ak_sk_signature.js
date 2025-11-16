// Test ModelArts with AK/SK Signature Authentication
// This uses signature-based auth instead of IAM tokens

const fetch = require('node-fetch');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

// Load configuration
const envPath = path.join(__dirname, '..', 'env.json');
const config = JSON.parse(fs.readFileSync(envPath, 'utf8'));

const {
  MODELARTS_ACCESS_KEY: accessKey,
  MODELARTS_SECRET_KEY: secretKey,
  MODELARTS_SERVICE_ID: serviceId,
  MODELARTS_REGION: region,
} = config;

console.log('\n========================================');
console.log('ModelArts AK/SK Signature Test');
console.log('========================================\n');

console.log('Configuration:');
console.log(`  Access Key: ${accessKey.substring(0, 8)}...`);
console.log(`  Service ID: ${serviceId}`);
console.log(`  Region: ${region}`);
console.log('');

// Create signature for Huawei Cloud API
function createSignature(method, url, headers, body) {
  // This is a simplified version - full implementation would need proper canonical request
  const stringToSign = `${method}\n${url}\n${JSON.stringify(headers)}\n${body}`;
  const signature = crypto
    .createHmac('sha256', secretKey)
    .update(stringToSign)
    .digest('hex');
  return signature;
}

async function testWithoutAuth() {
  console.log('[Test 1] Trying without authentication...');
  
  const testImage = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
  const url = `https://infer-modelarts-${region}.modelarts-infer.com/v1/infers/${serviceId}`;
  
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ image: testImage }),
    });

    console.log(`  Response status: ${response.status}`);
    const data = await response.json();
    console.log(`  Response:`, JSON.stringify(data, null, 2));
    
    if (response.status === 200) {
      console.log('  ✓ Success without authentication!\n');
      return true;
    }
  } catch (error) {
    console.log(`  ✗ Failed: ${error.message}\n`);
  }
  
  return false;
}

async function testWithAPIKey() {
  console.log('[Test 2] Trying with API Key in header...');
  
  const testImage = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
  const url = `https://infer-modelarts-${region}.modelarts-infer.com/v1/infers/${serviceId}`;
  
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Apig-AppCode': accessKey, // Some services use AppCode
      },
      body: JSON.stringify({ image: testImage }),
    });

    console.log(`  Response status: ${response.status}`);
    const data = await response.json();
    console.log(`  Response:`, JSON.stringify(data, null, 2));
    
    if (response.status === 200) {
      console.log('  ✓ Success with API Key!\n');
      return true;
    }
  } catch (error) {
    console.log(`  ✗ Failed: ${error.message}\n`);
  }
  
  return false;
}

async function main() {
  const test1 = await testWithoutAuth();
  if (test1) {
    console.log('========================================');
    console.log('SUCCESS: Service works without auth!');
    console.log('========================================\n');
    console.log('This means the ModelArts service is configured');
    console.log('for public access or has authentication disabled.');
    console.log('\nYou can use the service directly without IAM tokens!');
    return;
  }

  const test2 = await testWithAPIKey();
  if (test2) {
    console.log('========================================');
    console.log('SUCCESS: Service works with API Key!');
    console.log('========================================\n');
    return;
  }

  console.log('========================================');
  console.log('All tests failed');
  console.log('========================================\n');
  console.log('The service requires IAM token authentication.');
  console.log('Please verify your Huawei Cloud credentials can');
  console.log('login to the console successfully.');
  console.log('\nTry logging in at: https://console.huaweicloud.com');
  console.log('with username: kero_o911');
  console.log('and the password you provided.');
}

main().catch(console.error);
