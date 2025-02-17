import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_event.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_state.dart';
import 'package:the_boost/features/auth/presentation/widgets/OTP/custom_pin_input.dart';
import 'package:the_boost/features/auth/presentation/widgets/Qr%20Code/custom_qr_display.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/success_dialog.dart';

class TwoFactorDialog extends StatefulWidget {
  final User user;
  final VoidCallback onSkip;

  const TwoFactorDialog({
    super.key,
    required this.user,
    required this.onSkip,
  });

  @override
  State<TwoFactorDialog> createState() => _TwoFactorDialogState();
}

class _TwoFactorDialogState extends State<TwoFactorDialog> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TwoFactorAuthBloc, TwoFactorAuthState>(
      listener: (context, state) {
        if (state is TwoFactorAuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is TwoFactorAuthLoginSuccess) {
          Navigator.of(context).pop(); // Ferme le dialogue
          // Naviguer vers la page d'accueil ou autre
        }
      },
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      if (state is TwoFactorAuthLoading) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text('Please wait...'),
                      ] else if (state is TwoFactorAuthEnabled) ...[
                        _buildQRSection(state.qrCodeUrl),
                      ] else if (state is TwoFactorAuthVerified) ...[
                        _buildSuccessSection(),
                      ] else ...[
                        _buildInitialSection(),
                      ],
                    ],
                  ),
                ),
              ),
              if (state is TwoFactorAuthLoading)
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.security,
          size: 48,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        Text(
          'Two-Factor Authentication',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInitialSection() {
    return Column(
      children: [
        const Text(
          'Renforcez la sécurité de votre compte en activant l\'authentification à deux facteurs.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            print('TwoFactorDialog:🔵 Widget: Enable 2FA button pressed');
            context.read<TwoFactorAuthBloc>().add( EnableTwoFactorAuthEvent());
          },
          icon: const Icon(Icons.qr_code),
          label: const Text('Activate 2FA'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            widget.onSkip(); // Appelle le callback de navigation
          },
          child: const Text('Later'),
        ),
      ],
    );
  }

Widget _buildQRSection(String qrCodeUrl) {
  return Column(
    children: [
      CustomQrDisplay(
        qrData: qrCodeUrl,
        title: 'Scan Qr Code with your 2FA application',
        onRefresh: () {
          context.read<TwoFactorAuthBloc>().add( EnableTwoFactorAuthEvent());
        },
      ),
      const SizedBox(height: 24),
      CustomPinInput(
        controller: _pinController,
        onCompleted: (code) {
          context.read<TwoFactorAuthBloc>().add(
                VerifyTwoFactorAuthEvent(code),
              );
        },
        title: 'Enter your app\'s 6-digit code',
      ),
    ],
  );
}

Widget _buildSuccessSection() {
  return SuccessDialog(
    title: 'Two-factor authentication has been successfully enabled!',
    buttonText: 'Terminer',
    onButtonPressed: () => Navigator.of(context).pop(),
  );
}

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
