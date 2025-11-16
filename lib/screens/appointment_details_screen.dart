import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/appointment.dart';
import '../models/appointment_status.dart';
import '../providers/appointment_provider.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
  });

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text(
          'Are you sure you want to cancel this appointment? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Appointment'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelAppointment(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(BuildContext context) {
    final provider = context.read<AppointmentProvider>();
    provider.cancelAppointment(appointment.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Appointment cancelled successfully'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // Navigate back
    Navigator.of(context).pop();
  }

  void _copyBookingReference(BuildContext context) {
    Clipboard.setData(ClipboardData(text: appointment.id));
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointment Details',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isPhone ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            _buildStatusSection(context, theme),

            const SizedBox(height: 24),

            // Booking Reference Card
            _buildBookingReferenceCard(context, theme),

            const SizedBox(height: 24),

            // Doctor Information
            _buildDoctorSection(context, theme, l10n),

            const SizedBox(height: 16),

            // Appointment Information
            _buildAppointmentInfoSection(context, theme, l10n),

            const SizedBox(height: 16),

            // Patient Information
            _buildPatientInfoSection(context, theme, l10n),

            const SizedBox(height: 24),

            // Cancel Button (only for upcoming appointments)
            if (appointment.status == AppointmentStatus.upcoming)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelConfirmation(context),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Appointment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, ThemeData theme) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String statusText;

    switch (appointment.status) {
      case AppointmentStatus.upcoming:
        backgroundColor = AppTheme.accentColor.withOpacity(0.1);
        textColor = AppTheme.accentColor;
        icon = Icons.schedule;
        statusText = 'Upcoming Appointment';
        break;
      case AppointmentStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        icon = Icons.check_circle;
        statusText = 'Completed Appointment';
        break;
      case AppointmentStatus.cancelled:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        icon = Icons.cancel;
        statusText = 'Cancelled Appointment';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingReferenceCard(BuildContext context, ThemeData theme) {
    return Container(
      decoration: AppTheme.getCardDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Reference',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.getMutedBackgroundColor(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.getBorderColor(context),
                    ),
                  ),
                  child: Text(
                    appointment.id,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _copyBookingReference(context),
                icon: const Icon(Icons.copy),
                color: AppTheme.primaryColor,
                tooltip: 'Copy reference',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return _buildSection(
      context,
      theme,
      title: 'Doctor Information',
      child: Row(
        children: [
          // Doctor Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                appointment.doctor.image,
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
                      size: 36,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Doctor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.doctor.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.doctor.specialty,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${appointment.doctor.rating} (${appointment.doctor.reviews} ${l10n.reviews})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfoSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final createdFormat = DateFormat('MMM d, yyyy \'at\' h:mm a');

    return _buildSection(
      context,
      theme,
      title: 'Appointment Information',
      child: Column(
        children: [
          _buildInfoRow(
            context,
            theme,
            icon: Icons.calendar_today,
            label: 'Date',
            value: dateFormat.format(appointment.dateTime),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.access_time,
            label: 'Time',
            value: timeFormat.format(appointment.dateTime),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.location_on,
            label: 'Location',
            value: appointment.doctor.location,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.medical_services_outlined,
            label: 'Reason for Visit',
            value: appointment.reasonForVisit,
          ),
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              theme,
              icon: Icons.notes_outlined,
              label: 'Additional Notes',
              value: appointment.notes!,
            ),
          ],
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.history,
            label: 'Booked On',
            value: createdFormat.format(appointment.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return _buildSection(
      context,
      theme,
      title: 'Patient Information',
      child: Column(
        children: [
          _buildInfoRow(
            context,
            theme,
            icon: Icons.person_outline,
            label: 'Name',
            value: appointment.patientName,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.email_outlined,
            label: 'Email',
            value: appointment.patientEmail,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: appointment.patientPhone,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: AppTheme.getCardDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
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
}
