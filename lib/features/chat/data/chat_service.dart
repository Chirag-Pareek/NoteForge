// lib/features/chat/data/chat_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:noteforge/features/chat/domain/chat_messages.dart';


/// ----------------------------------------------------
/// ChatService
/// ----------------------------------------------------
/// Handles all ChatGPT API communication for NoteForge
/// - Sends user messages
/// - Maintains conversation context
/// - Restricts AI to EDUCATION ONLY
/// - Handles errors & timeouts cleanly
///
/// NO UI logic here (clean architecture)
/// ----------------------------------------------------
class ChatService {
  /// OpenAI API key loaded securely from .env file
  static String get _apiKey => dotenv.env['OPENAI_KEY']!;

  /// OpenAI chat completion endpoint
  static const String _apiUrl =
      'https://api.openai.com/v1/chat/completions';

  /// ----------------------------------------------------
  /// System prompt (locks AI to education)
  /// ----------------------------------------------------
  static const String _systemPrompt = '''
You are an educational AI assistant called NoteForge.

RULES:
- ONLY answer questions related to education, studying, homework, exams, and academic subjects
- Politely decline non-educational topics
- Be clear, professional, and supportive
- Explain concepts step-by-step when needed
- Use examples to help understanding
''';

  /// ----------------------------------------------------
  /// Sends message to OpenAI and returns AI reply
  /// ----------------------------------------------------
  Future<String> sendMessage({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
  }) async {
    try {
      /// Base message list always starts with system rules
      final List<Map<String, String>> messages = [
        {'role': 'system', 'content': _systemPrompt},
      ];

      /// Keep last 8 messages only (prevents token overload)
      final recentHistory = conversationHistory.length > 8
          ? conversationHistory.sublist(
              conversationHistory.length - 8,
            )
          : conversationHistory;

      /// Add previous conversation for context
      for (final msg in recentHistory) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }

      /// Add current user message
      messages.add({
        'role': 'user',
        'content': userMessage,
      });

      /// Send API request
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'gpt-4o-mini', // Fast + high quality for education
              'messages': messages,
              'temperature': 0.6,
              'max_tokens': 600,
            }),
          )
          .timeout(const Duration(seconds: 25));

      /// Decode response
      final data = jsonDecode(response.body);

      /// Handle API-side errors
      if (data['error'] != null) {
        return data['error']['message'];
      }

      /// Extract AI message
      final aiMessage =
          data['choices'][0]['message']['content'] as String;

      return aiMessage.trim();
    }

    /// Connection timeout
    on TimeoutException {
      return 'Connection timeout. Please try again.';
    }

    /// Any other failure
    catch (e) {
      return 'Something went wrong. Please try again later.';
    }
  }
}
