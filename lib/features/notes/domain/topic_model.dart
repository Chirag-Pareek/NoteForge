import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a topic within a chapter.
/// Firestore path: `users/{uid}/topics/{id}`
class TopicModel {
  final String id;
  final String chapterId;
  final String subjectId;
  final String name;
  final int notesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TopicModel({
    required this.id,
    required this.chapterId,
    required this.subjectId,
    required this.name,
    required this.notesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  TopicModel copyWith({
    String? id,
    String? chapterId,
    String? subjectId,
    String? name,
    int? notesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TopicModel(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      notesCount: notesCount ?? this.notesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapterId': chapterId,
      'subjectId': subjectId,
      'name': name,
      'notesCount': notesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory TopicModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return TopicModel(
      id: doc.id,
      chapterId: (data['chapterId'] as String?) ?? '',
      subjectId: (data['subjectId'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      notesCount: _toInt(data['notesCount']),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
