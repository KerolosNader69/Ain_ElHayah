import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/doctor_provider.dart';
import '../theme/app_theme.dart';
import '../models/patient_models.dart';

class NoteDetailScreen extends StatelessWidget {
  final String noteId;
  
  const NoteDetailScreen({
    super.key,
    required this.noteId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);
    
    // Find the note by ID
    PatientNote? note;
    for (final n in doctorProvider.notes) {
      if (n.id == noteId) {
        note = n;
        break;
      }
    }
    
    if (note == null) {
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
            'Note Not Found',
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
                'Note not found',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This note may have been deleted or does not exist',
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

    final patient = doctorProvider.getPatientById(note.patientId);

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
          note.title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: Implement edit functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality coming soon'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note Header
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getNoteIcon(note.type),
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppTheme.getTextColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getNoteTypeLabel(note.type),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(note.createdAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.getTextColor(context, isDescription: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: AppTheme.getTextColor(context, isDescription: true),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        patient?.fullName ?? 'Unknown Patient',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.getTextColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Note Content
            Text(
              'Note Content',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.getMutedBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
                ),
              ),
              child: Text(
                note.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.getTextColor(context),
                  height: 1.6,
                ),
              ),
            ),
            
            // Attachments Section
            if (note.attachments.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'Attachments',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...note.attachments.map((attachment) => _buildAttachmentCard(context, attachment, theme)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentCard(BuildContext context, NoteAttachment attachment, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Implement file viewing/downloading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${attachment.fileName}'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  attachment.fileIcon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attachment.fileName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.getTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${attachment.fileType.toUpperCase()} • ${attachment.fileSizeFormatted}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uploaded ${_formatDate(attachment.uploadedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.download,
                color: AppTheme.primaryColor,
                size: 24,
              ),
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
