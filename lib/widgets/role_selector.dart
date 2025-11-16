import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// A reusable widget for selecting user role (Patient or Doctor)
/// 
/// This widget displays two role cards with icons, labels, and selection states.
/// It provides visual feedback for the selected role and supports disabled state
/// during loading operations.
class RoleSelector extends StatelessWidget {
  /// The currently selected role
  final UserRole selectedRole;
  
  /// Callback invoked when the user selects a different role
  final ValueChanged<UserRole> onRoleChanged;
  
  /// Whether the role selector is enabled (default: true)
  /// When disabled, the selector will not respond to user interactions
  final bool enabled;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Choose Account Type',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    role: UserRole.patient,
                    icon: Icons.person,
                    label: 'Patient',
                    isSelected: selectedRole == UserRole.patient,
                    enabled: enabled,
                    onTap: () => onRoleChanged(UserRole.patient),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoleCard(
                    role: UserRole.doctor,
                    icon: Icons.medical_services,
                    label: 'Doctor',
                    isSelected: selectedRole == UserRole.doctor,
                    enabled: enabled,
                    onTap: () => onRoleChanged(UserRole.doctor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Internal widget for rendering individual role cards
class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor
                  : AppTheme.getBorderColor(context),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.2)
                      : AppTheme.getMutedBackgroundColor(context),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: isSelected 
                      ? AppTheme.primaryColor
                      : AppTheme.getTextColor(context, isDescription: true),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isSelected 
                      ? AppTheme.primaryColor
                      : AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isSelected) const SizedBox(height: 4),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
