import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/progress_model.dart';
import '../utils/performance_score_utils.dart';

/// Repository for study progress, streaks, and analytics data.
class ProgressRepository {
  ProgressRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _dailyRef(String uid) {
    return _firestore.collection('progress').doc(uid).collection('daily');
  }

  /// Saves or updates daily progress for a user.
  Future<void> saveDailyProgress({
    required String uid,
    required DateTime date,
    required int studyMinutes,
    required int tasksCompleted,
    required Map<String, int> subjects,
    bool merge = true,
    bool recalculateUserStats = true,
  }) async {
    final normalizedDate = ProgressModel.normalizeDate(date);
    final dateKey = ProgressModel.dateKeyFromDate(normalizedDate);

    final sanitizedSubjects = _sanitizeSubjects(subjects);

    try {
      await _dailyRef(uid).doc(dateKey).set({
        'studyMinutes': studyMinutes < 0 ? 0 : studyMinutes,
        'tasksCompleted': tasksCompleted < 0 ? 0 : tasksCompleted,
        'subjects': sanitizedSubjects,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: merge));

      if (recalculateUserStats) {
        await recalculateAndPersistUserMetrics(uid);
      }
    } on FirebaseException catch (e) {
      throw Exception('Failed to save daily progress: ${e.message ?? e.code}');
    }
  }

  /// Returns weekly analytics ending on [endingOn] (default: today).
  Future<ProgressPeriodData> getWeeklyData(
    String uid, {
    DateTime? endingOn,
  }) async {
    final endDate = ProgressModel.normalizeDate(endingOn ?? DateTime.now());
    final startDate = endDate.subtract(const Duration(days: 6));

    return _buildPeriodData(uid, startDate: startDate, endDate: endDate);
  }

  /// Returns analytics for the month containing [monthAnchor] (default: current month).
  Future<ProgressPeriodData> getMonthlyData(
    String uid, {
    DateTime? monthAnchor,
  }) async {
    final anchor = ProgressModel.normalizeDate(monthAnchor ?? DateTime.now());
    final startDate = DateTime(anchor.year, anchor.month, 1);
    final endDate = DateTime(anchor.year, anchor.month + 1, 0);

    return _buildPeriodData(uid, startDate: startDate, endDate: endDate);
  }

  /// Returns heatmap values (default = last 84 days).
  Future<List<HeatmapValue>> getHeatmapValues(
    String uid, {
    int days = 84,
    DateTime? endingOn,
  }) async {
    final endDate = ProgressModel.normalizeDate(endingOn ?? DateTime.now());
    final startDate = endDate.subtract(Duration(days: days - 1));

    final entries = await _fetchRange(
      uid,
      startDate: startDate,
      endDate: endDate,
      fillMissingDays: true,
    );

    return entries
        .map(
          (entry) =>
              HeatmapValue(date: entry.date, minutes: entry.studyMinutes),
        )
        .toList(growable: false);
  }

  /// Calculates current streak of consecutive active days.
  Future<int> calculateCurrentStreak(String uid, {DateTime? today}) async {
    final normalizedToday = ProgressModel.normalizeDate(
      today ?? DateTime.now(),
    );
    final lookbackStart = normalizedToday.subtract(const Duration(days: 365));

    final entries = await _fetchRange(
      uid,
      startDate: lookbackStart,
      endDate: normalizedToday,
      fillMissingDays: false,
    );

    final activeDateKeys = entries
        .where((entry) => entry.isActiveDay)
        .map((entry) => entry.dateKey)
        .toSet();

    if (activeDateKeys.isEmpty) {
      return 0;
    }

    var cursor = normalizedToday;
    if (!activeDateKeys.contains(ProgressModel.dateKeyFromDate(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (activeDateKeys.contains(ProgressModel.dateKeyFromDate(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calculates performance score from recent data window.
  Future<double> calculatePerformanceScore(
    String uid, {
    int lookbackDays = 30,
    DateTime? endingOn,
  }) async {
    final endDate = ProgressModel.normalizeDate(endingOn ?? DateTime.now());
    final startDate = endDate.subtract(Duration(days: lookbackDays - 1));

    final entries = await _fetchRange(
      uid,
      startDate: startDate,
      endDate: endDate,
      fillMissingDays: true,
    );

    final streak = await calculateCurrentStreak(uid, today: endDate);

    return PerformanceScoreUtils.calculatePerformanceScore(
      entries: entries,
      currentStreak: streak,
    );
  }

  /// Recalculates and persists streak + performance score into `users/{uid}`.
  Future<void> recalculateAndPersistUserMetrics(
    String uid, {
    int performanceLookbackDays = 30,
  }) async {
    try {
      final streak = await calculateCurrentStreak(uid);
      final score = await calculatePerformanceScore(
        uid,
        lookbackDays: performanceLookbackDays,
      );

      await _usersRef.doc(uid).set({
        'streak': streak,
        'performanceScore': score,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception(
        'Failed to update user performance metrics: ${e.message ?? e.code}',
      );
    }
  }

  /// Realtime stream for one day's progress document.
  Stream<ProgressModel?> streamDailyProgress(
    String uid, {
    required DateTime date,
  }) {
    final normalizedDate = ProgressModel.normalizeDate(date);
    final dateKey = ProgressModel.dateKeyFromDate(normalizedDate);

    return _dailyRef(uid).doc(dateKey).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return ProgressModel.fromDocument(uid, doc);
    });
  }

  /// Realtime stream of weekly entries.
  Stream<List<ProgressModel>> streamWeeklyData(
    String uid, {
    DateTime? endingOn,
  }) {
    final endDate = ProgressModel.normalizeDate(endingOn ?? DateTime.now());
    final startDate = endDate.subtract(const Duration(days: 6));

    return streamRangeData(
      uid,
      startDate: startDate,
      endDate: endDate,
      fillMissingDays: true,
    );
  }

  /// Realtime stream of monthly entries.
  Stream<List<ProgressModel>> streamMonthlyData(
    String uid, {
    DateTime? monthAnchor,
  }) {
    final anchor = ProgressModel.normalizeDate(monthAnchor ?? DateTime.now());
    final startDate = DateTime(anchor.year, anchor.month, 1);
    final endDate = DateTime(anchor.year, anchor.month + 1, 0);

    return streamRangeData(
      uid,
      startDate: startDate,
      endDate: endDate,
      fillMissingDays: true,
    );
  }

  /// Generic realtime progress stream for any date range.
  Stream<List<ProgressModel>> streamRangeData(
    String uid, {
    required DateTime startDate,
    required DateTime endDate,
    bool fillMissingDays = false,
  }) {
    final normalizedStart = ProgressModel.normalizeDate(startDate);
    final normalizedEnd = ProgressModel.normalizeDate(endDate);

    final startKey = ProgressModel.dateKeyFromDate(normalizedStart);
    final endKey = ProgressModel.dateKeyFromDate(normalizedEnd);

    final query = _dailyRef(uid)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
        .where(FieldPath.documentId, isLessThanOrEqualTo: endKey)
        .orderBy(FieldPath.documentId);

    return query.snapshots().map((snapshot) {
      final entries = snapshot.docs
          .map((doc) => ProgressModel.fromDocument(uid, doc))
          .toList(growable: false);

      if (!fillMissingDays) {
        return entries;
      }

      return _fillMissingDates(
        uid: uid,
        entries: entries,
        startDate: normalizedStart,
        endDate: normalizedEnd,
      );
    });
  }

  Future<ProgressPeriodData> _buildPeriodData(
    String uid, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final entries = await _fetchRange(
      uid,
      startDate: startDate,
      endDate: endDate,
      fillMissingDays: true,
    );

    final totalStudyMinutes = entries.fold<int>(
      0,
      (total, entry) => total + entry.studyMinutes,
    );

    final totalTasksCompleted = entries.fold<int>(
      0,
      (total, entry) => total + entry.tasksCompleted,
    );

    final subjectTotals = PerformanceScoreUtils.aggregateSubjectMinutes(
      entries,
    );

    return ProgressPeriodData(
      startDate: ProgressModel.normalizeDate(startDate),
      endDate: ProgressModel.normalizeDate(endDate),
      entries: entries,
      totalStudyMinutes: totalStudyMinutes,
      totalTasksCompleted: totalTasksCompleted,
      subjectTotals: subjectTotals,
    );
  }

  Future<List<ProgressModel>> _fetchRange(
    String uid, {
    required DateTime startDate,
    required DateTime endDate,
    required bool fillMissingDays,
  }) async {
    final normalizedStart = ProgressModel.normalizeDate(startDate);
    final normalizedEnd = ProgressModel.normalizeDate(endDate);

    final startKey = ProgressModel.dateKeyFromDate(normalizedStart);
    final endKey = ProgressModel.dateKeyFromDate(normalizedEnd);

    try {
      final snapshot = await _dailyRef(uid)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endKey)
          .orderBy(FieldPath.documentId)
          .get();

      final entries = snapshot.docs
          .map((doc) => ProgressModel.fromDocument(uid, doc))
          .toList(growable: false);

      if (!fillMissingDays) {
        return entries;
      }

      return _fillMissingDates(
        uid: uid,
        entries: entries,
        startDate: normalizedStart,
        endDate: normalizedEnd,
      );
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch progress data: ${e.message ?? e.code}');
    }
  }

  List<ProgressModel> _fillMissingDates({
    required String uid,
    required List<ProgressModel> entries,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final byDateKey = <String, ProgressModel>{
      for (final entry in entries) entry.dateKey: entry,
    };

    final filled = <ProgressModel>[];
    var cursor = startDate;

    while (!cursor.isAfter(endDate)) {
      final dateKey = ProgressModel.dateKeyFromDate(cursor);
      final existing = byDateKey[dateKey];
      filled.add(existing ?? ProgressModel.empty(uid: uid, date: cursor));
      cursor = cursor.add(const Duration(days: 1));
    }

    return filled;
  }

  Map<String, int> _sanitizeSubjects(Map<String, int> subjects) {
    final result = <String, int>{};

    for (final entry in subjects.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) {
        continue;
      }

      final value = entry.value;
      result[key] = value < 0 ? 0 : value;
    }

    return result;
  }
}
