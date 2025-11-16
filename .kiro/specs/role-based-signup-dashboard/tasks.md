# Implementation Plan

- [x] 1. Create reusable RoleSelector widget
  - Extract role selection UI from LoginScreen into a new reusable widget component
  - Create `lib/widgets/role_selector.dart` with RoleSelector stateless widget
  - Implement widget interface with selectedRole, onRoleChanged callback, and enabled parameters
  - Add visual styling for Patient and Doctor role cards with icons, labels, and selection states
  - Ensure proper theme integration and responsive layout
  - _Requirements: 1.1, 1.2, 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 2. Refactor LoginScreen to use RoleSelector widget
  - Replace inline role selection UI in LoginScreen with the new RoleSelector widget
  - Pass _selectedRole state and setState callback to RoleSelector
  - Pass loading state to disable RoleSelector during authentication
  - Verify visual consistency and functionality remains unchanged
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 3. Update SignupScreen with role selection and navigation
- [x] 3.1 Add role selection UI to SignupScreen
  - Add _selectedRole state variable to SignupScreen (default to UserRole.patient)
  - Import RoleSelector widget and UserRole enum from auth_provider
  - Position RoleSelector between password field and signup button in the form
  - Pass _selectedRole and setState callback to RoleSelector
  - Disable RoleSelector when _isLoading is true
  - _Requirements: 1.1, 1.2, 1.4_

- [x] 3.2 Implement role-based signup and navigation
  - Update _handleSignup method to pass _selectedRole to auth.signUp()
  - Replace navigation to '/login' with role-based navigation after successful signup
  - Navigate to '/' if role is UserRole.patient
  - Navigate to '/doctor-onboarding' if role is UserRole.doctor
  - Use context.go() for navigation instead of clearing form and going to login
  - _Requirements: 1.3, 2.1, 2.2_

- [x] 4. Update AuthProvider signUp method
  - Modify signUp method signature to accept required UserRole role parameter
  - Store the role parameter in _role instance variable after successful signup
  - Set _onboardingCompleted to true for patients, false for doctors
  - Persist role to SharedPreferences using _keyRole
  - Persist onboardingCompleted status to SharedPreferences
  - _Requirements: 1.3, 1.5, 2.4_

- [x] 5. Verify router redirect logic for role-based dashboards
  - Review existing redirect logic in app_router.dart
  - Confirm doctors with incomplete onboarding redirect to '/doctor-onboarding'
  - Confirm doctors with complete onboarding redirect to '/doctor/dashboard'
  - Confirm patients redirect to '/' (home/patient dashboard)
  - Confirm role persistence is handled by AuthProvider load() method
  - _Requirements: 2.3, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 6. Manual testing and validation
  - Test complete signup flow as Patient user
  - Test complete signup flow as Doctor user
  - Test doctor onboarding completion and dashboard navigation
  - Test role persistence after app restart
  - Test login flow with persisted roles
  - Verify visual consistency between signup and login role selectors
  - Test error handling with role selection
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 4.5_
