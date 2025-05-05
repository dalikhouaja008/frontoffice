part of 'login_bloc.dart';



abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginRequested extends LoginEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends LoginEvent {}

class CheckSession extends LoginEvent {}

class Set2FASuccessEvent extends LoginEvent {
  final User user;
  final String accessToken;
  final String refreshToken;

  Set2FASuccessEvent({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object> get props => [user, accessToken, refreshToken];
}