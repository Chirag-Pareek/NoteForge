import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/study_plan_repository.dart';
import '../../domain/study_plan_model.dart';
import '../../domain/revision_session_model.dart';

/// Controller for AI study plan and spaced repetition revision.
class StudyPlanController extends ChangeNotifier {
  final StudyPlanRepository _repo = StudyPlanRepository();

  StudyPlanModel? _todayPlan;
  List<StudyPlanModel> _recentPlans = [];
  List<RevisionSessionModel> _allRevisions = [];
  List<RevisionSessionModel> _dueRevisions = [];
  bool _isLoading = false;
  int _currentStreak = 0;
  String? _error;

  StreamSubscription? _plansSub;
  StreamSubscription? _revisionsSub;

  StudyPlanModel? get todayPlan => _todayPlan;
  List<StudyPlanModel> get recentPlans => _recentPlans;
  List<RevisionSessionModel> get allRevisions => _allRevisions;
  List<RevisionSessionModel> get dueRevisions => _dueRevisions;
  bool get isLoading => _isLoading;
  int get currentStreak => _currentStreak;
  String? get error => _error;

  // ──────────────────────────────────
  // STUDY PLANS
  // ──────────────────────────────────

  Future<void> loadTodayPlan() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayPlan = await _repo.getTodayPlan();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void loadRecentPlans() {
    _plansSub?.cancel();
    _plansSub = _repo.watchPlans().listen(
      (list) {
        _recentPlans = list;
        notifyListeners();
      },
    );
  }

  /// Generates a study plan from subjects/chapters data.
  /// This creates a simple plan based on available subjects and chapters.
  Future<StudyPlanModel> generatePlan({
    required List<Map<String, String>> subjectChapters,
  }) async {
    final now = DateTime.now();
    final tasks = <StudyTask>[];

    for (final sc in subjectChapters) {
      // Create a notes task
      tasks.add(StudyTask(
        subjectId: sc['subjectId'] ?? '',
        chapterId: sc['chapterId'] ?? '',
        subjectName: sc['subjectName'] ?? '',
        chapterName: sc['chapterName'] ?? '',
        type: StudyTaskType.notes,
        durationMinutes: 30,
        isCompleted: false,
      ));

      // Create a practice task
      tasks.add(StudyTask(
        subjectId: sc['subjectId'] ?? '',
        chapterId: sc['chapterId'] ?? '',
        subjectName: sc['subjectName'] ?? '',
        chapterName: sc['chapterName'] ?? '',
        type: StudyTaskType.practice,
        durationMinutes: 20,
        isCompleted: false,
      ));
    }

    // Add revision if there are due items
    if (_dueRevisions.isNotEmpty) {
      tasks.add(StudyTask(
        subjectId: '',
        chapterId: '',
        subjectName: 'Revision',
        chapterName: '${_dueRevisions.length} topics due',
        type: StudyTaskType.revision,
        durationMinutes: 15,
        isCompleted: false,
      ));
    }

    final plan = StudyPlanModel(
      id: '',
      userId: '',
      date: DateTime(now.year, now.month, now.day),
      tasks: tasks,
      isCompleted: false,
      createdAt: now,
      adjustedAt: now,
    );

    final saved = await _repo.savePlan(plan);
    _todayPlan = saved;
    notifyListeners();
    return saved;
  }

  Future<void> toggleTask(int taskIndex, bool isCompleted) async {
    if (_todayPlan == null) return;
    await _repo.updateTaskCompletion(_todayPlan!.id, taskIndex, isCompleted);
    await loadTodayPlan();
  }

  // ──────────────────────────────────
  // REVISION (Spaced Repetition)
  // ──────────────────────────────────

  void loadRevisions() {
    _revisionsSub?.cancel();
    _revisionsSub = _repo.watchRevisions().listen(
      (list) {
        _allRevisions = list;
        _dueRevisions = list.where((r) => r.isDue).toList();
        notifyListeners();
      },
    );
  }

  Future<void> refreshDueRevisions() async {
    try {
      _dueRevisions = await _repo.getDueRevisions();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Reviews a topic with the given quality rating (0-5).
  /// Updates SM-2 parameters and saves.
  Future<void> reviewTopic(RevisionSessionModel session, int quality) async {
    final updated = session.reviewWith(quality);
    await _repo.saveRevision(updated);
    await refreshDueRevisions();
  }

  Future<void> addTopicForRevision({
    required String topicId,
    required String chapterId,
    required String subjectId,
    required String topicName,
  }) async {
    await _repo.addTopicForRevision(
      topicId: topicId,
      chapterId: chapterId,
      subjectId: subjectId,
      topicName: topicName,
    );
  }

  // ──────────────────────────────────
  // STREAK
  // ──────────────────────────────────

  Future<void> calculateStreak() async {
    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final count = await _repo.getReviewCountForDate(date);
      if (count > 0) {
        streak++;
      } else if (i > 0) {
        break; // Streak broken
      }
    }

    _currentStreak = streak;
    notifyListeners();
  }

  @override
  void dispose() {
    _plansSub?.cancel();
    _revisionsSub?.cancel();
    super.dispose();
  }
}
