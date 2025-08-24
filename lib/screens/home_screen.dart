import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/app_header.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 72,
            collapsedHeight: 72,
            expandedHeight: 72,
            flexibleSpace: const SizedBox.expand(child: AppHeader()),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeroSection(context),
                _buildAIModelsSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    
    return Container(
      constraints: const BoxConstraints(minHeight: 600),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            
            return isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _buildHeroContent(context),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: _buildHeroImage(context),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildHeroContent(context),
                      const SizedBox(height: 48),
                      _buildHeroImage(context),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 48),
        
        // Enhanced Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.aiPoweredEyeDiagnosis,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Enhanced Main Heading
        RichText(
          text: TextSpan(
            style: theme.textTheme.displayLarge?.copyWith(
              color: AppTheme.getTextColor(context),
            ),
            children: [
              TextSpan(text: '${l10n.smartEyeDiagnosis}\n'),
              TextSpan(
                text: l10n.aiTechnology,
                style: TextStyle(
                  foreground: Paint()
                    ..shader = AppTheme.primaryGradient.createShader(
                      const Rect.fromLTWH(0, 0, 300, 60),
                    ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Enhanced Description
        Text(
          l10n.heroDescription,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.getTextColor(context, isDescription: true),
            height: 1.6,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Enhanced Action Buttons
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // Enhanced primary button
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.go('/diagnosis'),
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.startFreeDiagnosis),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Enhanced secondary button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: OutlinedButton(
                onPressed: () {
                  final l10n = AppLocalizations.of(context)!;
                  showDialog(
                    context: context,
                    builder: (context) {
                      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
                      return Directionality(
                        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                        child: AlertDialog(
                          backgroundColor: AppTheme.getSurfaceColor(context),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Row(
                            children: [
                              Text(
                                l10n.aboutAppTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Text(
                              l10n.readMeContent,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.getTextColor(context, isDescription: true),
                                height: 1.6,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.close),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.learnMore,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 48),
        
        // Enhanced Features (responsive)
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isPhone = width < 600;
            if (isPhone) {
              // On phones: 2-column grid to avoid overflow
              return GridView.count(
                crossAxisCount: width < 360 ? 1 : 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: width < 360 ? 3.6 : 2.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFeatureTile(context, Icons.chat_bubble_outline, l10n.aiPoweredChat, l10n.voiceAssistant),
                  _buildFeatureTile(context, Icons.location_on, l10n.findDoctors, l10n.nearbyLocations),
                  _buildFeatureTile(context, Icons.medical_services, l10n.instantDiagnosis, l10n.aiAnalysis),
                  _buildFeatureTile(context, Icons.language, l10n.multiLanguage, l10n.arabicEnglish),
                ],
              );
            }
            // On tablets/desktop: keep horizontal row
            return Row(
              children: [
                Expanded(child: _buildFeatureTile(context, Icons.chat_bubble_outline, l10n.aiPoweredChat, l10n.voiceAssistant)),
                const SizedBox(width: 16),
                Expanded(child: _buildFeatureTile(context, Icons.location_on, l10n.findDoctors, l10n.nearbyLocations)),
                const SizedBox(width: 16),
                Expanded(child: _buildFeatureTile(context, Icons.medical_services, l10n.instantDiagnosis, l10n.aiAnalysis)),
                const SizedBox(width: 16),
                Expanded(child: _buildFeatureTile(context, Icons.language, l10n.multiLanguage, l10n.arabicEnglish)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureTile(BuildContext context, IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    final isPhone = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 16),
      decoration: AppTheme.getGlassmorphismDecoration(context, opacity: 0.1),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isPhone ? 8 : 10),
            decoration: BoxDecoration(
              gradient: AppTheme.aiGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isPhone ? 18 : 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.w600,
                    fontSize: isPhone ? 13 : 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.getTextColor(context, isDescription: true),
                    fontSize: isPhone ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/images/futuristic-eye.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildAIModelsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          
          // Enhanced Section Header
          Text(
            l10n.aiModels,
            style: theme.textTheme.displayMedium?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            l10n.chooseFromAdvancedModels,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          // Enhanced AI Models Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 768;
              
              return isDesktop
                  ? Row(
                      children: [
                        Expanded(child: _buildAIModelCard(context, true)), // Retinal Lens
                        const SizedBox(width: 24),
                        Expanded(child: _buildAIModelCard(context, false)), // Selfie Close Up
                      ],
                    )
                  : Column(
                      children: [
                        _buildAIModelCard(context, true), // Retinal Lens
                        const SizedBox(height: 24),
                        _buildAIModelCard(context, false), // Selfie Close Up
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAIModelCard(BuildContext context, bool isRetinalLens) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: AppTheme.getCardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isRetinalLens ? AppTheme.primaryGradient : AppTheme.secondaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isRetinalLens ? AppTheme.primaryColor : AppTheme.warningColor).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isRetinalLens ? Icons.visibility : Icons.camera_alt,
                color: Colors.white,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              isRetinalLens ? l10n.retinalLens : l10n.selfieCloseUp,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              isRetinalLens 
                  ? l10n.retinalLensDescription
                  : l10n.selfieCloseUpDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getTextColor(context, isDescription: true),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Features list
            Column(
              children: [
                _buildFeatureRow(context, l10n.highAccuracy, '99.2%'),
                _buildFeatureRow(context, l10n.fastResults, '< 30 seconds'),
                _buildFeatureRow(context, l10n.multipleConditions, '50+ detected'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/diagnosis'),
                style: AppTheme.getPrimaryButtonStyle(context),
                child: Text(isRetinalLens ? l10n.tryRetinalLens : l10n.trySelfieCloseUp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for hero section background pattern
class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    
    // Draw grid pattern
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}