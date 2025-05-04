import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;

  const Failure({this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({String? message}) : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String? message}) : super(message: message);
}

// You might want to add other failure types based on your application needs
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({String? message}) : super(message: message);
}