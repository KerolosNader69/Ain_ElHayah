import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/doctor_provider.dart';
import '../theme/app_theme.dart';
import '../models/patient_models.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  String _selectedPatientId = '';
  String _selectedType = 'note';
  bool _isLoading = false;
  List<NoteAttachment> _attachments = [];

  final List<Map<String, String>> _noteTypes = [
    {'value': 'note', 'label': 'General Note', 'icon': 'note'},
    {'value': 'report', 'label': 'Medical Report', 'icon': 'description'},
    {'value': 'prescription', 'label': 'Prescription', 'icon': 'medication'},
    {'value': 'diagnosis', 'label': 'Diagnosis', 'icon': 'medical_services'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);

      final note = PatientNote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: _selectedPatientId,
        doctorId: auth.email ?? 'unknown',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: DateTime.now(),
        type: _selectedType,
        attachments: _attachments,
      );

      await doctorProvider.addNote(note);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getNoteTypeLabel(_selectedType)} added successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        context.go('/doctor/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getNoteTypeLabel(String type) {
    return _noteTypes.firstWhere((t) => t['value'] == type)['label'] ?? 'Note';
  }

  Future<void> _pickFile() async {
    // Simulate file picker - in a real app, you'd use file_picker package
    // For now, we'll simulate adding a file
    final attachment = NoteAttachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: 'medical_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      filePath: '/documents/medical_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      fileType: 'pdf',
      fileSize: 1024000, // 1MB
      uploadedAt: DateTime.now(),
    );

    setState(() {
      _attachments.add(attachment);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File "${attachment.fileName}" added successfully'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  IconData _getNoteTypeIcon(String type) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);

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
          'Add Medical Note',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.note_add,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add Medical Note',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create notes, reports, prescriptions, or diagnoses for your patients',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Patient Selection
              _buildSectionHeader('Select Patient', Icons.person_outline, theme),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getMutedBackgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.getBorderColor(context),
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedPatientId.isEmpty ? null : _selectedPatientId,
                  decoration: AppTheme.getInputDecoration(
                    context,
                    hintText: 'Choose a patient',
                    prefixIcon: Icons.people_outline,
                  ),
                  style: TextStyle(color: AppTheme.getTextColor(context)),
                  items: doctorProvider.patients.map((patient) {
                    return DropdownMenuItem<String>(
                      value: patient.id,
                      child: Text(patient.fullName),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedPatientId = value ?? ''),
                  validator: (value) => value == null || value.isEmpty ? 'Please select a patient' : null,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Note Type Selection
              _buildSectionHeader('Note Type', Icons.category_outlined, theme),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getMutedBackgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.getBorderColor(context),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: _noteTypes.map((type) {
                    return RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(
                            _getNoteTypeIcon(type['value']!),
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            type['label']!,
                            style: TextStyle(color: AppTheme.getTextColor(context)),
                          ),
                        ],
                      ),
                      value: type['value']!,
                      groupValue: _selectedType,
                      onChanged: (value) => setState(() => _selectedType = value!),
                      activeColor: AppTheme.primaryColor,
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Note Content
              _buildSectionHeader('Note Content', Icons.edit_outlined, theme),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _titleController,
                decoration: AppTheme.getInputDecoration(
                  context,
                  hintText: 'Note Title',
                  prefixIcon: Icons.title,
                ),
                style: TextStyle(color: AppTheme.getTextColor(context)),
                validator: (v) => v == null || v.isEmpty ? 'Please enter a title' : null,
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _contentController,
                decoration: AppTheme.getInputDecoration(
                  context,
                  hintText: 'Enter your note content here...',
                  prefixIcon: Icons.description_outlined,
                ),
                maxLines: 8,
                style: TextStyle(color: AppTheme.getTextColor(context)),
                validator: (v) => v == null || v.isEmpty ? 'Please enter note content' : null,
              ),
              
              const SizedBox(height: 32),
              
              // File Attachments Section
              _buildSectionHeader('File Attachments', Icons.attach_file, theme),
              const SizedBox(height: 16),
              
              // Upload Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.getMutedBackgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.getBorderColor(context),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload File',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.getTextColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to select files (PDF, DOC, Images, etc.)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.getTextColor(context, isDescription: true),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Attachments List
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Attached Files',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ..._attachments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final attachment = entry.value;
                  return _buildAttachmentCard(attachment, index, theme);
                }),
              ],
              
              const SizedBox(height: 40),
              
              // Add Note Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addNote,
                  style: AppTheme.getPrimaryButtonStyle(context).copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Add ${_getNoteTypeLabel(_selectedType)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/doctor/dashboard'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.getBorderColor(context)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.getTextColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentCard(NoteAttachment attachment, int index, ThemeData theme) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                attachment.fileIcon,
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
                    attachment.fileName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.getTextColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${attachment.fileType.toUpperCase()} • ${attachment.fileSizeFormatted}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextColor(context, isDescription: true),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeAttachment(index),
              icon: Icon(
                Icons.close,
                color: Colors.red,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
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
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
