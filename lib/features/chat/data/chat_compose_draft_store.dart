import 'package:shared_preferences/shared_preferences.dart';

import '../domain/compose_attachment.dart';

class ChatComposeDraft {
  final String text;
  final List<ComposeAttachment> attachments;

  const ChatComposeDraft({required this.text, required this.attachments});

  static const empty = ChatComposeDraft(text: '', attachments: []);
}

class ChatComposeDraftStore {
  static const String _draftTextKey = 'chat_compose_draft_text_v1';
  static const String _draftAttachmentsKey =
      'chat_compose_draft_attachments_v1';

  Future<ChatComposeDraft> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_draftTextKey) ?? '';
    final attachmentsRaw = prefs.getString(_draftAttachmentsKey) ?? '';
    final attachments = ComposeAttachment.decodeList(attachmentsRaw);
    return ChatComposeDraft(text: text, attachments: attachments);
  }

  Future<void> saveDraft({
    required String text,
    required List<ComposeAttachment> attachments,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftTextKey, text);
    await prefs.setString(
      _draftAttachmentsKey,
      ComposeAttachment.encodeList(attachments),
    );
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftTextKey);
    await prefs.remove(_draftAttachmentsKey);
  }
}
