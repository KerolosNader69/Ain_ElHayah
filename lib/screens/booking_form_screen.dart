import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class BookingFormData {
  String patientName;
  String patientEmail;
  String patientPhone;
  String reasonForVisit;
  String? notes;

  BookingFormData({
    this.patientName = '',
    this.patientEmail = '',
    this.patientPhone = '',
    this.reasonForVisit = '',
    this.notes,
  });
}

class BookingFormScreen extends StatefulWidget {
  final BookingFormData? initialData;
  final Function(BookingFormData formData) onFormSubmitted;

  const BookingFormScreen({
    super.key,
    this.initialData,
    required this.onFormSubmitted,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  
  String _selectedReason = '';
  
  final List<String> _reasonOptions = [
    'Routine Eye Exam',
    'Vision Problems',
    'Eye Pain or Discomfort',
    'Follow-up Appointment',
    'Contact Lens Fitting',
    'Diabetic Eye Screening',
    'Glaucoma Screening',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? BookingFormData();
    _nameController = TextEditingController(text: data.patientName);
    _emailController = TextEditingController(text: data.patientEmail);
    _phoneController = TextEditingController(text: data.patientPhone);
    _notesController = TextEditingController(text: data.notes);
    _selectedReason = data.reasonForVisit.isEmpty 
        ? _reasonOptions[0] 
        : data.reasonForVisit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }
    
    return null;
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      final formData = BookingFormData(
        patientName: _nameController.text.trim(),
        patientEmail: _emailController.text.trim(),
        patientPhone: _phoneController.text.trim(),
        reasonForVisit: _selectedReason,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );
      
      widget.onFormSubmitted(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPhone = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isPhone ? 16 : 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Patient Information',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Please provide your contact details',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getTextColor(context, isDescription: true),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Form Card
            Container(
              decoration: AppTheme.getCardDecoration(context),
              padding: EdgeInsets.all(isPhone ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Name
                  _buildLabel(context, theme, 'Full Name *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    validator: _validateName,
                    decoration: _buildInputDecoration(
                      context,
                      hintText: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                    ),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Email
                  _buildLabel(context, theme, 'Email Address *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
                    decoration: _buildInputDecoration(
                      context,
                      hintText: 'your.email@example.com',
                      prefixIcon: Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Phone
                  _buildLabel(context, theme, 'Phone Number *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    validator: _validatePhone,
                    decoration: _buildInputDecoration(
                      context,
                      hintText: '(555) 123-4567',
                      prefixIcon: Icons.phone_outlined,
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Reason for Visit
                  _buildLabel(context, theme, 'Reason for Visit *'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedReason,
                    decoration: _buildInputDecoration(
                      context,
                      hintText: 'Select reason',
                      prefixIcon: Icons.medical_services_outlined,
                    ),
                    items: _reasonOptions.map((reason) {
                      return DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedReason = value;
                        });
                      }
                    },
                    dropdownColor: AppTheme.darkSurface,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Additional Notes
                  _buildLabel(context, theme, 'Additional Notes (Optional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    decoration: _buildInputDecoration(
                      context,
                      hintText: 'Any additional information about your condition...',
                      prefixIcon: Icons.notes_outlined,
                    ),
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your information is kept confidential and will only be used for appointment purposes.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onContinue,
                style: AppTheme.getPrimaryButtonStyle(context).copyWith(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                child: const Text('Continue to Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        color: AppTheme.getTextColor(context),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppTheme.getTextColor(context, isDescription: true),
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: AppTheme.getTextColor(context, isDescription: true),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppTheme.primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: AppTheme.getMutedBackgroundColor(context),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 12,
      ),
    );
  }
}
