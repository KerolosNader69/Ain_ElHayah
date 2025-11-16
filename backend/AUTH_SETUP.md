# Authentication System Setup

## Overview
The authentication system now uses bcrypt for password hashing. Passwords are hashed before being stored in the database and verified using bcrypt.compare() during login.

## Files Modified/Created

### 1. **authHelpers.js** (NEW)
Helper functions for password hashing and comparison:
- `hashPassword(password)` - Hashes a plain text password
- `comparePassword(password, hashedPassword)` - Compares plain password with hash

### 2. **authController.js** (NEW)
Authentication controller with:
- `register(req, res)` - Handles user registration with password hashing
- `login(req, res)` - Handles user login with bcrypt password verification

### 3. **generate-hash.js** (NEW)
Utility script to generate password hashes manually for database updates.

### 4. **server.js** (MODIFIED)
Updated to use the new authentication controller.

### 5. **package.json** (MODIFIED)
Added bcrypt dependency.

## Setup Instructions

### 1. Install Dependencies
```bash
cd backend
npm install
```

This will install bcrypt along with other dependencies.

### 2. Update Existing Passwords in Database

For existing users with plain text passwords, you need to update them to hashed passwords.

#### Generate a hash for "123456":
```bash
node generate-hash.js 123456
```

Output:
```
============================================================
Password Hash Generator
============================================================
Password: 123456
Hash:     $2b$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJK
============================================================

Copy the hash above and paste it into your database's password_hash column.
```

#### Update your database:
```sql
UPDATE users 
SET password_hash = '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJK'
WHERE email = 'user@example.com';
```

### 3. Start the Server
```bash
npm start
```

## How It Works

### Registration Flow
1. User submits username, email, and plain password
2. Backend validates input
3. Password is hashed using `bcrypt.hash(password, 10)`
4. Hashed password is sent to Huawei Cloud APIG as `password_hash`
5. Database stores the hashed password in `password_hash` column

### Login Flow
1. User submits email and plain password
2. Backend fetches user data from Huawei Cloud APIG (including `password_hash`)
3. Backend compares plain password with stored hash using `bcrypt.compare()`
4. If match: Returns `{ success: true, userId: user.id, user: {...} }`
5. If no match: Returns `{ success: false, error: 'Invalid email or password' }` with 401 status

## API Endpoints

### POST /api/signup
**Request:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "123456"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "userId": 123
}
```

### POST /api/login
**Request:**
```json
{
  "email": "john@example.com",
  "password": "123456"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "userId": 123,
  "user": {
    "id": 123,
    "username": "john_doe",
    "email": "john@example.com"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "error": "Invalid email or password"
}
```

## Database Schema

The `users` table should have:
```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Important:** The column MUST be named `password_hash`, not `password`.

## Security Notes

1. **Never store plain text passwords** - Always use `hashPassword()` before storing
2. **Never log passwords** - The code removes passwords from logs
3. **Use HTTPS in production** - Passwords are sent over the network
4. **Salt rounds** - Currently set to 10 (good balance of security and performance)
5. **Password requirements** - Minimum 6 characters (can be increased)

## Troubleshooting

### Issue: "Invalid email or password" even with correct credentials
**Solution:** The password in the database is still plain text. Use `generate-hash.js` to create a hash and update the database.

### Issue: bcrypt installation fails on Windows
**Solution:** Install windows-build-tools:
```bash
npm install --global windows-build-tools
npm install bcrypt
```

### Issue: Login returns 500 error
**Solution:** Check that:
1. Huawei Cloud APIG returns user data with `password_hash` field
2. The `password_hash` column exists in the database
3. bcrypt is properly installed

## Testing

### Test password hashing:
```bash
node generate-hash.js testpassword
```

### Test login with curl:
```bash
curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"123456"}'
```

## Migration Script (Optional)

If you have many users with plain text passwords, create a migration script:

```javascript
// migrate-passwords.js
const bcrypt = require('bcrypt');
const fetch = require('node-fetch');

async function migratePasswords() {
  // Fetch all users with plain text passwords
  // For each user:
  //   1. Hash the plain password
  //   2. Update database with hashed password
  
  console.log('Migration complete');
}

migratePasswords();
```
