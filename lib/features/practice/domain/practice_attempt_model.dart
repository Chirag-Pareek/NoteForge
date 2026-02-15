import 'package:cloud_firestore/cloud_firestore.dart';

/// Single answer attempt for a practice question.
/// Firestore path: `users/{uid}/practiceAttempts/{id}`
class PracticeAttemptModel {
  final String id;
  final String userId;
  final String chapterId;
  final String questionId;
  final String questionType;
  final String selectedAnswer;
  final bool isCorrect;
  final DateTime attemptedAt;

  const PracticeAttemptModel({
    required this.id,
    required this.userId,
    required this.chapterId,
    required this.questionId,
    required this.questionType,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.attemptedAt,
  });

  PracticeAttemptModel copyWith({
    String? id,
    String? userId,
    String? chapterId,
    String? questionId,
    String? questionType,
    String? selectedAnswer,
    bool? isCorrect,
    DateTime? attemptedAt,
  }) {
    return PracticeAttemptModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      chapterId: chapterId ?? this.chapterId,
      questionId: questionId ?? this.questionId,
      questionType: questionType ?? this.questionType,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      attemptedAt: attemptedAt ?? this.attemptedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'chapterId': chapterId,
      'questionId': questionId,
      'questionType': questionType,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'attemptedAt': Timestamp.fromDate(attemptedAt),
    };
  }

  factory PracticeAttemptModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return PracticeAttemptModel(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      chapterId: (data['chapterId'] as String?) ?? '',
      questionId: (data['questionId'] as String?) ?? '',
      questionType: (data['questionType'] as String?) ?? '',
      selectedAnswer: (data['selectedAnswer'] as String?) ?? '',
      isCorrect: (data['isCorrect'] as bool?) ?? false,
      attemptedAt: _toDateTime(data['attemptedAt']),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}
