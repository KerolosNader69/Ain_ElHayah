# Implementation Plan

- [ ] 1. Set up data models and state management
  - Create Appointment model with all required fields (id, doctor, dateTime, patient info, status)
  - Create TimeSlot model for availability management
  - Create AppointmentStatus enum (upcoming, completed, cancelled)
  - Implement toJson, fromJson, and copyWith methods for models
  - _Requirements: 1.1, 2.1, 3.1, 5.4_

- [ ] 2. Implement AppointmentProvider for state management
  - Create AppointmentProvider class extending ChangeNotifier
  - Implement appointments list storage in memory
  - Add methods: addAppointment, cancelAppointment, getAppointmentById
  - Implement getAvailableSlots method to generate mock time slots
  - Create generateBookingReference method using UUID
  - Add getters for upcomingAppointments and pastAppointments with filtering
  - _Requirements: 5.4, 6.2, 7.3_

- [ ] 3. Create DoctorProfileScreen
  - Build screen layout with doctor photo, name, and specialty at top
  - Add sections for education, experience, and languages
  - Display specialties as chips/tags
  - Create mock patient reviews list (5-10 reviews with ratings and comments)
  - Add floating action button for "Book Appointment"
  - Implement navigation to AppointmentBookingScreen with doctor data
  - Make screen responsive for mobile, tablet, and desktop
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [ ] 4. Implement TimeSlotSelectionScreen
  - Integrate table_calendar package for date selection
  - Create calendar widget showing next 30 days
  - Generate available time slots (9 AM - 5 PM, 30-min intervals) for selected date
  - Build grid layout of time slot buttons
  - Implement selection state management for chosen slot
  - Add visual highlighting for selected time slot
  - Display timezone information
  - Add "Continue" button that enables only when slot is selected
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 5. Create BookingFormScreen with validation
  - Build form with TextFormField widgets for all required fields
  - Add patient name field (required, text validation)
  - Add email field (required, email format validation)
  - Add phone field (required, phone format validation)
  - Add reason for visit field (required, dropdown or text)
  - Add optional notes field (multiline text)
  - Implement Form widget with GlobalKey for validation
  - Create validator functions for each field type
  - Add "Continue" button that triggers validation before proceeding
  - Display inline error messages for invalid fields
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 6. Build BookingReviewScreen
  - Create summary layout with all booking information
  - Display doctor info card (photo, name, specialty, location)
  - Show appointment details section (date, time, location)
  - Display patient information section
  - Add "Edit" buttons for each section to navigate back
  - Implement "Confirm Booking" primary action button
  - Preserve form data when navigating back to edit
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ] 7. Implement BookingConfirmationScreen
  - Design success screen with checkmark icon or animation
  - Display generated booking reference number prominently
  - Show complete appointment summary (doctor, date, time, location)
  - Integrate add_2_calendar package for "Add to Calendar" button
  - Integrate share_plus package for "Share Details" button
  - Add "Done" button to return to doctors list
  - Save appointment to AppointmentProvider on confirmation
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 8. Create AppointmentBookingScreen wizard
  - Implement multi-step wizard using PageView or Stepper widget
  - Add step indicator showing current progress (1 of 4, 2 of 4, etc.)
  - Wire up navigation between TimeSlotSelection → BookingForm → Review → Confirmation
  - Implement back button handling with data preservation
  - Add confirmation dialog when user tries to exit with unsaved data
  - Handle navigation from both doctor card and profile screen
  - Pass doctor data through navigation parameters
  - _Requirements: 2.1, 3.1, 4.1, 5.1_

- [ ] 9. Build MyAppointmentsScreen
  - Create screen accessible from main navigation/app bar
  - Implement list view of all appointments using ListView.builder
  - Add tabs or filter buttons for All, Upcoming, Past appointments
  - Create appointment card widget showing doctor photo, name, date, time, status
  - Implement tap handler to navigate to AppointmentDetailsScreen
  - Sort appointments by date (upcoming first)
  - Add empty state widget when no appointments exist
  - Make layout responsive for different screen sizes
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 10. Implement AppointmentDetailsScreen
  - Create detailed view layout for single appointment
  - Display doctor information section with photo and details
  - Show appointment information section (date, time, location, booking reference)
  - Display patient information section
  - Add status badge (upcoming, completed, cancelled)
  - Implement "Cancel Appointment" button (only visible for upcoming appointments)
  - Add cancel confirmation dialog with warning message
  - Handle cancellation by updating appointment status in provider
  - Navigate back to MyAppointmentsScreen after cancellation
  - _Requirements: 6.4, 7.1, 7.2, 7.3, 7.4_

- [ ] 11. Create reusable widget components
  - Build AppointmentCard widget for list items
  - Create TimeSlotButton widget with available/selected/unavailable states
  - Implement StepIndicator widget for booking wizard progress
  - Build InfoSection widget for review and details screens
  - Add StatusBadge widget for appointment status display
  - Ensure all widgets follow AppTheme styling
  - _Requirements: 2.3, 6.3_

- [ ] 12. Wire up navigation from DoctorsScreen
  - Update "Book Appointment" button onPressed handler in doctor cards
  - Navigate to AppointmentBookingScreen with doctor parameter
  - Update "View Profile" button to navigate to DoctorProfileScreen
  - Ensure doctor data is passed correctly through navigation
  - Test navigation flow from both buttons
  - _Requirements: 1.3, 2.1_

- [ ] 13. Add dependencies to pubspec.yaml
  - Add provider package (^6.1.1)
  - Add uuid package (^4.2.2)
  - Add table_calendar package (^3.0.9)
  - Add intl package (^0.18.1)
  - Add add_2_calendar package (^3.0.1)
  - Add share_plus package (^7.2.1)
  - Run flutter pub get to install packages
  - _Requirements: All_

- [ ] 14. Register AppointmentProvider in app
  - Add AppointmentProvider to MultiProvider in main.dart
  - Ensure provider is available throughout widget tree
  - Test provider access from different screens
  - _Requirements: 5.4, 6.1, 7.3_

- [ ] 15. Implement responsive layouts
  - Test all screens on mobile (< 600px width)
  - Test all screens on tablet (600-1024px width)
  - Test all screens on desktop (> 1024px width)
  - Adjust layouts using LayoutBuilder and MediaQuery
  - Ensure touch targets are minimum 48x48 dp
  - Verify text readability at all sizes
  - _Requirements: All_

- [ ] 16. Add error handling and user feedback
  - Implement snackbar messages for successful booking
  - Add snackbar for successful cancellation
  - Show error dialog if booking fails (edge cases)
  - Add loading indicators where appropriate
  - Implement confirmation dialogs for destructive actions
  - Handle null doctor data gracefully
  - _Requirements: 3.2, 7.2, 7.4_

- [ ] 17. Polish UI and add transitions
  - Add smooth page transitions in booking wizard
  - Implement fade-in animations for confirmation screen
  - Add ripple effects to buttons and cards
  - Ensure consistent spacing and padding throughout
  - Verify color contrast meets accessibility standards
  - Test with light and dark themes
  - _Requirements: All_

- [ ] 18. Add localization support
  - Add all new strings to app_localizations files
  - Include: "Book Appointment", "View Profile", "My Appointments", "Cancel Appointment", etc.
  - Add strings for form labels and validation messages
  - Add strings for confirmation messages
  - Test with different locales if supported
  - _Requirements: All_
