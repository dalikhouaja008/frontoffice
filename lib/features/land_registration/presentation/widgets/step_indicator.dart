import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepIndex = index ~/ 2;
              return Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: stepIndex < currentStep
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8)
                            ],
                          )
                        : null,
                    color: stepIndex < currentStep ? null : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            } else {
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < currentStep;
              final isActive = stepIndex == currentStep;

              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : isActive
                          ? AppColors.primary.withOpacity(0.8)
                          : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? AppColors.primary : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isCompleted || isActive
                          ? Colors.white
                          : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.map((step) {
            final stepIndex = steps.indexOf(step);
            final isActive = stepIndex == currentStep;
            return Expanded(
              child: Text(
                step,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? AppColors.primary
                      : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}