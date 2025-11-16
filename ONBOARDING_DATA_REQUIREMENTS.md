# Onboarding Data Collection Requirements

This document outlines the information that should be collected during the onboarding process for both **Patients** and **Doctors**.

---

## 📋 **DOCTOR ONBOARDING** (3 Steps)

### **Step 1: Personal Information** ✅ (Currently Implemented)
- **Full Name** (Required)
  - First and Last Name
  - Validation: Cannot be empty
  
- **Email Address** (Required)
  - Valid email format
  - Used for account authentication and communication
  - Validation: Must match email regex pattern

### **Step 2: Professional Information** ✅ (Currently Implemented)
- **Medical ID / License Number** (Required)
  - Official medical license or registration number
  - Validation: Cannot be empty
  
- **Specialization** (Required)
  - Medical specialization field (e.g., Ophthalmology, Retina Specialist)
  - Validation: Cannot be empty
  
- **Years of Experience** (Required)
  - Number of years practicing medicine
  - Validation: Must be a number between 0-50
  
- **Workplace / Hospital** (Required)
  - Current hospital, clinic, or medical institution
  - Validation: Cannot be empty

### **Step 3: Document Verification** ✅ (Currently Implemented - Optional)
- **ID Document / Proof** (Optional but Recommended)
  - Medical license, ID card, or other verification documents
  - File upload (PDF, Image formats)
  
- **License Document** (Optional but Recommended)
  - Official medical license or certification document
  - File upload (PDF, Image formats)

---

## 👤 **PATIENT ONBOARDING** (Currently Missing - Should Be Added)

### **Step 1: Basic Information** (Required)
- **First Name** (Required)
  - Patient's first name
  - Validation: Cannot be empty
  
- **Last Name** (Required)
  - Patient's last name
  - Validation: Cannot be empty
  
- **Email Address** (Required)
  - Valid email format
  - Used for account authentication
  - Validation: Must match email regex pattern
  
- **Phone Number** (Required)
  - Contact phone number
  - Format: Should support international formats
  - Validation: Valid phone number format
  
- **Date of Birth** (Required)
  - Used to calculate age automatically
  - Validation: Must be a valid date, must be in the past
  
- **Gender** (Required)
  - Options: Male, Female, Other, Prefer not to say
  - Validation: Must select one option

### **Step 2: Medical Information** (Optional but Recommended)
- **Medical History** (Optional)
  - Previous eye conditions, surgeries, or relevant medical history
  - Text area for detailed input
  
- **Allergies** (Optional)
  - Known allergies (medications, materials, etc.)
  - Important for treatment safety
  - Text area for input
  
- **Current Medications** (Optional)
  - List of medications currently being taken
  - Important for drug interaction checks
  - Text area for input

### **Step 3: Emergency Contact** (Recommended)
- **Emergency Contact Name** (Optional)
  - Name of emergency contact person
  
- **Emergency Contact Phone** (Optional)
  - Phone number of emergency contact
  - Validation: Valid phone number format
  
- **Relationship to Patient** (Optional)
  - Relationship (e.g., Spouse, Parent, Sibling, Friend)

---

## 📊 **Summary Comparison**

| Field | Doctor | Patient | Required |
|-------|--------|---------|----------|
| **Full Name** | ✅ | ✅ (First + Last) | Yes |
| **Email** | ✅ | ✅ | Yes |
| **Phone** | ❌ | ✅ | Yes (Patient) |
| **Date of Birth/Age** | ❌ | ✅ | Yes (Patient) |
| **Gender** | ❌ | ✅ | Yes (Patient) |
| **Medical ID/License** | ✅ | ❌ | Yes (Doctor) |
| **Specialization** | ✅ | ❌ | Yes (Doctor) |
| **Years of Experience** | ✅ | ❌ | Yes (Doctor) |
| **Workplace** | ✅ | ❌ | Yes (Doctor) |
| **Medical History** | ❌ | ✅ | Optional |
| **Allergies** | ❌ | ✅ | Optional |
| **Current Medications** | ❌ | ✅ | Optional |
| **Emergency Contact** | ❌ | ✅ | Optional |
| **ID Documents** | ✅ (Optional) | ❌ | Optional (Doctor) |
| **License Documents** | ✅ (Optional) | ❌ | Optional (Doctor) |

---

## 🔧 **Implementation Notes**

### **Current Status:**
- ✅ **Doctor Onboarding**: Fully implemented with 3-step process
- ❌ **Patient Onboarding**: Not implemented - patients currently only sign up via login screen

### **Recommendations:**
1. **Create Patient Onboarding Screen** similar to doctor onboarding
2. **Add Patient Sign-Up Flow** that collects all required patient information
3. **Store Patient Data** in the Patient model (already defined in `patient_models.dart`)
4. **Add Validation** for all required fields
5. **Consider Adding:**
   - Profile photo upload (optional)
   - Insurance information (optional)
   - Preferred language (for TTS/SIS)
   - Notification preferences

---

## 📝 **Data Storage**

### **Doctor Data Structure:**
```dart
{
  'fullName': String,
  'email': String,
  'medicalId': String,
  'specialization': String,
  'yearsExperience': int,
  'workplace': String,
  'idDocumentPath': String?,
  'licenseDocumentPath': String?,
}
```

### **Patient Data Structure:**
```dart
{
  'id': String,
  'firstName': String,
  'lastName': String,
  'email': String,
  'phone': String,
  'age': int, // or dateOfBirth: DateTime
  'gender': String,
  'medicalHistory': String?,
  'allergies': String?,
  'currentMedications': String?,
  'emergencyContactName': String?,
  'emergencyContactPhone': String?,
  'emergencyContactRelationship': String?,
  'dateAdded': DateTime,
  'doctorId': String?, // If added by doctor
}
```

---

## ✅ **Next Steps**

1. Create `patient_onboarding_screen.dart` with multi-step form
2. Update sign-up flow to route to patient onboarding after registration
3. Add patient data collection to `AuthProvider` or create `PatientProvider`
4. Update database/storage to persist patient onboarding data
5. Add validation and error handling for all fields

