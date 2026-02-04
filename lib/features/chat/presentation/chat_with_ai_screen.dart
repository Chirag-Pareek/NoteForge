// lib/features/chat/presentation/chat_with_ai_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../domain/chat_messages.dart';
import 'widgets/chat_history_drawer.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_input_bar.dart';
import '../data/chat_service.dart';


/// Main chat screen with AI assistant
/// Displays messages, history drawer, and input bar
class ChatWithAiScreen extends StatefulWidget {
  const ChatWithAiScreen({super.key});

  @override
  State<ChatWithAiScreen> createState() => _ChatWithAiScreenState();
}

class _ChatWithAiScreenState extends State<ChatWithAiScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  // Current chat state
  List<ChatMessage> _messages = [];
  String _currentTopic = 'New Chat';
  bool _isLoading = false;

  // Chat history state (stored locally in this example)
  // In production, persist this to local storage or database
  final List<ChatHistory> _chatHistories = [];
  String? _activeHistoryId;

  @override
  void initState() {
    super.initState();
    // Initialize with empty chat
    _startNewChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Starts a new chat session
  /// Saves current chat to history if it has messages
  void _startNewChat() {
    setState(() {
      // Save current chat to history if it has messages
      if (_messages.isNotEmpty) {
        _saveCurrentChatToHistory();
      }

      // Reset to new chat
      _messages = [];
      _currentTopic = 'New Chat';
      _activeHistoryId = null;
      _isLoading = false;
    });
  }

  /// Saves current chat session to history
  void _saveCurrentChatToHistory() {
    if (_messages.isEmpty) return;

    final historyItem = ChatHistory(
      id: _activeHistoryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      topic: _currentTopic,
      date: DateTime.now(),
      messages: List.from(_messages),
    );

    setState(() {
      // Remove existing if updating
      _chatHistories.removeWhere((h) => h.id == historyItem.id);
      // Add to beginning (newest first)
      _chatHistories.insert(0, historyItem);
    });
  }

  /// Loads a chat from history
  void _loadChatFromHistory(ChatHistory history) {
    setState(() {
      // Save current chat before switching
      if (_messages.isNotEmpty) {
        _saveCurrentChatToHistory();
      }

      // Load selected chat
      _messages = List.from(history.messages);
      _currentTopic = history.topic;
      _activeHistoryId = history.id;
      _isLoading = false;
    });

    // Close drawer
    Navigator.of(context).pop();

    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  /// Sends a user message and gets AI response
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;

      // Update topic from first message if still "New Chat"
      if (_currentTopic == 'New Chat' && text.length > 5) {
        _currentTopic = text.length > 50 ? '${text.substring(0, 50)}...' : text;
      }
    });

    // Scroll to bottom to show user message
    _scrollToBottom();

    try {
      // Get AI response from ChatGPT API
      final aiResponse = await _chatService.sendMessage(
        userMessage: text,
        conversationHistory: _messages,
      );

      final aiMessage = ChatMessage(
        text: aiResponse,
        isUser: false,
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      // Scroll to show AI response
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) {
        return;
      }
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Scrolls chat to bottom smoothly
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// Shares current chat (placeholder - implement share functionality)
  void _shareChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark
          ? AppColorsDark.background
          : AppColorsLight.background,

      // Top app bar
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColorsDark.background
            : AppColorsLight.background,
        elevation: 0,
        leading: AppIconButton(
          icon: Icons.menu,
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text('Chats', style: AppTextStyles.bodyLarge),
        actions: [
          AppIconButton(icon: Icons.add, onPressed: _startNewChat),
          AppIconButton(icon: Icons.share_outlined, onPressed: _shareChat),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),

      // History drawer (left side)
      drawer: ChatHistoryDrawer(
        chatHistories: _chatHistories,
        onChatSelected: _loadChatFromHistory,
        onDeleteChat: (historyId) {
          setState(() {
            _chatHistories.removeWhere((h) => h.id == historyId);
          });
        },
      ),

      // Main chat body
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the end
                      if (index == _messages.length && _isLoading) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildLoadingBubble(isDark),
                          ),
                        );
                      }

                      final message = _messages[index];
                      return ChatMessageBubble(
                        message: message.text,
                        isUser: message.isUser,
                      );
                    },
                  ),
          ),

          // Chat input bar at bottom
          ChatInputBar(onSendMessage: _sendMessage),
        ],
      ),
    );
  }

  /// Empty state when no messages
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: isDark ? AppColorsDark.border : AppColorsLight.border,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Start a conversation',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark
                  ? AppColorsDark.secondaryText
                  : AppColorsLight.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ask me anything about your studies',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColorsDark.secondaryText
                  : AppColorsLight.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  /// Loading bubble while AI is thinking
  Widget _buildLoadingBubble(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColorsDark.lightBackground
            : AppColorsLight.lightBackground,
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColorsLight.border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark
                    ? AppColorsDark.secondaryText
                    : AppColorsLight.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Thinking...',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColorsDark.secondaryText
                  : AppColorsLight.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for chat history item
class ChatHistory {
  final String id;
  final String topic;
  final DateTime date;
  final List<ChatMessage> messages;

  ChatHistory({
    required this.id,
    required this.topic,
    required this.date,
    required this.messages,
  });
}
