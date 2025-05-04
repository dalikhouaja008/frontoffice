import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/chatbot/domain/entities/message.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';

// Enum for response length settings
enum ResponseLength {
  short,
  medium, 
  long
}

class InvestmentAssistantScreen extends StatefulWidget {
  const InvestmentAssistantScreen({Key? key}) : super(key: key);

  @override
  _InvestmentAssistantScreenState createState() => _InvestmentAssistantScreenState();
}

class _InvestmentAssistantScreenState extends State<InvestmentAssistantScreen> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isSearching = false;
  String _searchQuery = '';
  ResponseLength _responseLength = ResponseLength.medium;

  final List<String> _suggestedQuestions = [
    "What is land tokenization?",
    "How can I start investing in tokenized land?",
    "What are the risks of land investment?",
    "How do I diversify my land investments?",
    "What is the minimum investment amount?",
    "How do I get returns on my investment?",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
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

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<ChatController>(
        builder: (context, chatController, child) => Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy message'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message copied to clipboard')),
                  );
                },
              ),
              if (message.isFromUser) ...[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit message'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(message);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Resend message'),
                  onTap: () {
                    Navigator.pop(context);
                    chatController.sendMessage(message.content);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete message', 
                  style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  chatController.deleteMessage(message.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Message message) {
    final editController = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          maxLines: 5,
          minLines: 1,
          decoration: const InputDecoration(
            hintText: 'Edit your message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newContent = editController.text.trim();
              if (newContent.isNotEmpty) {
                context.read<ChatController>().editMessage(message.id, newContent);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show response length selection dialog
  void _showResponseLengthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Response Length'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildResponseLengthOption(
              ResponseLength.short,
              'Short',
              'Brief answers (1-2 paragraphs)',
            ),
            _buildResponseLengthOption(
              ResponseLength.medium,
              'Medium',
              'Balanced answers (2-3 paragraphs)',
            ),
            _buildResponseLengthOption(
              ResponseLength.long,
              'Long',
              'Detailed answers (3-4 paragraphs)',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper to build response length radio options
  Widget _buildResponseLengthOption(ResponseLength length, String title, String subtitle) {
    return RadioListTile<ResponseLength>(
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      value: length,
      groupValue: _responseLength,
      onChanged: (value) {
        setState(() {
          _responseLength = value!;
          // Here you would update your ChatController with the new setting
          // context.read<ChatController>().setResponseLength(value);
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : _buildAppBarTitle(),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: _buildAppBarActions(),
      ),
      body: Column(
        children: [
          Container(height: 1, color: Colors.grey[200]),
          
          // Response length indicator
          _buildResponseLengthIndicator(),
          
          Expanded(
            child: Consumer<ChatController>(
              builder: (context, chatController, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                
                final messages = _searchQuery.isEmpty
                    ? chatController.messages
                    : chatController.searchMessages(_searchQuery);
                
                return AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation.value,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      itemCount: messages.length + 
                          (chatController.isLoading && _searchQuery.isEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && chatController.isLoading) {
                          return const TypingIndicator();
                        }
                        final message = messages[index];
                        return GestureDetector(
                          onLongPress: () => _showMessageOptions(message),
                          child: ChatBubble(message: message),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (!_isSearching) ...[
            Consumer<ChatController>(
              builder: (context, chatController, child) {
                if (chatController.messages.length == 1) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSuggestedQuestions(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            _buildInputArea(),
          ],
        ],
      ),
    );
  }

  // New widget to show response length indicator
  Widget _buildResponseLengthIndicator() {
    String lengthText;
    Color indicatorColor;
    
    switch (_responseLength) {
      case ResponseLength.short:
        lengthText = 'Short responses';
        indicatorColor = Colors.green;
        break;
      case ResponseLength.medium:
        lengthText = 'Medium responses';
        indicatorColor = Colors.blue;
        break;
      case ResponseLength.long:
        lengthText = 'Detailed responses';
        indicatorColor = Colors.purple;
        break;
    }
    
    return GestureDetector(
      onTap: _showResponseLengthDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: indicatorColor.withOpacity(0.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_line_spacing,
              size: 14,
              color: indicatorColor,
            ),
            const SizedBox(width: 4),
            Text(
              lengthText,
              style: TextStyle(
                fontSize: 12,
                color: indicatorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: indicatorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.assistant, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Investment Assistant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Always here to help',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search messages...',
        border: InputBorder.none,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ),
      ];
    }
    
    return [
      // Response length control button
      IconButton(
        icon: const Icon(Icons.format_size),
        tooltip: 'Response length',
        onPressed: _showResponseLengthDialog,
      ),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() {
            _isSearching = true;
          });
        },
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          final controller = context.read<ChatController>();
          switch (value) {
            case 'clear':
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Chat'),
                  content: const Text('Are you sure you want to clear all messages?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        controller.clearChat();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              break;
            case 'export':
              final chatHistory = controller.exportChatHistory();
              Clipboard.setData(ClipboardData(text: chatHistory));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat history copied to clipboard')),
              );
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'clear',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Clear Chat', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'export',
            child: Row(
              children: [
                Icon(Icons.download),
                SizedBox(width: 8),
                Text('Export Chat'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildSuggestedQuestions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Questions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestedQuestions.map((question) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final controller = context.read<ChatController>();
                        controller.sendMessage(question);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          question,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
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
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Ask about investing...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
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
                    // Response length quick toggle
                    IconButton(
                      icon: Icon(
                        _getResponseLengthIcon(),
                        color: _getResponseLengthColor(),
                        size: 20,
                      ),
                      onPressed: _showResponseLengthDialog,
                      tooltip: 'Adjust response length',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Consumer<ChatController>(
              builder: (context, chatController, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: chatController.isLoading 
                        ? Colors.grey[400] 
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: chatController.isLoading
                          ? null
                          : () {
                              final text = _messageController.text;
                              if (text.trim().isNotEmpty) {
                                chatController.sendMessage(text);
                                _messageController.clear();
                              }
                            },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          chatController.isLoading 
                              ? Icons.stop 
                              : Icons.send,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper methods for response length UI
  IconData _getResponseLengthIcon() {
    switch (_responseLength) {
      case ResponseLength.short:
        return Icons.short_text;
      case ResponseLength.medium:
        return Icons.subject;
      case ResponseLength.long:
        return Icons.format_align_justify;
    }
  }
  
  Color _getResponseLengthColor() {
    switch (_responseLength) {
      case ResponseLength.short:
        return Colors.green;
      case ResponseLength.medium:
        return Colors.blue;
      case ResponseLength.long:
        return Colors.purple;
    }
  }
}