// lib/features/auth/presentation/widgets/dialogs/preferences_alert_dialog.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/pages/preferences/user_preferences_screen.dart';

class PreferencesAlertDialog extends StatelessWidget {
  final User user;
  
  const PreferencesAlertDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.paddingL),
          _buildBody(),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.backgroundGreen,
          radius: 40,
          child: Icon(
            Icons.tune,
            color: AppColors.primary,
            size: 40,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Text(
          'Set Your Land Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Text(
          'Help us find the perfect land investments for you by setting your preferences.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.paddingL),
        _buildPreferenceItem(
          icon: Icons.category,
          title: 'Land Types',
          description: 'Select types of land you\'re interested in.',
        ),
        _buildPreferenceItem(
          icon: Icons.paid,
          title: 'Price Range',
          description: 'Set your investment budget.',
        ),
        _buildPreferenceItem(
          icon: Icons.location_on,
          title: 'Locations',
          description: 'Choose your preferred areas.',
        ),
      ],
    );
  }
  
  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: AppColors.backgroundGreen,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Later',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserPreferencesScreen(user: user),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
          child: Text(
            'Set Preferences',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}