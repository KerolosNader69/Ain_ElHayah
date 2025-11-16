import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../screens/doctors_screen.dart';
import '../screens/booking_form_screen.dart';

class BookingReviewScreen extends StatelessWidget {
  final Doctor doctor;
  final DateTime selectedDateTime;
  final BookingFormData formData;
  final VoidCallback onEditDoctor;
  final VoidCallback onEditDateTime;
  final VoidCallback onEditPatientInfo;
  final VoidCallback onConfirmBooking;

  const BookingReviewScreen({
    super.key,
    required this.doctor,
    required this.selectedDateTime,
    required this.formData,
    required this.onEditDoctor,
    required this.onEditDateTime,
    required this.onEditPatientInfo,
    required this.onConfirmBooking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPhone = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isPhone ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Review Appointment',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Please review your appointment details before confirming',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Doctor Information Section
          _buildDoctorSection(context, theme, l10n),
          
          const SizedBox(height: 16),
          
          // Appointment Details Section
          _buildAppointmentDetailsSection(context, theme, l10n),
          
          const SizedBox(height: 16),
          
          // Patient Information Section
          _buildPatientInfoSection(context, theme, l10n),
          
          const SizedBox(height: 24),
          
          // Important Notice
          _buildNoticeBox(context, theme),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirmBooking,
                  style: AppTheme.getPrimaryButtonStyle(context).copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: const Text('Confirm Booking'),
                ),
              ),
              
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onEditPatientInfo,
                  style: AppTheme.getSecondaryButtonStyle(context).copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: const Text('Edit Information'),
                ),
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
      title: 'Doctor',
      onEdit: onEditDoctor,
      child: Row(
        children: [
          // Doctor Image
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
                doctor.image,
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
          
          // Doctor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.getTextColor(context, isDescription: true),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.getTextColor(context, isDescription: true),
                        ),
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

  Widget _buildAppointmentDetailsSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return _buildSection(
      context,
      theme,
      title: 'Appointment Details',
      onEdit: onEditDateTime,
      child: Column(
        children: [
          _buildInfoRow(
            context,
            theme,
            icon: Icons.calendar_today,
            label: 'Date',
            value: dateFormat.format(selectedDateTime),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.access_time,
            label: 'Time',
            value: timeFormat.format(selectedDateTime),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.location_on,
            label: 'Location',
            value: doctor.location,
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
      onEdit: onEditPatientInfo,
      child: Column(
        children: [
          _buildInfoRow(
            context,
            theme,
            icon: Icons.person_outline,
            label: 'Name',
            value: formData.patientName,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.email_outlined,
            label: 'Email',
            value: formData.patientEmail,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: formData.patientPhone,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            theme,
            icon: Icons.medical_services_outlined,
            label: 'Reason',
            value: formData.reasonForVisit,
          ),
          if (formData.notes != null && formData.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              theme,
              icon: Icons.notes_outlined,
              label: 'Notes',
              value: formData.notes!,
              isMultiline: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required Widget child,
    required VoidCallback onEdit,
  }) {
    return Container(
      decoration: AppTheme.getCardDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
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
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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

  Widget _buildNoticeBox(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.accentColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please arrive 15 minutes before your appointment time. '
                  'Bring a valid ID and insurance card if applicable.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.getTextColor(context, isDescription: true),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
