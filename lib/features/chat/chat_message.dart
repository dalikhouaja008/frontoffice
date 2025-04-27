// lib/features/chatbot/domain/entities/chat_message.dart
import 'package:flutter/material.dart';

enum MessageSender {
  user,
  assistant
}

class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.sender,
    DateTime? timestamp,
    this.isLoading = false,
  }) : timestamp = timestamp ?? DateTime.now();

  // Helper method to create a user message
  static ChatMessage fromUser(String text) {
    return ChatMessage(
      text: text,
      sender: MessageSender.user,
    );
  }

  // Helper method to create an assistant message
  static ChatMessage fromAssistant(String text, {bool isLoading = false}) {
    return ChatMessage(
      text: text,
      sender: MessageSender.assistant,
      isLoading: isLoading,
    );
  }
}