import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/session_service.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_event.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart'; // Ajoutez cette import
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
    print('[2025-05-05 00:20:28] 🔐 OTP Dialog initialized'
        '\n└─ User: nesssim'
        '\n└─ Email: ${widget.email}'
        '\n└─ Attempt: ${_currentRetry + 1}/$_maxRetries');

    // Ajouter un timer de timeout
    _startTimeoutTimer();
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(minutes: 2), () {
      if (mounted) {
        print('[2025-05-05 00:20:28] ⚠️ OTP verification timeout'
            '\n└─ User: nesssim'
            '\n└─ Email: ${widget.email}');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'La session de vérification a expiré. Veuillez réessayer.'),
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
      print('[2025-05-05 00:20:28] ⚠️ Max retries reached'
          '\n└─ User: nesssim'
          '\n└─ Email: ${widget.email}');
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

    print('[2025-05-05 00:20:28] 🔐 Verifying OTP'
        '\n└─ User: nesssim'
        '\n└─ Email: ${widget.email}'
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
    // Essayer d'obtenir le LoginBloc depuis le contexte
    // Il faut que le LoginBloc soit fourni par un parent
    LoginBloc? loginBloc;
    try {
      loginBloc = BlocProvider.of<LoginBloc>(context, listen: false);
      print('[2025-05-05 00:20:28] OtpDialog: ✅ Found LoginBloc in context');
    } catch (e) {
      print('[2025-05-05 00:20:28] OtpDialog: ⚠️ LoginBloc not found in context'
            '\n└─ Error: $e');
      // Si pas disponible, on continuera en utilisant getIt
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: BlocListener<TwoFactorAuthBloc, TwoFactorAuthState>(
        listener: (context, state) {
          if (state is TwoFactorAuthLoginSuccess) {
            print(
                '[2025-05-05 00:20:28] OtpDialog: ✅ 2FA verification successful'
                '\n└─ User: nesssim'
                '\n└─ Email: ${state.user.email}');

            // Save session data after successful 2FA login
            getIt<SessionService>()
                .saveSession(
              user: state.user,
              accessToken: state.accessToken,
              refreshToken: state.refreshToken,
            )
                .then((_) {
              print(
                  '[2025-05-05 00:20:28] OtpDialog: 💾 Session saved after 2FA'
                  '\n└─ User: nesssim');

              // IMPORTANT: Mettre à jour le LoginBloc
              if (loginBloc != null) {
                print('[2025-05-05 00:20:28] OtpDialog: 🔄 Updating LoginBloc state');
                loginBloc.add(
                  Set2FASuccessEvent(
                    user: state.user,
                    accessToken: state.accessToken,
                    refreshToken: state.refreshToken,
                  ),
                );
              } else {
                // Tenter d'obtenir le LoginBloc via getIt si non disponible via le contexte
                print('[2025-05-05 00:20:28] OtpDialog: 🔄 Updating LoginBloc via getIt');
                try {
                  getIt<LoginBloc>().add(
                    Set2FASuccessEvent(
                      user: state.user,
                      accessToken: state.accessToken,
                      refreshToken: state.refreshToken,
                    ),
                  );
                } catch (e) {
                  print('[2025-05-05 00:20:28] OtpDialog: ❌ Failed to update LoginBloc'
                        '\n└─ Error: $e');
                }
              }

              // Ne pas naviguer ici, seulement fermer le dialogue
              // Le parent (LoginScreen) gèrera la navigation
              Navigator.of(context).pop(state); // Passer l'état pour que le parent puisse le gérer
            });
          } else if (state is TwoFactorAuthError) {
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
                            subtitle:
                                'Entrez le code à 6 chiffres de votre application d\'authentification',
                            onCompleted: _handleVerification,
                            showRefreshButton: true,
                            onRefresh: () {
                              print(
                                  '[2025-05-05 00:20:28] 🔄 OTP refresh requested'
                                  '\n└─ User: nesssim'
                                  '\n└─ Email: ${widget.email}');
                              _otpController.clear();
                              _startTimeoutTimer();
                            },
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Vérifier',
                            isLoading: state is TwoFactorAuthLoading,
                            onPressed: () =>
                                _handleVerification(_otpController.text),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              print(
                                  '[2025-05-05 00:20:28] 🚫 OTP verification cancelled'
                                  '\n└─ User: nesssim'
                                  '\n└─ Email: ${widget.email}');
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