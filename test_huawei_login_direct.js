const fetch = require('node-fetch');

// Huawei Cloud APIG Configuration
const HUAWEI_BASE_URL = 'https://bfea85780dee4f95b5e5ce77704934e9.apic.af-south-1.huaweicloudapis.com';
const HUAWEI_APP_CODE = 'b369a2fd558f4331a644598d6223a731b2ffaaa3baf644c1a606d593b52301c7';

async function testHuaweiLogin(email, password) {
  console.log(`\n${'='.repeat(60)}`);
  console.log(`Testing Huawei Cloud Login API`);
  console.log(`Email: ${email}`);
  console.log('='.repeat(60));

  try {
    const requestBody = {
      email: email.trim(),
      password: password.trim(),
    };

    console.log('\n📤 Request Body:', JSON.stringify(requestBody, null, 2));

    const response = await fetch(`${HUAWEI_BASE_URL}/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Apig-AppCode': HUAWEI_APP_CODE,
      },
      body: JSON.stringify(requestBody),
    });

    console.log(`\n📥 Response Status: ${response.status}`);
    console.log('Response Headers:', Object.fromEntries(response.headers.entries()));

    const responseData = await response.json();
    console.log('\n📥 Response Body:', JSON.stringify(responseData, null, 2));

    if (response.status === 200) {
      console.log('\n✅ Huawei Cloud login successful!');
      if (responseData.user) {
        console.log('User data:', responseData.user);
      }
    } else {
      console.log('\n❌ Huawei Cloud login failed!');
      if (responseData.error_code || responseData.error_msg) {
        console.log(`Error: ${responseData.error_code} - ${responseData.error_msg}`);
      }
    }
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error('Stack:', error.stack);
  }
}

async function runTests() {
  console.log('\n🔍 Testing Huawei Cloud Login API Directly\n');
  
  // Test with database credentials
  await testHuaweiLogin('Afreslem@gmail.com', 'keroderal2012');
  
  console.log('\n' + '='.repeat(60));
  console.log('Test complete!');
  console.log('='.repeat(60));
}

runTests();
