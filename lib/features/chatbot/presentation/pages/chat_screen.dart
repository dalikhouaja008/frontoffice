// lib/features/chatbot/presentation/pages/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_bubble.dart';

class InvestmentAssistantScreen extends StatefulWidget {
  const InvestmentAssistantScreen({Key? key}) : super(key: key);

  @override
  _InvestmentAssistantScreenState createState() => _InvestmentAssistantScreenState();
}

class _InvestmentAssistantScreenState extends State<InvestmentAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _suggestedQuestions = [
    "What is land tokenization?",
    "How can I start investing in tokenized land?",
    "What are the risks of land investment?",
    "How do I diversify my land investments?",
    "What is the minimum investment amount?",
    "How do I get returns on my investment?",
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.assistant, color: AppColors.primary),
            const SizedBox(width: 10),
            const Text('Investment Assistant'),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final controller = context.read<ChatController>();
              controller.clearChat();
            },
            tooltip: 'Start New Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatController>(
              builder: (context, chatController, child) {
                // Schedule scrolling after the build is complete
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                  itemCount: chatController.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatController.messages[index];
                    return ChatBubble(message: message);
                  },
                );
              },
            ),
          ),
          
          // Only show suggested questions if chat is still in initial state
          Consumer<ChatController>(
            builder: (context, chatController, child) {
              if (chatController.messages.length == 1) {
                return _buildSuggestedQuestions();
              }
              return const SizedBox.shrink();
            },
          ),
          
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
        itemCount: _suggestedQuestions.length,
        itemBuilder: (context, index) {
          final question = _suggestedQuestions[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                final controller = context.read<ChatController>();
                controller.sendMessage(question);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about investing...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  final controller = context.read<ChatController>();
                  controller.sendMessage(text);
                  _messageController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Consumer<ChatController>(
            builder: (context, chatController, child) {
              return IconButton(
                icon: const Icon(Icons.send),
                color: AppColors.primary,
                onPressed: chatController.isLoading
                    ? null
                    : () {
                        final text = _messageController.text;
                        if (text.trim().isNotEmpty) {
                          chatController.sendMessage(text);
                          _messageController.clear();
                        }
                      },
              );
            },
          ),
        ],
      ),
    );
  }
}