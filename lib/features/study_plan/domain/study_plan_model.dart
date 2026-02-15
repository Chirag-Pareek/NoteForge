import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a task type within a study plan.
enum StudyTaskType { notes, practice, revision }

/// A single scheduled study task within a daily plan.
class StudyTask {
  final String subjectId;
  final String chapterId;
  final String subjectName;
  final String chapterName;
  final StudyTaskType type;
  final int durationMinutes;
  final bool isCompleted;

  const StudyTask({
    required this.subjectId,
    required this.chapterId,
    required this.subjectName,
    required this.chapterName,
    required this.type,
    required this.durationMinutes,
    required this.isCompleted,
  });

  StudyTask copyWith({bool? isCompleted}) {
    return StudyTask(
      subjectId: subjectId,
      chapterId: chapterId,
      subjectName: subjectName,
      chapterName: chapterName,
      type: type,
      durationMinutes: durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'chapterId': chapterId,
      'subjectName': subjectName,
      'chapterName': chapterName,
      'type': type.name,
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
    };
  }

  factory StudyTask.fromMap(Map<String, dynamic> data) {
    return StudyTask(
      subjectId: (data['subjectId'] as String?) ?? '',
      chapterId: (data['chapterId'] as String?) ?? '',
      subjectName: (data['subjectName'] as String?) ?? '',
      chapterName: (data['chapterName'] as String?) ?? '',
      type: _parseType(data['type']),
      durationMinutes: _toInt(data['durationMinutes']),
      isCompleted: (data['isCompleted'] as bool?) ?? false,
    );
  }

  static StudyTaskType _parseType(dynamic value) {
    if (value is String) {
      switch (value) {
        case 'notes':
          return StudyTaskType.notes;
        case 'practice':
          return StudyTaskType.practice;
        case 'revision':
          return StudyTaskType.revision;
      }
    }
    return StudyTaskType.notes;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 30;
  }
}

/// Model for a daily study plan.
/// Firestore path: `users/{uid}/studyPlans/{id}`
class StudyPlanModel {
  final String id;
  final String userId;
  final DateTime date;
  final List<StudyTask> tasks;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime adjustedAt;

  const StudyPlanModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.tasks,
    required this.isCompleted,
    required this.createdAt,
    required this.adjustedAt,
  });

  /// Ratio of completed tasks.
  double get completionRatio {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.isCompleted).length;
    return completed / tasks.length;
  }

  int get totalMinutes =>
      tasks.fold<int>(0, (total, t) => total + t.durationMinutes);

  int get completedMinutes => tasks
      .where((t) => t.isCompleted)
      .fold<int>(0, (total, t) => total + t.durationMinutes);

  StudyPlanModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<StudyTask>? tasks,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? adjustedAt,
  }) {
    return StudyPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      adjustedAt: adjustedAt ?? this.adjustedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'adjustedAt': FieldValue.serverTimestamp(),
    };
  }

  factory StudyPlanModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawTasks = (data['tasks'] as List<dynamic>?) ?? const <dynamic>[];
    final tasks = rawTasks
        .whereType<Map<String, dynamic>>()
        .map((m) => StudyTask.fromMap(m))
        .toList();
    return StudyPlanModel(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      date: _toDateTime(data['date']),
      tasks: tasks,
      isCompleted: (data['isCompleted'] as bool?) ?? false,
      createdAt: _toDateTime(data['createdAt']),
      adjustedAt: _toDateTime(data['adjustedAt']),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}
