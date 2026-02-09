import 'package:cloud_firestore/cloud_firestore.dart';

/// Daily progress model stored at: `progress/{uid}/daily/{dateKey}`
///
/// Expected dateKey format: `yyyy-MM-dd`.
class ProgressModel {
  final String uid;
  final String dateKey;
  final DateTime date;
  final int studyMinutes;
  final int tasksCompleted;
  final Map<String, int> subjects;

  const ProgressModel({
    required this.uid,
    required this.dateKey,
    required this.date,
    required this.studyMinutes,
    required this.tasksCompleted,
    required this.subjects,
  });

  int get totalSubjectMinutes =>
      subjects.values.fold<int>(0, (total, value) => total + value);

  bool get isActiveDay => studyMinutes > 0 || tasksCompleted > 0;

  ProgressModel copyWith({
    String? uid,
    String? dateKey,
    DateTime? date,
    int? studyMinutes,
    int? tasksCompleted,
    Map<String, int>? subjects,
  }) {
    return ProgressModel(
      uid: uid ?? this.uid,
      dateKey: dateKey ?? this.dateKey,
      date: date ?? this.date,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      subjects: subjects ?? this.subjects,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studyMinutes': studyMinutes,
      'tasksCompleted': tasksCompleted,
      'subjects': subjects,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ProgressModel.fromDocument(
    String uid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final rawSubjects =
        (data['subjects'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final subjects = <String, int>{};
    for (final entry in rawSubjects.entries) {
      final value = entry.value;
      if (value is int) {
        subjects[entry.key] = value;
      } else if (value is num) {
        subjects[entry.key] = value.toInt();
      }
    }

    return ProgressModel(
      uid: uid,
      dateKey: doc.id,
      date: dateFromKey(doc.id),
      studyMinutes: _toInt(data['studyMinutes']),
      tasksCompleted: _toInt(data['tasksCompleted']),
      subjects: subjects,
    );
  }

  factory ProgressModel.empty({required String uid, required DateTime date}) {
    final normalized = normalizeDate(date);
    return ProgressModel(
      uid: uid,
      dateKey: dateKeyFromDate(normalized),
      date: normalized,
      studyMinutes: 0,
      tasksCompleted: 0,
      subjects: const <String, int>{},
    );
  }

  /// Normalizes a DateTime to local midnight.
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String dateKeyFromDate(DateTime date) {
    final normalized = normalizeDate(date);
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime dateFromKey(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) {
      return DateTime.now();
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null || month == null || day == null) {
      return DateTime.now();
    }

    return DateTime(year, month, day);
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }
}

/// Aggregated analytics for a fixed date range.
class ProgressPeriodData {
  final DateTime startDate;
  final DateTime endDate;
  final List<ProgressModel> entries;
  final int totalStudyMinutes;
  final int totalTasksCompleted;
  final Map<String, int> subjectTotals;

  const ProgressPeriodData({
    required this.startDate,
    required this.endDate,
    required this.entries,
    required this.totalStudyMinutes,
    required this.totalTasksCompleted,
    required this.subjectTotals,
  });

  double get averageStudyMinutes {
    if (entries.isEmpty) {
      return 0;
    }
    return totalStudyMinutes / entries.length;
  }

  double get activeDayRatio {
    if (entries.isEmpty) {
      return 0;
    }
    final activeDays = entries.where((entry) => entry.isActiveDay).length;
    return activeDays / entries.length;
  }
}

/// Value object used for heatmap rendering.
class HeatmapValue {
  final DateTime date;
  final int minutes;

  const HeatmapValue({required this.date, required this.minutes});
}
