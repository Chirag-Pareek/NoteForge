import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/practice_repository.dart';
import '../../domain/practice_question_model.dart';
import '../../domain/practice_attempt_model.dart';
import '../../domain/practice_session_model.dart';

/// Controller for the practice engine.
/// Manages active quiz sessions, score tracking, and history.
class PracticeController extends ChangeNotifier {
  final PracticeRepository _repo = PracticeRepository();

  // ── State ──
  List<PracticeQuestionModel> _questions = [];
  List<PracticeSessionModel> _sessions = [];
  int _currentIndex = 0;
  Map<String, String> _answers = {}; // questionId -> selectedAnswer
  bool _isLoading = false;
  bool _sessionActive = false;
  String? _activeChapterId;
  String? _activeSubjectId;
  String? _error;

  StreamSubscription? _sessionsSub;

  // ── Getters ──
  List<PracticeQuestionModel> get questions => _questions;
  List<PracticeSessionModel> get sessions => _sessions;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get sessionActive => _sessionActive;
  String? get error => _error;
  PracticeQuestionModel? get currentQuestion =>
      _currentIndex < _questions.length ? _questions[_currentIndex] : null;
  int get totalQuestions => _questions.length;
  double get progress =>
      _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;
  Map<String, String> get answers => _answers;

  // ──────────────────────────────────
  // SESSION MANAGEMENT
  // ──────────────────────────────────

  /// Loads questions for a chapter and starts a practice session.
  Future<void> startSession(String chapterId, String subjectId) async {
    _isLoading = true;
    _error = null;
    _activeChapterId = chapterId;
    _activeSubjectId = subjectId;
    notifyListeners();

    try {
      _questions = await _repo.getQuestions(chapterId);
      _questions.shuffle(); // Randomize order
      _currentIndex = 0;
      _answers = {};
      _sessionActive = true;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Records the user's answer for the current question.
  void selectAnswer(String answer) {
    if (currentQuestion == null) return;
    _answers[currentQuestion!.id] = answer;
    notifyListeners();
  }

  /// Moves to the next question.
  bool nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
      return true;
    }
    return false; // No more questions
  }

  /// Moves to the previous question.
  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  /// Finishes the session, computes scores, and saves results.
  Future<PracticeSessionModel?> finishSession() async {
    if (!_sessionActive || _activeChapterId == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      int correct = 0;
      final attempts = <PracticeAttemptModel>[];
      final wrongTopics = <String>{};

      for (final q in _questions) {
        final userAnswer = _answers[q.id] ?? '';
        final isCorrect =
            userAnswer.trim().toLowerCase() ==
            q.correctAnswer.trim().toLowerCase();
        if (isCorrect) {
          correct++;
        } else {
          wrongTopics.add(q.chapterId); // Track weak areas
        }

        attempts.add(PracticeAttemptModel(
          id: '',
          userId: '',
          chapterId: _activeChapterId!,
          questionId: q.id,
          questionType: q.type.name,
          selectedAnswer: userAnswer,
          isCorrect: isCorrect,
          attemptedAt: DateTime.now(),
        ));
      }

      // Save all attempts
      await _repo.saveAttempts(attempts);

      // Save session summary
      final accuracy =
          _questions.isEmpty ? 0.0 : (correct / _questions.length) * 100;

      final session = PracticeSessionModel(
        id: '',
        userId: '',
        chapterId: _activeChapterId!,
        subjectId: _activeSubjectId ?? '',
        totalQuestions: _questions.length,
        correctAnswers: correct,
        accuracy: accuracy,
        weakTopics: wrongTopics.toList(),
        completedAt: DateTime.now(),
      );

      final saved = await _repo.saveSession(session);
      _sessionActive = false;
      _isLoading = false;
      notifyListeners();
      return saved;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ──────────────────────────────────
  // HISTORY
  // ──────────────────────────────────

  void loadHistory({String? chapterId}) {
    _sessionsSub?.cancel();
    _sessionsSub =
        _repo.watchSessions(chapterId: chapterId).listen((list) {
      _sessions = list;
      notifyListeners();
    });
  }

  /// Gets average accuracy for a chapter across all sessions.
  double getChapterAccuracy(String chapterId) {
    final chapterSessions =
        _sessions.where((s) => s.chapterId == chapterId).toList();
    if (chapterSessions.isEmpty) return 0;
    final total =
        chapterSessions.fold<double>(0, (sum, s) => sum + s.accuracy);
    return total / chapterSessions.length;
  }

  /// Gets total attempts for a chapter.
  int getChapterAttempts(String chapterId) {
    return _sessions.where((s) => s.chapterId == chapterId).length;
  }

  /// Detects weak topics based on low accuracy sessions.
  List<String> getWeakTopics() {
    final allWeak = <String>{};
    for (final s in _sessions) {
      if (s.accuracy < 60) {
        allWeak.addAll(s.weakTopics);
      }
    }
    return allWeak.toList();
  }

  void resetSession() {
    _sessionActive = false;
    _questions = [];
    _currentIndex = 0;
    _answers = {};
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionsSub?.cancel();
    super.dispose();
  }
}
