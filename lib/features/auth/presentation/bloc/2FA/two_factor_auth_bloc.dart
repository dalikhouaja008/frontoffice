import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'package:the_boost/features/auth/domain/entities/login_response.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'two_factor_auth_event.dart';
import 'two_factor_auth_state.dart';

class TwoFactorAuthBloc extends Bloc<TwoFactorAuthEvent, TwoFactorAuthState> {

  final TwoFactorAuthRepository repository;
  static const int _maxConcurrentRequests = 1;
  static const String _timestamp = '2025-02-17 11:58:43';
  static const String _user = 'raednas';
  int _currentRequests = 0;

  TwoFactorAuthBloc({required this.repository}) :super(const TwoFactorAuthInitial()) {
    on<EnableTwoFactorAuthEvent>(_onEnableTwoFactorAuth);
    on<VerifyTwoFactorAuthEvent>(_onVerifyTwoFactorAuth);
    on<VerifyTwoFactorLoginEvent>(_onVerifyTwoFactorLogin);
  }

  Future<void> _onEnableTwoFactorAuth(
    EnableTwoFactorAuthEvent event,
    Emitter<TwoFactorAuthState> emit,
  ) async {
    print('[$_timestamp] TwoFactorAuthBloc: 🚀 Enable 2FA requested'
          '\n└─ User: $_user');

    emit(const TwoFactorAuthLoading());

    try {
      print('[$_timestamp] TwoFactorAuthBloc: 📡 Generating QR code'
            '\n└─ User: $_user');
          
      final qrCodeUrl = await repository.enableTwoFactorAuth();
      
      print('[$_timestamp] TwoFactorAuthBloc: ✅ QR code generated'
            '\n└─ User: $_user');
          
      emit(TwoFactorAuthEnabled(qrCodeUrl));
    } catch (e) {
      print('[$_timestamp] TwoFactorAuthBloc: ❌ QR code generation failed'
            '\n└─ User: $_user'
            '\n└─ Error: $e');

      emit(TwoFactorAuthError(_formatErrorMessage(e)));
    }
  }

  Future<void> _onVerifyTwoFactorAuth(
    VerifyTwoFactorAuthEvent event,
    Emitter<TwoFactorAuthState> emit,
  ) async {
    print('[$_timestamp] TwoFactorAuthBloc: 🔐 Verifying setup code'
          '\n└─ User: $_user'
          '\n└─ Code length: ${event.code.length}');

    emit(const TwoFactorAuthLoading());

    try {
      print('[$_timestamp] TwoFactorAuthBloc: 📡 Validating setup code'
            '\n└─ User: $_user');

      final isVerified = await repository.verifyTwoFactorAuth(event.code);
      
      if (isVerified) {
        print('[$_timestamp] TwoFactorAuthBloc: ✅ Setup verified'
              '\n└─ User: $_user');
        emit(const TwoFactorAuthVerified());
      } else {
        print('[$_timestamp] TwoFactorAuthBloc: ⚠️ Invalid setup code'
              '\n└─ User: $_user');
        emit(const TwoFactorAuthError('Code de vérification invalide'));
      }
    } catch (e) {
      print('[$_timestamp] TwoFactorAuthBloc: ❌ Setup verification failed'
            '\n└─ User: $_user'
            '\n└─ Error: $e');
      
      emit(TwoFactorAuthError(_formatErrorMessage(e)));
    }
  }

  Future<void> _onVerifyTwoFactorLogin(
    VerifyTwoFactorLoginEvent event,
    Emitter<TwoFactorAuthState> emit,
  ) async {
    print('[$_timestamp] TwoFactorAuthBloc: 🔐 Verifying login OTP'
          '\n└─ User: $_user'
          '\n└─ Code length: ${event.code.length}'
          // ignore: unnecessary_null_comparison
          '\n└─ Has tempToken: ${event.tempToken != null}');

    if (_currentRequests >= _maxConcurrentRequests) {
      print('[$_timestamp] TwoFactorAuthBloc: ⚠️ Request blocked'
            '\n└─ User: $_user'
            '\n└─ Reason: Concurrent request limit');
          
      emit(const TwoFactorAuthError(
        'Une vérification est déjà en cours. Veuillez patienter.',
      ));
      return;
    }

    try {
      _currentRequests++;
      emit(const TwoFactorAuthLoading());

      print('[$_timestamp] TwoFactorAuthBloc: 📡 Verifying with repository'
            '\n└─ User: $_user');

      final LoginResponse response = await repository.verifyLoginOtp(
        event.tempToken!,  // Assurez-vous que tempToken est en premier !
        event.code,
      );

      if (!isClosed) {
        if (response.accessToken != null && response.refreshToken != null) {
          print('[$_timestamp] TwoFactorAuthBloc: ✅ Login successful'
                '\n└─ User: $_user'
                '\n└─ Email: ${response.user?.email}');

          emit(TwoFactorAuthLoginSuccess(
            user: response.user!,
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken!,
          ));
        } else {
          print('[$_timestamp] TwoFactorAuthBloc: ❌ Missing tokens'
                '\n└─ User: $_user'
                '\n└─ Has accessToken: ${response.accessToken != null}'
                '\n└─ Has refreshToken: ${response.refreshToken != null}');
              
          emit(const TwoFactorAuthError(
            'Erreur d\'authentification: jetons manquants ou invalides',
          ));
        }
      }
    } catch (e) {
      if (!isClosed) {
        print('[$_timestamp] TwoFactorAuthBloc: ❌ Verification failed'
              '\n└─ User: $_user'
              '\n└─ Error: $e');
            
        emit(TwoFactorAuthError(_formatErrorMessage(e)));
      }
    } finally {
      _currentRequests--;
    }
  }

  @override
  Future<void> close() {
    print('[$_timestamp] TwoFactorAuthBloc: 🔄 Closing bloc'
          '\n└─ User: $_user');
    _currentRequests = 0;
    return super.close();
  }

  String _formatErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    print('[$_timestamp] TwoFactorAuthBloc: 🔍 Formatting error'
          '\n└─ User: $_user'
          '\n└─ Raw error: $error');

    if (errorStr.contains('token')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    } else if (errorStr.contains('network')) {
      return 'Erreur de connexion. Vérifiez votre connexion internet.';
    } else if (errorStr.contains('invalid')) {
      return 'Code invalide. Veuillez réessayer.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}