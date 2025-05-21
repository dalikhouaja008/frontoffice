// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  
  ServerException({required this.message});
  
  @override
  String toString() => 'ServerException: $message';
}

class ConnectionException implements Exception {
  final String message;
  
  ConnectionException({required this.message});
  
  @override
  String toString() => 'ConnectionException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  
  AuthenticationException({required this.message});
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class TimeoutException implements Exception {
  final String message;
  
  TimeoutException({required this.message});
  
  @override
  String toString() => 'TimeoutException: $message';
}

class CorsException implements Exception {
  final String message;
  
  CorsException({required this.message});
  
  @override
  String toString() => 'CorsException: $message';
}

class CacheException implements Exception {
  final String message;
  
  CacheException({required this.message});
  
  @override
  String toString() => 'CacheException: $message';
}