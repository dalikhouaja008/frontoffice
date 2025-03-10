// lib/features/auth/presentation/widgets/dialogs/preferences_alert_dialog.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';

class PreferencesAlertDialog extends StatelessWidget {
  final User user;

  const PreferencesAlertDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  Widget _buildPreferenceItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      title: Row(
        children: [
          Icon(Icons.tune, color: AppColors.primary),
          const SizedBox(width: AppDimensions.paddingS),
          const Text('Set Your Preferences'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customize your investment preferences to get notified about lands that match your criteria.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          const Text(
            'You can set:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          _buildPreferenceItem(Icons.category, 'Land types you\'re interested in'),
          _buildPreferenceItem(Icons.attach_money, 'Price range for investments'),
          _buildPreferenceItem(Icons.location_on, 'Preferred locations'),
          _buildPreferenceItem(Icons.notifications, 'Notification preferences'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(
              AppRoutes.preferences,
              arguments: user,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Set Preferences'),
        ),
      ],
    );
  }
}