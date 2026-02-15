import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a note within a topic.
/// Firestore path: `users/{uid}/notes/{id}`
class NoteModel {
  final String id;
  final String topicId;
  final String chapterId;
  final String subjectId;
  final String title;
  final String content;
  final bool isDraft;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.topicId,
    required this.chapterId,
    required this.subjectId,
    required this.title,
    required this.content,
    required this.isDraft,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteModel copyWith({
    String? id,
    String? topicId,
    String? chapterId,
    String? subjectId,
    String? title,
    String? content,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      chapterId: chapterId ?? this.chapterId,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      content: content ?? this.content,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'topicId': topicId,
      'chapterId': chapterId,
      'subjectId': subjectId,
      'title': title,
      'content': content,
      'isDraft': isDraft,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory NoteModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return NoteModel(
      id: doc.id,
      topicId: (data['topicId'] as String?) ?? '',
      chapterId: (data['chapterId'] as String?) ?? '',
      subjectId: (data['subjectId'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      content: (data['content'] as String?) ?? '',
      isDraft: (data['isDraft'] as bool?) ?? true,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  /// Creates an empty draft note for a given topic hierarchy.
  factory NoteModel.emptyDraft({
    required String topicId,
    required String chapterId,
    required String subjectId,
  }) {
    final now = DateTime.now();
    return NoteModel(
      id: '',
      topicId: topicId,
      chapterId: chapterId,
      subjectId: subjectId,
      title: '',
      content: '',
      isDraft: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}
