import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon_button.dart';
import 'widgets/chat_history_drawer.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_message_bubble.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
  });
}

class ChatThread {
  final String id;
  final DateTime date;
  String title;
  final List<ChatMessage> messages;

  ChatThread({
    required this.id,
    required this.date,
    required this.title,
    required this.messages,
  });
}

class ChatWithAIScreen extends StatefulWidget {
  const ChatWithAIScreen({super.key});

  @override
  State<ChatWithAIScreen> createState() => _ChatWithAIScreenState();
}

class _ChatWithAIScreenState extends State<ChatWithAIScreen> {
  // Chat flow: active thread and message list.
  final List<ChatThread> _threads = [];
  ChatThread? _activeThread;
  final ScrollController _scrollController = ScrollController();
  final _OpenAIChatService _openAi = _OpenAIChatService();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _createNewChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _createNewChat() {
    final thread = ChatThread(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      title: 'New Chat',
      messages: [],
    );
    setState(() {
      _threads.insert(0, thread);
      _activeThread = thread;
    });
  }

  // History handling: loading a chat sets it as active.
  void _loadChat(ChatHistoryItem item) {
    final match = _threads.where((t) => t.id == item.id).toList();
    if (match.isEmpty) {
      return;
    }
    setState(() => _activeThread = match.first);
  }

  void _onSendMessage(String text) {
    final thread = _activeThread;
    if (thread == null) {
      return;
    }

    final userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
    );

    setState(() {
      thread.messages.add(userMessage);
    });

    // Topic update logic: first user message becomes the chat title.
    if (thread.title == 'New Chat') {
      thread.title = text;
    }

    _scrollToBottom();

    if (!_openAi.isEducationQuery(text)) {
      _addAssistantMessage(
        'I am built for study help only. Please ask an education-related question.',
      );
      return;
    }

    _fetchAiResponse(thread.messages);
  }

  Future<void> _fetchAiResponse(List<ChatMessage> messages) async {
    // API usage: send chat to OpenAI and append the assistant reply.
    final reply = await _openAi.createChatCompletion(messages);
    _addAssistantMessage(reply);
  }

  void _addAssistantMessage(String text) {
    final thread = _activeThread;
    if (thread == null) {
      return;
    }

    final assistantMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
    );

    setState(() {
      thread.messages.add(assistantMessage);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    final activeMessages = _activeThread?.messages ?? const <ChatMessage>[];

    return Scaffold(
      drawer: ChatHistoryDrawer(
        items: _threads
            .map(
              (t) => ChatHistoryItem(
                id: t.id,
                title: t.title,
                date: t.date,
              ),
            )
            .toList(),
        selectedId: _activeThread?.id,
        searchQuery: _searchQuery,
        onSearchChanged: (value) => setState(() => _searchQuery = value),
        onSelect: _loadChat,
      ),
      appBar: AppBar(
        elevation: 0,
        leading: Builder(
          builder: (context) => AppIconButton(
            icon: Icons.history,
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'History',
          ),
        ),
        title: Text('Chats', style: AppTextStyles.titleMedium),
        centerTitle: true,
        actions: [
          AppIconButton(
            icon: Icons.add_comment_outlined,
            onPressed: _createNewChat,
            tooltip: 'New Chat',
          ),
          AppIconButton(
            icon: Icons.share_outlined,
            onPressed: () {},
            tooltip: 'Share Chat',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(AppSpacing.xs),
          child: Container(
            height: AppSpacing.xs,
            color: borderColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: activeMessages.length,
                itemBuilder: (context, index) {
                  final message = activeMessages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ChatMessageBubble(
                      text: message.text,
                      isUser: message.isUser,
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ChatInputBar(
                onSend: _onSendMessage,
                onAttach: () {},
                onMic: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenAIChatService {
  // API configuration for OpenAI Chat Completions.
  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  bool isEducationQuery(String text) {
    final lower = text.toLowerCase();
    const keywords = [
      'study',
      'explain',
      'summary',
      'summarize',
      'learn',
      'homework',
      'math',
      'science',
      'physics',
      'chemistry',
      'biology',
      'history',
      'geography',
      'grammar',
      'algebra',
      'calculus',
      'formula',
      'theorem',
      'problem',
      'question',
      'notes',
    ];
    return keywords.any(lower.contains);
  }

  Future<String> createChatCompletion(List<ChatMessage> messages) async {
    final apiKey = const String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isEmpty) {
      return 'OpenAI API key is missing. Set OPENAI_API_KEY to enable chat.';
    }

    final payload = {
      'model': _model,
      'messages': [
        {
          'role': 'developer',
          'content':
              'You are an education-focused AI tutor. Only answer study-related questions.',
        },
        ...messages.map(
          (m) => {
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.text,
          },
        ),
      ],
    };

    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(_endpoint));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');
      request.add(utf8.encode(jsonEncode(payload)));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;
          return content ?? 'No response returned.';
        }
        return 'No response returned.';
      }

      return 'Request failed. Please try again.';
    } catch (_) {
      return 'Network error. Please try again.';
    } finally {
      client.close();
    }
  }
}
