import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';
import 'language_selector.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: Container(
        height: 80, // Fixed header height
        decoration: BoxDecoration(
          color: AppTheme.darkSurface.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1024;
              
              return isDesktop
                  ? _buildDesktopHeader(context)
                  : _buildMobileHeader(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentPath = GoRouterState.of(context).uri.path;
    
    return Row(
      children: [
        const AppLogo(),
        const Spacer(),
        _buildNavItems(context, currentPath),
        const SizedBox(width: 32),
        _buildHeaderActions(context),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Row(
      children: [
        const AppLogo(),
        const Spacer(),
        _buildMobileMenu(context),
        const SizedBox(width: 8),
        _buildCompactLanguageButton(context),
        const SizedBox(width: 8),
        _buildIconButton(
          context,
          Icons.settings,
          () => context.go('/settings'),
        ),
      ],
    );
  }

  Widget _buildNavItems(BuildContext context, String currentPath) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 768;
        
        if (isSmallScreen) {
          // For small screens, use a horizontal scrollable list
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNavItem(context, l10n.appTitle, '/', currentPath == '/'),
                _buildNavItem(context, l10n.diagnosis, '/diagnosis', currentPath == '/diagnosis'),
                _buildNavItem(context, l10n.chat, '/chat', currentPath == '/chat'),
                _buildNavItem(context, l10n.doctors, '/doctors', currentPath == '/doctors'),
              ],
            ),
          );
        } else {
          // For larger screens, use regular row
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavItem(context, l10n.appTitle, '/', currentPath == '/'),
              _buildNavItem(context, l10n.diagnosis, '/diagnosis', currentPath == '/diagnosis'),
              _buildNavItem(context, l10n.chat, '/chat', currentPath == '/chat'),
              _buildNavItem(context, l10n.doctors, '/doctors', currentPath == '/doctors'),
            ],
          );
        }
      },
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.darkMuted.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.menu, color: Colors.white),
        color: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) => context.go(value),
        itemBuilder: (context) => [
          PopupMenuItem(value: '/', child: Text(l10n.appTitle)),
          PopupMenuItem(value: '/diagnosis', child: Text(l10n.diagnosis)),
          PopupMenuItem(value: '/chat', child: Text(l10n.chat)),
          PopupMenuItem(value: '/doctors', child: Text(l10n.doctors)),
        ],
      ),
    );
  }

  Widget _buildCompactLanguageButton(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: AppTheme.darkMuted.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: PopupMenuButton<Locale>(
        icon: const Icon(Icons.language, color: Colors.white, size: 20),
        color: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) => appProvider.setLocale(value),
        itemBuilder: (context) => const [
          PopupMenuItem(value: Locale('ar'), child: Text('العربية')),
          PopupMenuItem(value: Locale('en'), child: Text('English')),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String text, String path, bool isActive) {
    final theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 768;
        
        return Container(
          margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go(path),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48, // Fixed height for consistency
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20, 
                  vertical: 12
                ),
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppTheme.primaryColor.withOpacity(0.15)
                      : AppTheme.darkMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive 
                        ? AppTheme.primaryColor 
                        : AppTheme.getBorderColor(context),
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isActive 
                          ? AppTheme.primaryColor 
                          : Colors.white,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      fontSize: isSmallScreen ? 16 : 18,
                      height: 1.2,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LanguageSelector(),
        const SizedBox(width: 16),
        _buildIconButton(
          context,
          Icons.settings,
          () => context.go('/settings'),
        ),
      ],
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48, // Fixed height to match other elements
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}