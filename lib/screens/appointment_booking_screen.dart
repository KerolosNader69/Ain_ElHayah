import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../screens/doctors_screen.dart';
import '../screens/time_slot_selection_screen.dart';
import '../screens/booking_form_screen.dart';
import '../screens/booking_review_screen.dart';
import '../screens/booking_confirmation_screen.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment.dart';
import '../models/appointment_status.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final Doctor doctor;

  const AppointmentBookingScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  int _currentStep = 0;
  DateTime? _selectedDateTime;
  BookingFormData? _formData;
  bool _isConfirmed = false;
  Appointment? _confirmedAppointment;

  final List<String> _stepTitles = [
    'Select Time',
    'Patient Info',
    'Review',
    'Confirmation',
  ];

  void _onTimeSlotSelected(DateTime dateTime) {
    setState(() {
      _selectedDateTime = dateTime;
      _currentStep = 1;
    });
  }

  void _onFormSubmitted(BookingFormData formData) {
    setState(() {
      _formData = formData;
      _currentStep = 2;
    });
  }

  void _onEditDoctor() {
    // Navigate back to doctors list
    Navigator.of(context).pop();
  }

  void _onEditDateTime() {
    setState(() {
      _currentStep = 0;
    });
  }

  void _onEditPatientInfo() {
    setState(() {
      _currentStep = 1;
    });
  }

  void _onConfirmBooking() {
    if (_selectedDateTime == null || _formData == null) return;

    final provider = context.read<AppointmentProvider>();
    
    // Create appointment
    final appointment = Appointment(
      id: provider.generateBookingReference(),
      doctor: widget.doctor,
      dateTime: _selectedDateTime!,
      patientName: _formData!.patientName,
      patientEmail: _formData!.patientEmail,
      patientPhone: _formData!.patientPhone,
      reasonForVisit: _formData!.reasonForVisit,
      notes: _formData!.notes,
      status: AppointmentStatus.upcoming,
      createdAt: DateTime.now(),
    );

    // Add to provider
    provider.addAppointment(appointment);

    setState(() {
      _confirmedAppointment = appointment;
      _isConfirmed = true;
      _currentStep = 3;
    });
  }

  void _onDone() {
    // Navigate back to doctors list
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<bool> _onWillPop() async {
    if (_isConfirmed) {
      // If booking is confirmed, allow back navigation
      return true;
    }

    if (_currentStep == 0) {
      // On first step, allow back navigation
      return true;
    }

    // Show confirmation dialog
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text(
          'Are you sure you want to cancel this booking? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue Booking'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isConfirmed ? 'Booking Confirmed' : 'Book Appointment',
            style: TextStyle(
              color: AppTheme.getTextColor(context),
            ),
          ),
          backgroundColor: AppTheme.darkBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppTheme.getTextColor(context),
            ),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          bottom: _isConfirmed
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: _buildStepIndicator(context, theme),
                ),
        ),
        body: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Step dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_stepTitles.length - 1, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Row(
                children: [
                  _buildStepDot(
                    context,
                    theme,
                    index + 1,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                  ),
                  if (index < _stepTitles.length - 2)
                    Container(
                      width: 40,
                      height: 2,
                      color: isCompleted
                          ? AppTheme.primaryColor
                          : AppTheme.getBorderColor(context),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          // Step title
          Text(
            _stepTitles[_currentStep],
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(
    BuildContext context,
    ThemeData theme,
    int stepNumber, {
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color backgroundColor;
    Color textColor;
    Widget child;

    if (isCompleted) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
      child = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (isCurrent) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
      child = Text(
        stepNumber.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    } else {
      backgroundColor = AppTheme.getMutedBackgroundColor(context);
      textColor = AppTheme.getTextColor(context, isDescription: true);
      child = Text(
        stepNumber.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isCurrent
            ? Border.all(
                color: AppTheme.primaryColor,
                width: 2,
              )
            : null,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(child: child),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return TimeSlotSelectionScreen(
          doctor: widget.doctor,
          onTimeSlotSelected: _onTimeSlotSelected,
        );
      case 1:
        return BookingFormScreen(
          initialData: _formData,
          onFormSubmitted: _onFormSubmitted,
        );
      case 2:
        if (_selectedDateTime == null || _formData == null) {
          return const Center(child: Text('Error: Missing data'));
        }
        return BookingReviewScreen(
          doctor: widget.doctor,
          selectedDateTime: _selectedDateTime!,
          formData: _formData!,
          onEditDoctor: _onEditDoctor,
          onEditDateTime: _onEditDateTime,
          onEditPatientInfo: _onEditPatientInfo,
          onConfirmBooking: _onConfirmBooking,
        );
      case 3:
        if (_confirmedAppointment == null) {
          return const Center(child: Text('Error: No appointment'));
        }
        return BookingConfirmationScreen(
          appointment: _confirmedAppointment!,
          onDone: _onDone,
        );
      default:
        return const Center(child: Text('Unknown step'));
    }
  }
}
