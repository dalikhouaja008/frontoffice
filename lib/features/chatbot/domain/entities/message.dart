// lib/features/chatbot/domain/entities/message.dart
class Message {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;
  final bool isSent;

  Message({
    required this.id,
    required this.content,
    required this.isFromUser,
    DateTime? timestamp,
    this.isSent = true,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}