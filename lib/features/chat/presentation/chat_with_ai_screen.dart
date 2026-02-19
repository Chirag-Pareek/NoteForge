// lib/features/chat/presentation/chat_with_ai_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../domain/chat_messages.dart';
import '../domain/compose_attachment.dart';
import 'widgets/chat_history_drawer.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_input_bar.dart';
import '../data/chat_service.dart';

/// Main chat screen with AI assistant
/// Displays messages, history drawer, and input bar
class ChatWithAiScreen extends StatefulWidget {
  final TextEditingController? inputController;
  final bool autoFocusInput;
  final VoidCallback? onBackPressed;

  const ChatWithAiScreen({
    super.key,
    this.inputController,
    this.autoFocusInput = false,
    this.onBackPressed,
  });

  @override
  State<ChatWithAiScreen> createState() => _ChatWithAiScreenState();
}

class _ChatWithAiScreenState extends State<ChatWithAiScreen> {
  static const Duration _aiTypingTick = Duration(milliseconds: 24);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  Timer? _aiTypingTimer;

  // Current chat state
  List<ChatMessage> _messages = [];
  String _currentTopic = 'New Chat';
  bool _isLoading = false;
  bool _isStreamingResponse = false;
  String _streamingText = '';
  String _streamingTargetText = '';
  DateTime? _streamingTimestamp;
  int _activeRequestToken = 0;
  int _streamTickCount = 0;

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
    _activeRequestToken++;
    _aiTypingTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// Starts a new chat session
  /// Saves current chat to history if it has messages
  void _startNewChat() {
    setState(() {
      _activeRequestToken++;
      _cancelActiveAiPresentation(notify: false);

      // Save current chat to history if it has messages
      if (_messages.isNotEmpty) {
        _saveCurrentChatToHistory(notify: false);
      }

      // Reset to new chat
      _messages = [];
      _currentTopic = 'New Chat';
      _activeHistoryId = null;
    });
  }

  /// Saves current chat session to history
  void _saveCurrentChatToHistory({bool notify = true}) {
    if (_messages.isEmpty) return;

    final historyItem = ChatHistory(
      id: _activeHistoryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      topic: _currentTopic,
      date: DateTime.now(),
      messages: List.from(_messages),
    );

    if (!notify) {
      _upsertHistoryItem(historyItem);
      return;
    }

    setState(() {
      _upsertHistoryItem(historyItem);
    });
  }

  void _upsertHistoryItem(ChatHistory historyItem) {
    // Remove existing if updating
    _chatHistories.removeWhere((h) => h.id == historyItem.id);
    // Add to beginning (newest first)
    _chatHistories.insert(0, historyItem);
  }

  /// Loads a chat from history
  void _loadChatFromHistory(ChatHistory history) {
    setState(() {
      _activeRequestToken++;
      _cancelActiveAiPresentation(notify: false);

      // Save current chat before switching
      if (_messages.isNotEmpty) {
        _saveCurrentChatToHistory(notify: false);
      }

      // Load selected chat
      _messages = List.from(history.messages);
      _currentTopic = history.topic;
      _activeHistoryId = history.id;
    });

    // Close drawer
    Navigator.of(context).pop();

    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  bool _shouldGroupMessages(ChatMessage previous, ChatMessage next) {
    if (previous.isUser != next.isUser) {
      return false;
    }

    final gap = next.timestamp.difference(previous.timestamp).abs();
    return gap <= const Duration(minutes: 5);
  }

  /// Sends a user message and gets AI response
  Future<bool> _sendMessage(
    String text,
    List<ComposeAttachment> attachments,
  ) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty && attachments.isEmpty) {
      return false;
    }

    final userMessage = ChatMessage(
      text: trimmedText,
      isUser: true,
      attachments: attachments,
    );
    final requestToken = ++_activeRequestToken;

    setState(() {
      _cancelActiveAiPresentation(notify: false, commitPartial: true);
      _messages.add(userMessage);
      _isLoading = true;

      // Update topic from first message if still "New Chat"
      if (_currentTopic == 'New Chat') {
        if (trimmedText.length > 5) {
          _currentTopic = trimmedText.length > 50
              ? '${trimmedText.substring(0, 50)}...'
              : trimmedText;
        } else if (attachments.isNotEmpty) {
          _currentTopic = attachments.length == 1
              ? attachments.first.name
              : '${attachments.length} attachments';
        }
      }
    });

    // Scroll to bottom to show user message
    _scrollToBottom();

    try {
      // Attachments are represented as upload metadata for future storage sync.
      final attachmentUploadQueue = _buildAttachmentUploadQueue(attachments);
      if (attachmentUploadQueue.isNotEmpty) {
        // Placeholder for future Firebase Storage upload before AI request.
      }

      final aiUserPrompt = trimmedText.isNotEmpty
          ? trimmedText
          : 'Analyze the provided attachments and help me study.';
      final aiResponse = await _chatService.sendMessage(
        userMessage: aiUserPrompt,
        conversationHistory: _messages,
      );

      if (!mounted || requestToken != _activeRequestToken) {
        return false;
      }

      _startStreamingAiResponse(aiResponse, requestToken);
      return true;
    } catch (e) {
      if (requestToken != _activeRequestToken) {
        return false;
      }

      setState(() {
        _isLoading = false;
      });
      if (!mounted) {
        return false;
      }
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  List<Map<String, dynamic>> _buildAttachmentUploadQueue(
    List<ComposeAttachment> attachments,
  ) {
    return attachments
        .map((attachment) => attachment.toUploadMetadata())
        .toList(growable: false);
  }

  int _typingChunkSize(int totalLength) {
    if (totalLength <= 200) {
      return 1;
    }
    if (totalLength <= 800) {
      return 2;
    }
    return 3;
  }

  void _cancelActiveAiPresentation({
    bool notify = true,
    bool commitPartial = false,
  }) {
    _aiTypingTimer?.cancel();
    _aiTypingTimer = null;

    void resetState() {
      if (commitPartial &&
          _isStreamingResponse &&
          _streamingText.trim().isNotEmpty) {
        _messages.add(
          ChatMessage(
            text: _streamingText.trimRight(),
            isUser: false,
            timestamp: _streamingTimestamp ?? DateTime.now(),
          ),
        );
      }
      _isLoading = false;
      _isStreamingResponse = false;
      _streamingText = '';
      _streamingTargetText = '';
      _streamingTimestamp = null;
      _streamTickCount = 0;
    }

    if (notify) {
      setState(resetState);
    } else {
      resetState();
    }
  }

  void _startStreamingAiResponse(String fullResponse, int requestToken) {
    final targetText = fullResponse.trimRight();
    final safeTarget = targetText.isEmpty ? '...' : targetText;
    final chunkSize = _typingChunkSize(safeTarget.length);

    _aiTypingTimer?.cancel();

    setState(() {
      _isLoading = false;
      _isStreamingResponse = true;
      _streamingText = '';
      _streamingTargetText = safeTarget;
      _streamingTimestamp = DateTime.now();
      _streamTickCount = 0;
    });
    _scrollToBottom();

    _aiTypingTimer = Timer.periodic(_aiTypingTick, (timer) {
      if (!mounted || requestToken != _activeRequestToken) {
        timer.cancel();
        return;
      }

      final nextLength = (_streamingText.length + chunkSize).clamp(
        0,
        _streamingTargetText.length,
      );

      setState(() {
        _streamingText = _streamingTargetText.substring(0, nextLength);
        _streamTickCount++;
      });

      if (_streamTickCount.isEven) {
        _scrollToBottom(duration: const Duration(milliseconds: 90));
      }

      if (nextLength >= _streamingTargetText.length) {
        timer.cancel();
        _finishStreamingAiResponse(requestToken);
      }
    });
  }

  void _finishStreamingAiResponse(int requestToken) {
    if (!mounted ||
        requestToken != _activeRequestToken ||
        !_isStreamingResponse) {
      return;
    }

    final completedMessage = ChatMessage(
      text: _streamingText.trimRight(),
      isUser: false,
      timestamp: _streamingTimestamp ?? DateTime.now(),
    );

    setState(() {
      _messages.add(completedMessage);
      _isStreamingResponse = false;
      _streamingText = '';
      _streamingTargetText = '';
      _streamingTimestamp = null;
      _streamTickCount = 0;
    });

    _scrollToBottom();
  }

  /// Scrolls chat to bottom smoothly
  void _scrollToBottom({
    Duration duration = const Duration(milliseconds: 220),
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: duration,
          curve: Curves.easeOut,
        );
      }
    });
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
    final hasEmbeddedBack = widget.onBackPressed != null;

    return PopScope(
      canPop: !hasEmbeddedBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !hasEmbeddedBack) {
          return;
        }
        widget.onBackPressed?.call();
      },
      child: Scaffold(
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
          forceMaterialTransparency: true,
          leading: AppIconButton(
            icon: hasEmbeddedBack ? Icons.arrow_back : Icons.menu,
            onPressed: hasEmbeddedBack
                ? widget.onBackPressed!
                : () => _scaffoldKey.currentState?.openDrawer(),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AppColorsDark.border
                        : AppColorsLight.border,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: isDark
                      ? AppColorsDark.lightBackground
                      : AppColorsLight.lightBackground,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: isDark
                      ? AppColorsDark.primaryText
                      : AppColorsLight.primaryText,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Study Chat',
                      style: AppTextStyles.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentTopic == 'New Chat'
                          ? 'Ready to help you study'
                          : _currentTopic,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColorsDark.secondaryText
                            : AppColorsLight.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (hasEmbeddedBack)
              AppIconButton(
                icon: Icons.menu,
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            AppIconButton(
              icon: Icons.add_comment_outlined,
              onPressed: _startNewChat,
            ),
            AppIconButton(
              icon: Icons.ios_share_outlined,
              onPressed: _shareChat,
            ),
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 960
                ? AppSpacing.xxl
                : AppSpacing.lg;
            final maxBubbleWidth = constraints.maxWidth >= 960
                ? constraints.maxWidth * 0.56
                : constraints.maxWidth * 0.8;

            return Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _messages.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            key: ValueKey<int>(
                              _messages.length +
                                  ((_isLoading || _isStreamingResponse)
                                      ? 1
                                      : 0),
                            ),
                            controller: _scrollController,
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              AppSpacing.lg,
                              horizontalPadding,
                              AppSpacing.lg,
                            ),
                            itemCount:
                                _messages.length +
                                ((_isLoading || _isStreamingResponse) ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _messages.length &&
                                  (_isLoading || _isStreamingResponse)) {
                                final previous = _messages.isNotEmpty
                                    ? _messages.last
                                    : null;
                                final placeholderTimestamp =
                                    _streamingTimestamp ?? DateTime.now();
                                final isGroupedWithPrevious =
                                    previous != null &&
                                    _shouldGroupMessages(
                                      previous,
                                      ChatMessage(
                                        text: _streamingText,
                                        isUser: false,
                                        timestamp: placeholderTimestamp,
                                      ),
                                    );

                                return ChatMessageBubble(
                                  message: _streamingText,
                                  isUser: false,
                                  timestamp: placeholderTimestamp,
                                  isTypingIndicator:
                                      _isLoading && !_isStreamingResponse,
                                  showStreamingCursor: _isStreamingResponse,
                                  isGroupedWithPrevious: isGroupedWithPrevious,
                                  isGroupedWithNext: false,
                                  showTimestamp: false,
                                  maxBubbleWidth: maxBubbleWidth,
                                );
                              }

                              final message = _messages[index];
                              final previous = index > 0
                                  ? _messages[index - 1]
                                  : null;
                              final next = index < _messages.length - 1
                                  ? _messages[index + 1]
                                  : null;
                              final isGroupedWithPrevious =
                                  previous != null &&
                                  _shouldGroupMessages(previous, message);
                              final isGroupedWithNext =
                                  next != null &&
                                  _shouldGroupMessages(message, next);

                              return ChatMessageBubble(
                                message: message.text,
                                isUser: message.isUser,
                                timestamp: message.timestamp,
                                attachments: message.attachments,
                                isGroupedWithPrevious: isGroupedWithPrevious,
                                isGroupedWithNext: isGroupedWithNext,
                                showTimestamp: !isGroupedWithNext,
                                maxBubbleWidth: maxBubbleWidth,
                              );
                            },
                          ),
                  ),
                ),
                ChatInputBar(
                  onSendMessage: _sendMessage,
                  controller: widget.inputController,
                  autoFocusOnInit: widget.autoFocusInput,
                ),
              ],
            );
          },
        ),
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
