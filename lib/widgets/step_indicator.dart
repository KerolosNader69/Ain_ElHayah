import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepTitles;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Step dots with connecting lines
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;

            return Row(
              children: [
                _StepDot(
                  stepNumber: index + 1,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                ),
                if (index < totalSteps - 1)
                  Container(
                    width: 40,
                    height: 2,
                    color: isCompleted
                        ? AppTheme.primaryColor
                        : AppTheme.getBorderColor(context),
                  ),
              ],
            );
          }),
        ),
        
        // Step title (if provided)
        if (stepTitles != null && currentStep < stepTitles!.length) ...[
          const SizedBox(height: 12),
          Text(
            stepTitles![currentStep],
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int stepNumber;
  final bool isCompleted;
  final bool isCurrent;

  const _StepDot({
    required this.stepNumber,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Widget child;

    if (isCompleted) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
      child = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (isCurrent) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
      child = Text(
        stepNumber.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    } else {
      backgroundColor = AppTheme.getMutedBackgroundColor(context);
      textColor = AppTheme.getTextColor(context, isDescription: true);
      child = Text(
        stepNumber.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isCurrent
            ? Border.all(
                color: AppTheme.primaryColor,
                width: 2,
              )
            : null,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(child: child),
    );
  }
}
