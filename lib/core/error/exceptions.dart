// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
  
  @override
  String toString() => 'ServerException: $message';
}