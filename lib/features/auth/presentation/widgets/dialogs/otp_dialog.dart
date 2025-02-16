import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_event.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_state.dart';
import 'package:the_boost/features/auth/presentation/widgets/OTP/custom_pin_input.dart';
import 'package:the_boost/features/auth/presentation/widgets/custom_button.dart';


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
  static const _timestamp = '2025-02-15 16:16:18';
  static const _user = 'raednas';

  @override
  void initState() {
    super.initState();
    print('[$_timestamp] 🔐 OTP Dialog initialized'
          '\n└─ User: $_user'
          '\n└─ Email: ${widget.email}');
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                      CustomPinInput(
                        controller: _otpController,
                        title: 'Code de vérification',
                        subtitle: 'Entrez le code à 6 chiffres de votre application d\'authentification',
                        onCompleted: (code) {
                          print('[$_timestamp] ✅ OTP input completed'
                                '\n└─ User: $_user'
                                '\n└─ Code length: ${code.length}');

                          context.read<TwoFactorAuthBloc>().add(
                            VerifyTwoFactorLoginEvent(
                              code: code,
                              tempToken: widget.tempToken,
                            ),
                          );
                        },
                        showRefreshButton: true,
                        onRefresh: () {
                          print('[$_timestamp] 🔄 OTP refresh requested'
                                '\n└─ User: $_user');
                          _otpController.clear();
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Vérifier',
                        isLoading: state is TwoFactorAuthLoading,
                        onPressed: () {
                          if (_otpController.text.length == 6) {
                            print('[$_timestamp] 🔐 Verifying OTP'
                                  '\n└─ User: $_user'
                                  '\n└─ Email: ${widget.email}');

                            context.read<TwoFactorAuthBloc>().add(
                              VerifyTwoFactorLoginEvent(
                                code: _otpController.text,
                                tempToken: widget.tempToken,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          print('[$_timestamp] 🚫 OTP verification cancelled'
                                '\n└─ User: $_user');
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
    );
  }
}