const { hashPassword, comparePassword } = require('./authHelpers');
const fetch = require('node-fetch');

// Huawei Cloud APIG Configuration
const HUAWEI_BASE_URL = 'https://bfea85780dee4f95b5e5ce77704934e9.apic.af-south-1.huaweicloudapis.com';
const HUAWEI_APP_CODE = 'b369a2fd558f4331a644598d6223a731b2ffaaa3baf644c1a606d593b52301c7';

/**
 * Register a new user
 * Hashes the password before storing in database
 */
async function register(req, res) {
  try {
    const { username, email, password, user_type } = req.body;

    // Validate all fields are present
    if (!username || !email || !password || !user_type) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields. Please provide username, email, password, and user_type.',
      });
    }

    // Validate email format
    if (!email.includes('@')) {
      return res.status(400).json({
        success: false,
        error: 'Invalid email format',
      });
    }

    // Validate password length
    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        error: 'Password must be at least 6 characters',
      });
    }

    // Hash the password
    const passwordHash = await hashPassword(password);

    // Log request
    console.log(`[${new Date().toISOString()}] POST /api/signup - Username: ${username}, Email: ${email}, User Type: ${user_type}`);

    // Forward request to Huawei Cloud APIG with hashed password
    const requestBody = {
      username: username.trim(),
      email: email.trim(),
      password: password.trim(), // Send plain password - Huawei validates and hashes it
      role: user_type, // Try 'role' instead of 'user_type'
      user_type: user_type, // Also keep user_type for compatibility
      type: user_type, // Also try 'type'
    };
    
    console.log(`[${new Date().toISOString()}] Sending to Huawei Cloud:`, JSON.stringify(requestBody, null, 2));
    
    const response = await fetch(`${HUAWEI_BASE_URL}/signup`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Apig-AppCode': HUAWEI_APP_CODE,
      },
      body: JSON.stringify(requestBody),
    });

    // Get response data
    const responseData = await response.json();

    // Log response status and error details if present
    console.log(`[${new Date().toISOString()}] Response Status: ${response.status}`);
    console.log(`[${new Date().toISOString()}] Response Body:`, JSON.stringify(responseData, null, 2));
    if (responseData.error_code || responseData.error_msg) {
      console.log(`[${new Date().toISOString()}] Huawei Cloud Error: ${responseData.error_code} - ${responseData.error_msg}`);
    }

    // Return the exact response from Huawei Cloud
    res.status(response.status).json(responseData);
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Error in /api/signup:`, error);
    res.status(500).json({
      success: false,
      error: 'Internal server error. Please try again later.',
    });
  }
}

/**
 * Login user
 * Compares plain password with hashed password from database
 */
async function login(req, res) {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: email, password',
      });
    }

    // Log request
    console.log(`📤 [${new Date().toISOString()}] Login request for: ${email}`);

    // Fetch user from Huawei Cloud APIG
    // Note: We need to get the user data including password_hash
    const response = await fetch(`${HUAWEI_BASE_URL}/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Apig-AppCode': HUAWEI_APP_CODE,
      },
      body: JSON.stringify({
        email: email.trim(),
        password: password.trim(), // Send plain password for now to get user data
      }),
    });

    const responseData = await response.json();

    // Log response status
    console.log(`📥 [${new Date().toISOString()}] Login response status: ${response.status}`);

    // If Huawei Cloud returns user data with password_hash, verify it
    if (response.status === 200 && responseData.user && responseData.user.password_hash) {
      const user = responseData.user;
      
      // Compare the plain password with the hashed password
      const isMatch = await comparePassword(password, user.password_hash);
      
      if (!isMatch) {
        console.log(`❌ [${new Date().toISOString()}] Password mismatch for: ${email}`);
        return res.status(401).json({
          success: false,
          error: 'Invalid email or password',
        });
      }

      // Password matches - return success
      console.log(`✅ [${new Date().toISOString()}] Login successful for: ${email}`);
      return res.json({
        success: true,
        userId: user.id,
        user: {
          id: user.id,
          username: user.username,
          email: user.email
        }
      });
    }

    // If response doesn't contain password_hash, forward the response as-is
    // This handles cases where Huawei Cloud does its own authentication
    return res.status(response.status).json(responseData);

  } catch (error) {
    console.error(`❌ [${new Date().toISOString()}] Login error:`, error.message);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error.message,
    });
  }
}

module.exports = {
  register,
  login
};
