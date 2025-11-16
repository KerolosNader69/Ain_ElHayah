import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/doctor_provider.dart';
import '../theme/app_theme.dart';
import '../models/patient_models.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _currentMedicationsController = TextEditingController();
  
  String _selectedGender = 'Male';
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _currentMedicationsController.dispose();
    super.dispose();
  }

  Future<void> _addPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);

      final patient = Patient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        dateAdded: DateTime.now(),
        doctorId: auth.email ?? 'unknown',
        medicalHistory: _medicalHistoryController.text.trim().isEmpty 
            ? null 
            : _medicalHistoryController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty 
            ? null 
            : _allergiesController.text.trim(),
        currentMedications: _currentMedicationsController.text.trim().isEmpty 
            ? null 
            : _currentMedicationsController.text.trim(),
      );

      await doctorProvider.addPatient(patient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient ${patient.fullName} added successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        context.go('/doctor/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding patient: $e'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'Add Patient',
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
                      Icons.person_add,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add New Patient',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter patient information to add them to your practice',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Personal Information Section
              _buildSectionHeader('Personal Information', Icons.person_outline, theme),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: AppTheme.getInputDecoration(
                        context,
                        hintText: 'First Name',
                        prefixIcon: Icons.person_outline,
                      ),
                      style: TextStyle(color: AppTheme.getTextColor(context)),
                      validator: (v) => v == null || v.isEmpty ? 'Please enter first name' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: AppTheme.getInputDecoration(
                        context,
                        hintText: 'Last Name',
                        prefixIcon: Icons.person_outline,
                      ),
                      style: TextStyle(color: AppTheme.getTextColor(context)),
                      validator: (v) => v == null || v.isEmpty ? 'Please enter last name' : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _emailController,
                decoration: AppTheme.getInputDecoration(
                  context,
                  hintText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: AppTheme.getTextColor(context)),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: AppTheme.getInputDecoration(
                        context,
                        hintText: 'Phone Number',
                        prefixIcon: Icons.phone_outlined,
                      ),
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: AppTheme.getTextColor(context)),
                      validator: (v) => v == null || v.isEmpty ? 'Please enter phone number' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: AppTheme.getInputDecoration(
                        context,
                        hintText: 'Age',
                        prefixIcon: Icons.cake_outlined,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(color: AppTheme.getTextColor(context)),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter age';
                        }
                        final age = int.tryParse(v);
                        if (age == null || age < 0 || age > 120) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Gender Selection
              Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gender',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.getTextColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'Male',
                                style: TextStyle(color: AppTheme.getTextColor(context)),
                              ),
                              value: 'Male',
                              groupValue: _selectedGender,
                              onChanged: (value) => setState(() => _selectedGender = value!),
                              activeColor: AppTheme.primaryColor,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'Female',
                                style: TextStyle(color: AppTheme.getTextColor(context)),
                              ),
                              value: 'Female',
                              groupValue: _selectedGender,
                              onChanged: (value) => setState(() => _selectedGender = value!),
                              activeColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Medical Information Section
              _buildSectionHeader('Medical Information', Icons.medical_information_outlined, theme),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _medicalHistoryController,
                decoration: AppTheme.getInputDecoration(
                  context,
                  hintText: 'Medical History (Optional)',
                  prefixIcon: Icons.history,
                ),
                maxLines: 3,
                style: TextStyle(color: AppTheme.getTextColor(context)),
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _allergiesController,
                decoration: AppTheme.getInputDecoration(
                  context,
                  hintText: 'Allergies (Optional)',
                  prefixIcon: Icons.warning_outlined,
                ),
                maxLines: 2,
                style: TextStyle(color: AppTheme.getTextColor(context)),
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _currentMedicationsController,
                decoration: AppTheme.getInputDecoration(
                  context,
                  hintText: 'Current Medications (Optional)',
                  prefixIcon: Icons.medication_outlined,
                ),
                maxLines: 2,
                style: TextStyle(color: AppTheme.getTextColor(context)),
              ),
              
              const SizedBox(height: 40),
              
              // Add Patient Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addPatient,
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
                          'Add Patient',
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
