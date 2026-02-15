import 'package:cloud_firestore/cloud_firestore.dart';

/// Aggregated result of a practice session.
/// Firestore path: `users/{uid}/practiceSessions/{id}`
class PracticeSessionModel {
  final String id;
  final String userId;
  final String chapterId;
  final String subjectId;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final List<String> weakTopics;
  final DateTime completedAt;

  const PracticeSessionModel({
    required this.id,
    required this.userId,
    required this.chapterId,
    required this.subjectId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.weakTopics,
    required this.completedAt,
  });

  PracticeSessionModel copyWith({
    String? id,
    String? userId,
    String? chapterId,
    String? subjectId,
    int? totalQuestions,
    int? correctAnswers,
    double? accuracy,
    List<String>? weakTopics,
    DateTime? completedAt,
  }) {
    return PracticeSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      chapterId: chapterId ?? this.chapterId,
      subjectId: subjectId ?? this.subjectId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracy: accuracy ?? this.accuracy,
      weakTopics: weakTopics ?? this.weakTopics,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'chapterId': chapterId,
      'subjectId': subjectId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'weakTopics': weakTopics,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  factory PracticeSessionModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawWeakTopics =
        (data['weakTopics'] as List<dynamic>?)?.whereType<String>().toList() ??
            const <String>[];
    return PracticeSessionModel(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      chapterId: (data['chapterId'] as String?) ?? '',
      subjectId: (data['subjectId'] as String?) ?? '',
      totalQuestions: _toInt(data['totalQuestions']),
      correctAnswers: _toInt(data['correctAnswers']),
      accuracy: _toDouble(data['accuracy']),
      weakTopics: rawWeakTopics,
      completedAt: _toDateTime(data['completedAt']),
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

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}
