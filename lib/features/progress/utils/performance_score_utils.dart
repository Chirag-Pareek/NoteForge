import '../domain/progress_model.dart';

/// Utility functions for performance score and analytics calculations.
class PerformanceScoreUtils {
  PerformanceScoreUtils._();

  /// Calculates a 0-100 performance score from progress history.
  ///
  /// Weighting:
  /// - Consistency (active days): 40%
  /// - Study minutes target: 30%
  /// - Task completion target: 20%
  /// - Current streak bonus: 10%
  static double calculatePerformanceScore({
    required List<ProgressModel> entries,
    required int currentStreak,
    int targetDailyMinutes = 120,
    int targetDailyTasks = 4,
  }) {
    if (entries.isEmpty) {
      return _roundToOneDecimal((currentStreak.clamp(0, 14) / 14) * 10);
    }

    final totalStudyMinutes = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.studyMinutes,
    );

    final totalTasks = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.tasksCompleted,
    );

    final activeDays = entries.where((entry) => entry.isActiveDay).length;
    final periodDays = entries.length;

    final consistencyComponent = (activeDays / periodDays).clamp(0.0, 1.0) * 40;

    final avgMinutes = totalStudyMinutes / periodDays;
    final minutesComponent =
        (avgMinutes / targetDailyMinutes).clamp(0.0, 1.0) * 30;

    final avgTasks = totalTasks / periodDays;
    final tasksComponent = (avgTasks / targetDailyTasks).clamp(0.0, 1.0) * 20;

    final streakComponent = (currentStreak / 14).clamp(0.0, 1.0) * 10;

    final score =
        consistencyComponent +
        minutesComponent +
        tasksComponent +
        streakComponent;

    return _roundToOneDecimal(score.clamp(0.0, 100.0));
  }

  /// Aggregates subject minutes for a list of entries.
  static Map<String, int> aggregateSubjectMinutes(List<ProgressModel> entries) {
    final result = <String, int>{};

    for (final entry in entries) {
      for (final subjectEntry in entry.subjects.entries) {
        result.update(
          subjectEntry.key,
          (existing) => existing + subjectEntry.value,
          ifAbsent: () => subjectEntry.value,
        );
      }
    }

    return result;
  }

  /// Converts raw minutes to a 0-3 heatmap intensity scale.
  static int heatmapIntensityFromMinutes(int minutes) {
    if (minutes <= 0) {
      return 0;
    }
    if (minutes <= 30) {
      return 1;
    }
    if (minutes <= 60) {
      return 2;
    }
    return 3;
  }

  static double _roundToOneDecimal(double value) {
    return (value * 10).roundToDouble() / 10;
  }
}
