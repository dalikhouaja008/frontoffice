part of 'sign_up_bloc.dart';

abstract class SignUpEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SignUpRequested extends SignUpEvent {
  final String username;
  final String email;
  final String password;
  final String role;
  final String? publicKey;
  final GDPRConsent gdprConsent;


  SignUpRequested({required this.username, required this.email, required this.password, required this.role, this.publicKey,
    required this.gdprConsent});

  @override
  List<Object> get props => [username, email, password, role, gdprConsent];
}
