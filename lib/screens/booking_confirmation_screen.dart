import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/appointment.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Appointment appointment;
  final VoidCallback onDone;

  const BookingConfirmationScreen({
    super.key,
    required this.appointment,
    required this.onDone,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addToCalendar() {
    final event = Event(
      title: 'Appointment with ${widget.appointment.doctor.name}',
      description: 'Reason: ${widget.appointment.reasonForVisit}\n'
          'Location: ${widget.appointment.doctor.location}\n'
          'Booking Reference: ${widget.appointment.id}',
      location: widget.appointment.doctor.location,
      startDate: widget.appointment.dateTime,
      endDate: widget.appointment.dateTime.add(const Duration(hours: 1)),
      allDay: false,
    );

    Add2Calendar.addEvent2Cal(event);
  }

  void _shareDetails() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    final shareText = '''
Appointment Confirmed!

Doctor: ${widget.appointment.doctor.name}
Specialty: ${widget.appointment.doctor.specialty}

Date: ${dateFormat.format(widget.appointment.dateTime)}
Time: ${timeFormat.format(widget.appointment.dateTime)}
Location: ${widget.appointment.doctor.location}

Patient: ${widget.appointment.patientName}
Reason: ${widget.appointment.reasonForVisit}

Booking Reference: ${widget.appointment.id}

Please arrive 15 minutes before your appointment time.
''';

    Share.share(shareText, subject: 'Appointment Confirmation');
  }

  void _copyBookingReference() {
    Clipboard.setData(ClipboardData(text: widget.appointment.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Booking reference copied to clipboard'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPhone = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isPhone ? 16 : 24),
      child: Column(
        children: [
          // Success Animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Success Message
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  'Booking Confirmed!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your appointment has been successfully booked',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.getTextColor(context, isDescription: true),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Booking Reference Card
          _buildBookingReferenceCard(context, theme),

          const SizedBox(height: 24),

          // Appointment Details Card
          _buildAppointmentDetailsCard(context, theme, l10n),

          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context, theme, l10n, isPhone),

          const SizedBox(height: 24),

          // Done Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onDone,
              style: AppTheme.getPrimaryButtonStyle(context).copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingReferenceCard(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.accentColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Booking Reference',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.appointment.id,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _copyBookingReference,
                icon: const Icon(Icons.copy, size: 20),
                color: AppTheme.primaryColor,
                tooltip: 'Copy reference',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Save this reference for your records',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      decoration: AppTheme.getCardDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Details',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Doctor Info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.appointment.doctor.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appointment.doctor.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.getTextColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.appointment.doctor.specialty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: AppTheme.getBorderColor(context)),
          const SizedBox(height: 20),

          // Date & Time
          _buildDetailRow(
            context,
            theme,
            icon: Icons.calendar_today,
            label: 'Date',
            value: dateFormat.format(widget.appointment.dateTime),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            theme,
            icon: Icons.access_time,
            label: 'Time',
            value: timeFormat.format(widget.appointment.dateTime),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            theme,
            icon: Icons.location_on,
            label: 'Location',
            value: widget.appointment.doctor.location,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            theme,
            icon: Icons.medical_services_outlined,
            label: 'Reason',
            value: widget.appointment.reasonForVisit,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.getTextColor(context, isDescription: true),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    bool isPhone,
  ) {
    if (isPhone) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addToCalendar,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Add to Calendar'),
              style: AppTheme.getSecondaryButtonStyle(context).copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _shareDetails,
              icon: const Icon(Icons.share),
              label: const Text('Share Details'),
              style: AppTheme.getSecondaryButtonStyle(context).copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _addToCalendar,
            icon: const Icon(Icons.calendar_today),
            label: const Text('Add to Calendar'),
            style: AppTheme.getSecondaryButtonStyle(context).copyWith(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _shareDetails,
            icon: const Icon(Icons.share),
            label: const Text('Share Details'),
            style: AppTheme.getSecondaryButtonStyle(context).copyWith(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
