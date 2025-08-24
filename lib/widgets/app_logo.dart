import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  
  const AppLogo({
    super.key,
    this.size = 32,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Eye of Horus Logo Image
        Container(
          width: size,
          height: size,
          child: Image.asset(
            'assets/images/Ain Al-Hayah@Logo.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to simple icon if image fails to load
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(size / 2),
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.visibility,
                    color: AppTheme.primaryColor,
                    size: size * 0.6,
                  ),
                ),
              );
            },
          ),
        ),
        
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            l10n.appTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}