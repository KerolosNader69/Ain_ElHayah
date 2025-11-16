import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/doctor_provider.dart';
import '../theme/app_theme.dart';
import '../models/patient_models.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  
  const PatientDetailScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);
    
    final patient = doctorProvider.getPatientById(widget.patientId);
    if (patient == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/doctor/dashboard'),
          ),
          title: Text(
            'Patient Not Found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.getTextColor(context, isDescription: true),
              ),
              const SizedBox(height: 16),
              Text(
                'Patient not found',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This patient may have been deleted or does not exist',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextColor(context, isDescription: true),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final patientNotes = doctorProvider.getNotesForPatient(patient.id);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/doctor/dashboard'),
        ),
        title: Text(
          patient.fullName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => context.go('/doctor/add-note'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getMutedBackgroundColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    patient.fullName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.getTextColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${patient.age} years • ${patient.gender}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.getTextColor(context, isDescription: true),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoItem('Email', patient.email, Icons.email_outlined, theme),
                      _buildInfoItem('Phone', patient.phone, Icons.phone_outlined, theme),
                      _buildInfoItem('Added', _formatDate(patient.dateAdded), Icons.calendar_today_outlined, theme),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Medical Information
            if (patient.medicalHistory != null || patient.allergies != null || patient.currentMedications != null) ...[
              Text(
                'Medical Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              if (patient.medicalHistory != null) ...[
                _buildMedicalInfoCard(
                  'Medical History',
                  patient.medicalHistory!,
                  Icons.history,
                  theme,
                ),
                const SizedBox(height: 16),
              ],
              
              if (patient.allergies != null) ...[
                _buildMedicalInfoCard(
                  'Allergies',
                  patient.allergies!,
                  Icons.warning_outlined,
                  theme,
                ),
                const SizedBox(height: 16),
              ],
              
              if (patient.currentMedications != null) ...[
                _buildMedicalInfoCard(
                  'Current Medications',
                  patient.currentMedications!,
                  Icons.medication_outlined,
                  theme,
                ),
                const SizedBox(height: 24),
              ],
            ],
            
            // Notes Section
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Medical Notes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.getTextColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/doctor/add-note'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Note'),
                  style: AppTheme.getPrimaryButtonStyle(context),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (patientNotes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.getMutedBackgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.getBorderColor(context),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 48,
                      color: AppTheme.getTextColor(context, isDescription: true),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notes yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first medical note for this patient',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...patientNotes.map((note) => _buildNoteCard(note, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.getTextColor(context, isDescription: true),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMedicalInfoCard(String title, String content, IconData icon, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(PatientNote note, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.go('/doctor/note/${note.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNoteIcon(note.type),
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.getTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(note.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextColor(context, isDescription: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getNoteTypeLabel(note.type),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextColor(context, isDescription: true),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Show attachments if any
              if (note.attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${note.attachments.length} attachment${note.attachments.length > 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNoteIcon(String type) {
    switch (type) {
      case 'report':
        return Icons.description;
      case 'prescription':
        return Icons.medication;
      case 'diagnosis':
        return Icons.medical_services;
      default:
        return Icons.note;
    }
  }

  String _getNoteTypeLabel(String type) {
    switch (type) {
      case 'report':
        return 'Medical Report';
      case 'prescription':
        return 'Prescription';
      case 'diagnosis':
        return 'Diagnosis';
      default:
        return 'General Note';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
