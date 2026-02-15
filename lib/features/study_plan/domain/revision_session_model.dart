import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a spaced repetition revision session.
/// Uses SM-2 algorithm fields.
/// Firestore path: `users/{uid}/revisionSessions/{id}`
class RevisionSessionModel {
  final String id;
  final String userId;
  final String topicId;
  final String chapterId;
  final String subjectId;
  final String topicName;
  final DateTime nextReviewDate;
  final int interval; // days until next review
  final double easeFactor; // SM-2 ease factor (default 2.5)
  final int repetition; // number of successful reviews
  final DateTime lastReviewedAt;

  const RevisionSessionModel({
    required this.id,
    required this.userId,
    required this.topicId,
    required this.chapterId,
    required this.subjectId,
    required this.topicName,
    required this.nextReviewDate,
    required this.interval,
    required this.easeFactor,
    required this.repetition,
    required this.lastReviewedAt,
  });

  /// Whether this topic is due for review.
  bool get isDue => DateTime.now().isAfter(nextReviewDate) ||
      DateTime.now().isAtSameMomentAs(nextReviewDate);

  /// SM-2 algorithm: update after a review with quality rating (0-5).
  /// 0-2 = incorrect/hard, 3 = correct but hard, 4 = correct, 5 = easy
  RevisionSessionModel reviewWith(int quality) {
    double newEF = easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (newEF < 1.3) newEF = 1.3;

    int newInterval;
    int newRepetition;

    if (quality < 3) {
      // Reset on failure
      newRepetition = 0;
      newInterval = 1;
    } else {
      newRepetition = repetition + 1;
      if (newRepetition == 1) {
        newInterval = 1;
      } else if (newRepetition == 2) {
        newInterval = 6;
      } else {
        newInterval = (interval * newEF).round();
      }
    }

    final now = DateTime.now();
    return copyWith(
      interval: newInterval,
      easeFactor: newEF,
      repetition: newRepetition,
      lastReviewedAt: now,
      nextReviewDate: DateTime(now.year, now.month, now.day + newInterval),
    );
  }

  RevisionSessionModel copyWith({
    String? id,
    String? userId,
    String? topicId,
    String? chapterId,
    String? subjectId,
    String? topicName,
    DateTime? nextReviewDate,
    int? interval,
    double? easeFactor,
    int? repetition,
    DateTime? lastReviewedAt,
  }) {
    return RevisionSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topicId: topicId ?? this.topicId,
      chapterId: chapterId ?? this.chapterId,
      subjectId: subjectId ?? this.subjectId,
      topicName: topicName ?? this.topicName,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      repetition: repetition ?? this.repetition,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'topicId': topicId,
      'chapterId': chapterId,
      'subjectId': subjectId,
      'topicName': topicName,
      'nextReviewDate': Timestamp.fromDate(nextReviewDate),
      'interval': interval,
      'easeFactor': easeFactor,
      'repetition': repetition,
      'lastReviewedAt': Timestamp.fromDate(lastReviewedAt),
    };
  }

  factory RevisionSessionModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return RevisionSessionModel(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      topicId: (data['topicId'] as String?) ?? '',
      chapterId: (data['chapterId'] as String?) ?? '',
      subjectId: (data['subjectId'] as String?) ?? '',
      topicName: (data['topicName'] as String?) ?? '',
      nextReviewDate: _toDateTime(data['nextReviewDate']),
      interval: _toInt(data['interval']),
      easeFactor: _toDouble(data['easeFactor'], 2.5),
      repetition: _toInt(data['repetition']),
      lastReviewedAt: _toDateTime(data['lastReviewedAt']),
    );
  }

  /// Creates a new revision session for a topic (first time).
  factory RevisionSessionModel.create({
    required String userId,
    required String topicId,
    required String chapterId,
    required String subjectId,
    required String topicName,
  }) {
    final now = DateTime.now();
    return RevisionSessionModel(
      id: '',
      userId: userId,
      topicId: topicId,
      chapterId: chapterId,
      subjectId: subjectId,
      topicName: topicName,
      nextReviewDate: now,
      interval: 0,
      easeFactor: 2.5,
      repetition: 0,
      lastReviewedAt: now,
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

  static double _toDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return defaultValue;
  }
}
