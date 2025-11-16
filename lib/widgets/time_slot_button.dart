import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/time_slot.dart';

class TimeSlotButton extends StatelessWidget {
  final TimeSlot timeSlot;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeSlotButton({
    super.key,
    required this.timeSlot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (!timeSlot.isAvailable) {
      backgroundColor = AppTheme.getMutedBackgroundColor(context);
      textColor = AppTheme.getTextColor(context, isDescription: true)
          .withOpacity(0.5);
      borderColor = AppTheme.getBorderColor(context).withOpacity(0.5);
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
      borderColor = AppTheme.primaryColor;
    } else {
      backgroundColor = AppTheme.getMutedBackgroundColor(context);
      textColor = AppTheme.getTextColor(context);
      borderColor = AppTheme.getBorderColor(context);
    }

    return InkWell(
      onTap: timeSlot.isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            timeSlot.displayTime,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
