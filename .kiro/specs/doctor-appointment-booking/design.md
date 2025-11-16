# Design Document

## Overview

This design implements a frontend-only appointment booking system for the doctors page. The solution uses Flutter's state management (Provider pattern) to handle appointment data locally without backend integration. The design focuses on creating an intuitive multi-step booking flow with proper navigation, form validation, and state persistence during the user session.

## Architecture

### State Management
- Use Provider pattern for managing appointment state across screens
- Create `AppointmentProvider` to handle booking data and operations
- Store appointments in memory (List) during app session
- Generate unique booking IDs using UUID package

### Navigation Flow
```
DoctorsScreen
  ├─> DoctorProfileScreen (View Profile)
  │     └─> AppointmentBookingScreen
  │           ├─> TimeSlotSelectionScreen
  │           ├─> BookingFormScreen
  │           ├─> BookingReviewScreen
  │           └─> BookingConfirmationScreen
  │
  └─> AppointmentBookingScreen (Book Appointment - direct)
        └─> [same flow as above]

MyAppointmentsScreen (accessible from main navigation)
  └─> AppointmentDetailsScreen
        └─> Cancel confirmation dialog
```

## Components and Interfaces

### 1. Data Models

#### Appointment Model
```dart
class Appointment {
  final String id;
  final Doctor doctor;
  final DateTime dateTime;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String reasonForVisit;
  final String? notes;
  final AppointmentStatus status;
  final DateTime createdAt;
  
  // Methods: toJson, fromJson, copyWith
}

enum AppointmentStatus {
  upcoming,
  completed,
  cancelled
}
```

#### TimeSlot Model
```dart
class TimeSlot {
  final DateTime dateTime;
  final bool isAvailable;
  final String displayTime;
  
  // Constructor and helper methods
}
```

### 2. State Management

#### AppointmentProvider
```dart
class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  
  // Getters
  List<Appointment> get appointments;
  List<Appointment> get upcomingAppointments;
  List<Appointment> get pastAppointments;
  
  // Methods
  void addAppointment(Appointment appointment);
  void cancelAppointment(String appointmentId);
  Appointment? getAppointmentById(String id);
  List<TimeSlot> getAvailableSlots(Doctor doctor, DateTime date);
  String generateBookingReference();
}
```

### 3. Screen Components

#### DoctorProfileScreen
- Display comprehensive doctor information
- Show education, experience, specialties
- Display mock patient reviews (5-10 reviews)
- Show "Book Appointment" floating action button
- Navigate to AppointmentBookingScreen on button press

#### AppointmentBookingScreen
- Multi-step wizard interface using PageView or Stepper
- Progress indicator showing current step
- Back navigation with data preservation
- Steps: Date/Time Selection → Patient Info → Review → Confirmation

#### TimeSlotSelectionScreen
- Calendar widget for date selection (using table_calendar package)
- Grid of available time slots for selected date
- Visual indication of selected slot
- Generate mock availability (9 AM - 5 PM, 30-min slots)
- "Continue" button enabled only when slot selected

#### BookingFormScreen
- Form fields:
  - Patient Name (required, TextFormField)
  - Email (required, email validation)
  - Phone (required, phone format validation)
  - Reason for Visit (required, dropdown or text)
  - Additional Notes (optional, multiline)
- Form validation using Form widget and validators
- "Continue" button triggers validation

#### BookingReviewScreen
- Display summary card with all booking details
- Doctor info card (name, specialty, photo)
- Appointment details (date, time, location)
- Patient information
- "Edit" button for each section
- "Confirm Booking" primary action button

#### BookingConfirmationScreen
- Success icon/animation
- Booking reference number (generated UUID)
- Complete appointment details
- Action buttons:
  - "Add to Calendar" (uses add_2_calendar package)
  - "Share Details" (uses share_plus package)
  - "Done" (returns to doctors list)

#### MyAppointmentsScreen
- List view of all appointments
- Tabs or filters: All, Upcoming, Past
- Each appointment card shows:
  - Doctor name and photo
  - Date and time
  - Status badge
  - Tap to view details
- Empty state when no appointments

#### AppointmentDetailsScreen
- Full appointment information
- Doctor details section
- Appointment info section
- Patient info section
- "Cancel Appointment" button (only for upcoming)
- Cancel confirmation dialog

### 4. Reusable Widgets

#### AppointmentCard
- Compact card showing appointment summary
- Used in MyAppointmentsScreen list
- Props: appointment, onTap

#### TimeSlotButton
- Button representing a single time slot
- Visual states: available, selected, unavailable
- Props: timeSlot, isSelected, onTap

#### StepIndicator
- Progress indicator for booking wizard
- Shows current step and completed steps
- Props: currentStep, totalSteps

#### InfoSection
- Reusable section with title and content
- Used in review and details screens
- Props: title, content, onEdit (optional)

## Data Models

### Mock Data Generation

#### Available Time Slots
- Generate slots for next 30 days
- Business hours: 9:00 AM - 5:00 PM
- 30-minute intervals
- Randomly mark 30% as unavailable for realism
- Weekend availability varies by doctor

#### Doctor Extended Info (for profile)
- Education: Medical school, residency
- Years of experience
- Languages spoken
- Accepted insurance (mock list)
- Patient reviews with ratings and comments

#### Sample Reviews
```dart
class Review {
  final String patientName;
  final double rating;
  final String comment;
  final DateTime date;
}
```

## Error Handling

### Validation Errors
- Display inline error messages below form fields
- Highlight invalid fields in red
- Prevent form submission until all validations pass
- Show snackbar for general form errors

### Navigation Errors
- Handle back button press with confirmation dialog if data entered
- Preserve form data when navigating back
- Clear data when booking completed or cancelled

### State Errors
- Handle null doctor gracefully
- Validate appointment data before adding to provider
- Show error dialog if booking fails (edge cases)

## Testing Strategy

### Widget Tests
- Test each screen renders correctly
- Test form validation logic
- Test time slot selection behavior
- Test appointment card interactions
- Test navigation between screens

### Integration Tests
- Test complete booking flow end-to-end
- Test appointment cancellation flow
- Test data persistence in provider
- Test navigation with data preservation

### Manual Testing Checklist
- Book appointment from doctor card
- Book appointment from doctor profile
- Complete full booking flow
- Edit information during review
- Cancel appointment
- View appointment details
- Test responsive layout on different screen sizes
- Test with different locales (if internationalized)

## UI/UX Considerations

### Responsive Design
- Mobile: Single column, full-width cards
- Tablet: Two-column layout where appropriate
- Desktop: Centered content with max-width constraint

### Accessibility
- Semantic labels for screen readers
- Sufficient color contrast
- Touch targets minimum 48x48 dp
- Keyboard navigation support (web)

### Visual Design
- Consistent with existing AppTheme
- Use primary gradient for success states
- Status badges with appropriate colors
- Smooth transitions between steps
- Loading states for any async operations (future-proofing)

### User Feedback
- Snackbars for success/error messages
- Confirmation dialogs for destructive actions
- Visual feedback on button presses
- Progress indicators during multi-step flow

## Dependencies

Required packages to add to `pubspec.yaml`:
```yaml
dependencies:
  provider: ^6.1.1
  uuid: ^4.2.2
  table_calendar: ^3.0.9
  intl: ^0.18.1
  add_2_calendar: ^3.0.1
  share_plus: ^7.2.1
```

## Implementation Notes

### Phase 1: Core Structure
- Set up AppointmentProvider
- Create data models
- Implement basic navigation flow

### Phase 2: Booking Flow
- Implement time slot selection
- Create booking form with validation
- Build review and confirmation screens

### Phase 3: Appointment Management
- Create MyAppointmentsScreen
- Implement appointment details view
- Add cancellation functionality

### Phase 4: Polish
- Add animations and transitions
- Implement calendar and share features
- Refine responsive layouts
- Add comprehensive error handling

### Future Enhancements (Out of Scope)
- Backend integration for real appointments
- Push notifications for reminders
- Rescheduling functionality
- Video consultation integration
- Payment processing
