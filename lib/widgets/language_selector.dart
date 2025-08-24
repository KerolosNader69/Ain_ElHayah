import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return PopupMenuButton<Locale>(
      child: Container(
        height: 48, // Fixed height to match nav items
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkMuted.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              appProvider.locale.languageCode == 'ar' ? 'العربية' : 'English',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 16,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
          ],
        ),
      ),
      onSelected: (Locale locale) {
        appProvider.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('ar'),
          child: Row(
            children: [
              const Text('🇪🇬'),
              const SizedBox(width: 8),
              Text(l10n.arabic),
              if (appProvider.locale.languageCode == 'ar')
                const Spacer(),
              if (appProvider.locale.languageCode == 'ar')
                const Icon(Icons.check, color: AppTheme.primaryColor),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Row(
            children: [
              const Text('🇬🇧'),
              const SizedBox(width: 8),
              Text(l10n.english),
              if (appProvider.locale.languageCode == 'en')
                const Spacer(),
              if (appProvider.locale.languageCode == 'en')
                const Icon(Icons.check, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ],
    );
  }
}
