const fetch = require('node-fetch');

// Test credentials from database
const testCredentials = [
  { email: 'Afreslem@gmail.com', password: 'keroderal2012', role: 'doctor' },
  { email: 'kbsmith308@gmail.com', password: 'keroderal2012', role: 'patient' }
];

async function testLogin(email, password, role) {
  console.log(`\n${'='.repeat(60)}`);
  console.log(`Testing login for: ${email} (${role})`);
  console.log('='.repeat(60));

  try {
    const response = await fetch('http://localhost:3001/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    const data = await response.json();
    
    console.log(`Status: ${response.status}`);
    console.log('Response:', JSON.stringify(data, null, 2));

    if (response.status === 200) {
      console.log('✅ Login successful!');
    } else {
      console.log('❌ Login failed!');
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

async function runTests() {
  console.log('\n🔍 Testing Login with Database Credentials\n');
  
  for (const cred of testCredentials) {
    await testLogin(cred.email, cred.password, cred.role);
    await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1 second between tests
  }

  console.log('\n' + '='.repeat(60));
  console.log('Tests complete!');
  console.log('='.repeat(60));
}

runTests();
