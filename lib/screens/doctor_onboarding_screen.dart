import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class DoctorOnboardingScreen extends StatefulWidget {
  const DoctorOnboardingScreen({super.key});

  @override
  State<DoctorOnboardingScreen> createState() => _DoctorOnboardingScreenState();
}

class _DoctorOnboardingScreenState extends State<DoctorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _medicalIdController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _yearsExperienceController = TextEditingController();
  final TextEditingController _workplaceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // File upload state
  String? _idDocumentPath;
  String? _licenseDocumentPath;
  bool _isUploading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _medicalIdController.dispose();
    _specializationController.dispose();
    _yearsExperienceController.dispose();
    _workplaceController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.completeDoctorOnboarding();
    
    if (mounted) {
      context.go('/');
    }
  }

  Future<void> _simulateFileUpload(String type) async {
    setState(() => _isUploading = true);
    
    // Simulate file upload
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isUploading = false;
      if (type == 'id') {
        _idDocumentPath = 'uploaded_id_document.pdf';
      } else {
        _licenseDocumentPath = 'uploaded_license_document.pdf';
      }
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type document uploaded successfully'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
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
          onPressed: () => context.go('/login'),
        ),
        title: Text(
          'Doctor Onboarding',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < _totalSteps - 1 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? AppTheme.primaryColor
                              : AppTheme.getMutedBackgroundColor(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getTextColor(context, isDescription: true),
                  ),
                ),
              ],
            ),
          ),
          
          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoStep(),
                  _buildProfessionalInfoStep(),
                  _buildVerificationStep(),
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == _totalSteps - 1
                        ? _completeOnboarding
                        : _nextStep,
                    style: AppTheme.getPrimaryButtonStyle(context).copyWith(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1 ? 'Complete Setup' : 'Next',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getMutedBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                          Icons.person_outline,
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
                              'Personal Information',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppTheme.getTextColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Tell us about yourself',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.getTextColor(context, isDescription: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: AppTheme.getInputDecoration(
                      context,
                      hintText: 'Full Name',
                      prefixIcon: Icons.person_outline,
                    ),
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter your full name' : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Email Verification
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
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoStep() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getMutedBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                          Icons.medical_services_outlined,
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
                              'Professional Information',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppTheme.getTextColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Your medical credentials',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.getTextColor(context, isDescription: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Medical ID / License Number
                  TextFormField(
                    controller: _medicalIdController,
                    decoration: AppTheme.getInputDecoration(
                      context,
                      hintText: 'Medical ID / License Number',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter your medical ID or license number' : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Specialization
                  TextFormField(
                    controller: _specializationController,
                    decoration: AppTheme.getInputDecoration(
                      context,
                      hintText: 'Specialization',
                      prefixIcon: Icons.medical_information_outlined,
                    ),
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter your specialization' : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Years of Experience
                  TextFormField(
                    controller: _yearsExperienceController,
                    decoration: AppTheme.getInputDecoration(
                      context,
                      hintText: 'Years of Experience',
                      prefixIcon: Icons.schedule_outlined,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter your years of experience';
                      }
                      final years = int.tryParse(v);
                      if (years == null || years < 0 || years > 50) {
                        return 'Please enter a valid number of years (0-50)';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Workplace / Hospital
                  TextFormField(
                    controller: _workplaceController,
                    decoration: AppTheme.getInputDecoration(
                      context,
                      hintText: 'Workplace / Hospital',
                      prefixIcon: Icons.business_outlined,
                    ),
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter your workplace or hospital' : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getMutedBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                          Icons.verified_user_outlined,
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
                              'Document Verification',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppTheme.getTextColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Upload your credentials (Optional)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.getTextColor(context, isDescription: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // ID Document Upload
                  _buildDocumentUploadCard(
                    title: 'Upload ID / Proof',
                    subtitle: 'Medical license, ID card, or other verification documents',
                    icon: Icons.upload_file_outlined,
                    isUploaded: _idDocumentPath != null,
                    onUpload: () => _simulateFileUpload('id'),
                    isLoading: _isUploading,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // License Document Upload
                  _buildDocumentUploadCard(
                    title: 'Upload License Document',
                    subtitle: 'Official medical license or certification',
                    icon: Icons.description_outlined,
                    isUploaded: _licenseDocumentPath != null,
                    onUpload: () => _simulateFileUpload('license'),
                    isLoading: _isUploading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Verification notice
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Document verification is optional but recommended for enhanced trust and credibility.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onUpload,
    required bool isLoading,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded 
              ? AppTheme.primaryColor 
              : AppTheme.getBorderColor(context),
          width: isUploaded ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isLoading ? null : onUpload,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUploaded 
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.getMutedBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle : icon,
                  color: isUploaded 
                      ? AppTheme.primaryColor 
                      : AppTheme.getTextColor(context, isDescription: true),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.getTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextColor(context, isDescription: true),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                )
              else if (isUploaded)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 24,
                )
              else
                Icon(
                  Icons.upload_outlined,
                  color: AppTheme.getTextColor(context, isDescription: true),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
