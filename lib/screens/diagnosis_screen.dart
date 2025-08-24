import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/diagnosis_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'package:go_router/go_router.dart';

class DiagnosisScreen extends StatelessWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                     // Hero Section
                   _buildHeroSection(context, l10n),
                   const SizedBox(height: 48),
                   
                   // AI Models Section
                   _buildAIModelsSection(context, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaireCard(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode.startsWith('ar');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'تشخيص بدون صورة' : 'Diagnosis without photo',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'أجب عن استبيان قصير، وسنقترح أمراضاً محتملة بناءً على إجاباتك.'
                : 'Answer a short questionnaire and we will suggest likely eye conditions.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/diagnosis/questionnaire'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                isArabic ? 'ابدأ الاستبيان' : 'Start questionnaire',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.darkSurface.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              l10n.aiPoweredEyeDiagnosis,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Main Heading
          Text(
            l10n.smartEyeDiagnosis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.1,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          Text(
            l10n.aiTechnology,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Description
          Text(
            l10n.heroDescription,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              height: 1.6,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          
        ],
      ),
    );
  }

  Widget _buildAIModelsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiPoweredDiagnosisModels,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.chooseFromAdvancedModels,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 18,
            height: 1.5,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 32),
        
        // Model Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 768;
            
            if (isSmallScreen) {
              return Column(
                children: [
                  _buildModelCard(context, l10n, 'retinal'),
                  const SizedBox(height: 16),
                  _buildModelCard(context, l10n, 'selfie'),
                  const SizedBox(height: 16),
                  _buildQuestionnaireCard(context),
                ],
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildModelCard(context, l10n, 'retinal')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildModelCard(context, l10n, 'selfie')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildQuestionnaireCard(context)),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildModelCard(BuildContext context, AppLocalizations l10n, String modelType) {
    String title;
    String description;
    String accuracy;
    String time;
    String imageType;
    
    switch (modelType) {
      case 'retinal':
        title = l10n.retinalLens;
        description = l10n.retinalLensDescription;
        accuracy = l10n.retinalAccuracy;
        time = l10n.retinalTime;
        imageType = l10n.retinalPhoto;
        break;
      case 'selfie':
        title = l10n.selfieCloseUp;
        description = l10n.selfieCloseUpDescription;
        accuracy = l10n.selfieAccuracy;
        time = l10n.selfieTime;
        imageType = l10n.closeUpSelfie;
        break;
      default:
        title = '';
        description = '';
        accuracy = '';
        time = '';
        imageType = '';
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStat(l10n.accuracy, accuracy),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStat(l10n.analysisTime, time),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStat(l10n.imageType, imageType),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _onSelectModelPressed(context, modelType, l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                modelType == 'retinal' ? l10n.tryRetinalLens :
                l10n.trySelfieCloseUp,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSelectModelPressed(BuildContext context, String modelType, AppLocalizations l10n) async {
    final diagnosisProvider = context.read<DiagnosisProvider>();
    diagnosisProvider.selectModel(modelType);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.close)),
        );
        return;
      }

      final bytes = await image.readAsBytes();
      diagnosisProvider.setImageBytes(bytes);
    } catch (_) {
      // ignore
    }

    // Run analysis with a visible loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        // Kick off analysis once the dialog is shown
        Future.microtask(() async {
          await diagnosisProvider.analyzeImage();
          if (context.mounted) Navigator.of(context).pop();

          final error = diagnosisProvider.error;
          if (error != null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
            }
            return;
          }

          final result = diagnosisProvider.diagnosisResult;
          if (result != null && context.mounted) {
            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  backgroundColor: AppTheme.getSurfaceColor(ctx),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(l10n.smartEyeDiagnosis),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%'),
                        const SizedBox(height: 12),
                        Text('Detected Conditions:'),
                        const SizedBox(height: 6),
                        ...result.conditions.map((c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text('- ${c.name} (${c.severity}) • ${(c.confidence * 100).toStringAsFixed(1)}%'),
                            )),
                        const SizedBox(height: 12),
                        Text('Recommendations:'),
                        const SizedBox(height: 6),
                        ...result.recommendations.map((r) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text('- $r'),
                            )),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(l10n.close),
                    ),
                  ],
                );
              },
            );
          }
        });
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }


}
