// lib/features/chatbot/presentation/controllers/chat_controller.dart
import 'package:flutter/material.dart';
import '../../../../core/services/gemini_service.dart';
import '../../domain/entities/chat_message.dart';

class ChatController extends ChangeNotifier {
  final GeminiService _geminiService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatController({required GeminiService geminiService}) 
      : _geminiService = geminiService {
    // Add initial greeting message
    _messages.add(
      ChatMessage.fromAssistant(
        "Hello! I'm your investment assistant. How can I help you with land tokenization investments today?",
      ),
    );
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add user message
    final userMessage = ChatMessage.fromUser(text);
    _messages.add(userMessage);
    
    // Add loading message from assistant
    final loadingMessage = ChatMessage.fromAssistant("", isLoading: true);
    _messages.add(loadingMessage);
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get response from Gemini
      final response = await _geminiService.getInvestmentAdvice(text);
      
      // Replace loading message with actual response
      _messages.removeLast();
      _messages.add(ChatMessage.fromAssistant(response));
    } catch (e) {
      // Replace loading message with error message
      _messages.removeLast();
      _messages.add(ChatMessage.fromAssistant(
        "I'm sorry, I couldn't process your request. Please try again later."
      ));
      print('Error in chat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    // Add initial greeting message again
    _messages.add(
      ChatMessage.fromAssistant(
        "Hello! I'm your investment assistant. How can I help you with land tokenization investments today?",
      ),
    );
    notifyListeners();
  }
}