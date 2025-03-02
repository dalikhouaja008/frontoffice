import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_event.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_state.dart';
import 'package:the_boost/features/auth/presentation/widgets/OTP/custom_pin_input.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/custom_button.dart';

class OtpDialog extends StatefulWidget {
  final String tempToken;
  final String email;

  const OtpDialog({
    Key? key,
    required this.tempToken,
    required this.email,
  }) : super(key: key);

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final TextEditingController _otpController = TextEditingController();
  static const int _maxRetries = 3;
  int _currentRetry = 0;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    print('[${DateTime.now().toUtc()}] 🔐 OTP Dialog initialized'
          '\n└─ User: ${widget.email}'
          '\n└─ Attempt: ${_currentRetry + 1}/$_maxRetries');
    
    // Ajouter un timer de timeout
    _startTimeoutTimer();
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(minutes: 2), () {
      if (mounted) {
        print('[${DateTime.now().toUtc()}] ⚠️ OTP verification timeout'
              '\n└─ User: ${widget.email}');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La session de vérification a expiré. Veuillez réessayer.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _handleVerification(String code) {
    if (!mounted) return;
    
    if (_currentRetry >= _maxRetries) {
      print('[${DateTime.now().toUtc()}] ⚠️ Max retries reached'
            '\n└─ User: ${widget.email}');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trop de tentatives. Veuillez réessayer plus tard.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (code.length != 6) return;

    setState(() => _currentRetry++);
    
    print('[${DateTime.now().toUtc()}] 🔐 Verifying OTP'
          '\n└─ User: ${widget.email}'
          '\n└─ Attempt: $_currentRetry/$_maxRetries');

    context.read<TwoFactorAuthBloc>().add(
      VerifyTwoFactorLoginEvent(
        code: code,
        tempToken: widget.tempToken,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocListener<TwoFactorAuthBloc, TwoFactorAuthState>(
        listener: (context, state) {
          if (state is TwoFactorAuthError) {
            _otpController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Vérification en deux étapes',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<TwoFactorAuthBloc, TwoFactorAuthState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          Text(
                            'Tentative ${_currentRetry + 1}/$_maxRetries',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomPinInput(
                            controller: _otpController,
                            title: 'Code de vérification',
                            subtitle: 'Entrez le code à 6 chiffres de votre application d\'authentification',
                            onCompleted: _handleVerification,
                            showRefreshButton: true,
                            onRefresh: () {
                              print('[${DateTime.now().toUtc()}] 🔄 OTP refresh requested'
                                    '\n└─ User: ${widget.email}');
                              _otpController.clear();
                              _startTimeoutTimer();
                            },
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Vérifier',
                            isLoading: state is TwoFactorAuthLoading,
                            onPressed: () => _handleVerification(_otpController.text),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              print('[${DateTime.now().toUtc()}] 🚫 OTP verification cancelled'
                                    '\n└─ User: ${widget.email}');
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Annuler',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}