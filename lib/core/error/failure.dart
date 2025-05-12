abstract class Failure {
  final String message;
  
  const Failure({required this.message}); 
  
  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message: 'erreur');  
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network connection failed'});  
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}