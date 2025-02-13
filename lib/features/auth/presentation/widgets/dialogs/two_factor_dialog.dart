import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_event.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_state.dart';

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
                        const Text('Chargement...'),
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
          'Authentification à Deux Facteurs',
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
            print('[2025-02-13 22:55:59] 🔵 Widget: Enable 2FA button pressed');
            context.read<TwoFactorAuthBloc>().add(EnableTwoFactorAuthEvent());
          },
          icon: const Icon(Icons.qr_code),
          label: const Text('Activer 2FA'),
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
            Navigator.of(context).pop(); // Ferme le dialogue
            widget.onSkip(); // Appelle le callback de navigation
          },
          child: const Text('Plus tard'),
        ),
      ],
    );
  }

  Widget _buildQRSection(String qrCodeUrl) {
    return Column(
      children: [
        const Text(
          'Scannez ce QR code avec votre application d\'authentification',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: QrImageView(
            data: qrCodeUrl,
            size: 200,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Entrez le code à 6 chiffres de votre application',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: _pinController,
          obscureText: true,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: Colors.white,
            activeColor: Colors.blue,
            selectedColor: Colors.blue,
            inactiveColor: Colors.grey.shade300,
          ),
          onCompleted: (code) {
            context.read<TwoFactorAuthBloc>().add(
                  VerifyTwoFactorAuthEvent(code),
                );
          },
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _buildSuccessSection() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 64,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        const Text(
          'L\'authentification à deux facteurs a été activée avec succès !',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Terminer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
