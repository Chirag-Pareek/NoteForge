import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of practice questions.
enum QuestionType { mcq, fillBlank, shortAnswer }

/// Model for a practice question.
/// Firestore path: `users/{uid}/practiceQuestions/{id}`
class PracticeQuestionModel {
  final String id;
  final String chapterId;
  final String subjectId;
  final QuestionType type;
  final String question;
  final List<String> options; // Only for MCQ
  final String correctAnswer;
  final String explanation;
  final DateTime createdAt;

  const PracticeQuestionModel({
    required this.id,
    required this.chapterId,
    required this.subjectId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.createdAt,
  });

  PracticeQuestionModel copyWith({
    String? id,
    String? chapterId,
    String? subjectId,
    QuestionType? type,
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    DateTime? createdAt,
  }) {
    return PracticeQuestionModel(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      subjectId: subjectId ?? this.subjectId,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapterId': chapterId,
      'subjectId': subjectId,
      'type': type.name,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PracticeQuestionModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawOptions =
        (data['options'] as List<dynamic>?)?.whereType<String>().toList() ??
            const <String>[];
    return PracticeQuestionModel(
      id: doc.id,
      chapterId: (data['chapterId'] as String?) ?? '',
      subjectId: (data['subjectId'] as String?) ?? '',
      type: _parseType(data['type']),
      question: (data['question'] as String?) ?? '',
      options: rawOptions,
      correctAnswer: (data['correctAnswer'] as String?) ?? '',
      explanation: (data['explanation'] as String?) ?? '',
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  static QuestionType _parseType(dynamic value) {
    if (value is String) {
      switch (value) {
        case 'mcq':
          return QuestionType.mcq;
        case 'fillBlank':
          return QuestionType.fillBlank;
        case 'shortAnswer':
          return QuestionType.shortAnswer;
      }
    }
    return QuestionType.mcq;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}
