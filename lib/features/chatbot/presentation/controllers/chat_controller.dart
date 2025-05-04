// lib/features/chatbot/presentation/controllers/chat_controller.dart
import 'package:flutter/material.dart';
import '../../../../core/services/gemini_service.dart';
import '../../domain/entities/message.dart';

class ChatController extends ChangeNotifier {
  final GeminiService _geminiService;
  final List<Message> _messages = [];
  bool _isLoading = false;
  int _messageIdCounter = 0;
  ResponseLength _currentResponseLength = ResponseLength.medium;
  ResponseLength get responseLength => _currentResponseLength;
set responseLength(ResponseLength length) {
  _currentResponseLength = length;
  notifyListeners();
}

  ChatController({required GeminiService geminiService}) 
      : _geminiService = geminiService {
    // Add initial greeting message
    _addMessage(
      Message(
        id: _generateMessageId(),
        content: "Hello! I'm your investment assistant. How can I help you with land tokenization investments today?",
        isFromUser: false,
      ),
    );
  }

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  String _generateMessageId() {
    _messageIdCounter++;
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_$_messageIdCounter';
  }

  void _addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void _updateLastMessage(Message message) {
    if (_messages.isNotEmpty) {
      _messages[_messages.length - 1] = message;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add user message
    final userMessage = Message(
      id: _generateMessageId(),
      content: text,
      isFromUser: true,
      isSent: false, // Initially mark as not sent
    );
    _addMessage(userMessage);
    
    // Mark user message as sent after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      final index = _messages.indexOf(userMessage);
      if (index != -1) {
        _messages[index] = Message(
          id: userMessage.id,
          content: userMessage.content,
          isFromUser: true,
          timestamp: userMessage.timestamp,
          isSent: true,
        );
        notifyListeners();
      }
    });
    
    // Set loading state
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get response from Gemini
      final response = await _geminiService.getInvestmentAdvice(
      text, 
      length: _currentResponseLength
    );
      
      // Add assistant response
      _addMessage(Message(
      id: _generateMessageId(),
      content: response,
      isFromUser: false,
    ));
    } catch (e) {
      // Add error message
      _addMessage(Message(
        id: _generateMessageId(),
        content: "I'm sorry, I couldn't process your request. Please try again later.",
        isFromUser: false,
      ));
      debugPrint('Error in chat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _messageIdCounter = 0;
    
    // Add initial greeting message again
    _addMessage(
      Message(
        id: _generateMessageId(),
        content: "Hello! I'm your investment assistant. How can I help you with land tokenization investments today?",
        isFromUser: false,
      ),
    );
  }

  // Additional functionality for enhanced chat features
  
  void retryLastMessage() {
    if (_messages.length >= 2) {
      final lastUserMessage = _messages.reversed.firstWhere(
        (msg) => msg.isFromUser,
        orElse: () => _messages.last,
      );
      
      if (lastUserMessage.isFromUser) {
        // Remove any error messages after the last user message
        final lastUserIndex = _messages.indexOf(lastUserMessage);
        if (lastUserIndex != -1 && lastUserIndex < _messages.length - 1) {
          _messages.removeRange(lastUserIndex + 1, _messages.length);
          notifyListeners();
        }
        
        // Resend the message
        sendMessage(lastUserMessage.content);
      }
    }
  }

  void deleteMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
  }

  void editMessage(String messageId, String newContent) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final oldMessage = _messages[index];
      _messages[index] = Message(
        id: oldMessage.id,
        content: newContent,
        isFromUser: oldMessage.isFromUser,
        timestamp: oldMessage.timestamp,
        isSent: oldMessage.isSent,
      );
      notifyListeners();
      
      // If it's a user message, resend to get new response
      if (oldMessage.isFromUser) {
        // Remove any assistant messages after this
        _messages.removeRange(index + 1, _messages.length);
        sendMessage(newContent);
      }
    }
  }

  // Message search functionality
  List<Message> searchMessages(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return _messages.where((message) => 
      message.content.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Export chat history
  String exportChatHistory() {
    final buffer = StringBuffer();
    buffer.writeln('Chat History - ${DateTime.now()}');
    buffer.writeln('----------------------------------------');
    
    for (var message in _messages) {
      final sender = message.isFromUser ? 'You' : 'Assistant';
      final time = _formatDateTime(message.timestamp);
      buffer.writeln('[$time] $sender: ${message.content}');
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}