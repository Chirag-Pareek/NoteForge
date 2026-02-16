import 'compose_attachment.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<ComposeAttachment> attachments;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    List<ComposeAttachment> attachments = const <ComposeAttachment>[],
  }) : timestamp = timestamp ?? DateTime.now(),
       attachments = List<ComposeAttachment>.unmodifiable(attachments);
}
