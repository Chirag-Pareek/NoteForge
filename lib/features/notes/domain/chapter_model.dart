import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a chapter within a subject.
/// Firestore path: `users/{uid}/chapters/{id}`
class ChapterModel {
  final String id;
  final String subjectId;
  final String name;
  final int topicsCount;
  final int completedTopics;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChapterModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.topicsCount,
    required this.completedTopics,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Progress as a ratio from 0.0 to 1.0.
  double get progress =>
      topicsCount > 0 ? completedTopics / topicsCount : 0.0;

  ChapterModel copyWith({
    String? id,
    String? subjectId,
    String? name,
    int? topicsCount,
    int? completedTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      topicsCount: topicsCount ?? this.topicsCount,
      completedTopics: completedTopics ?? this.completedTopics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'name': name,
      'topicsCount': topicsCount,
      'completedTopics': completedTopics,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ChapterModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ChapterModel(
      id: doc.id,
      subjectId: (data['subjectId'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      topicsCount: _toInt(data['topicsCount']),
      completedTopics: _toInt(data['completedTopics']),
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
