abstract class Failure {
  final String message;
  
  const Failure({required this.message});  // Change to named parameter
  
  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});  // Change to named parameter
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});  // Change to named parameter
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network connection failed'});  // Change to named parameter
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});  // Change to named parameter
}