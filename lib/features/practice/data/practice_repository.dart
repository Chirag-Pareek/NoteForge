import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/practice_question_model.dart';
import '../domain/practice_attempt_model.dart';
import '../domain/practice_session_model.dart';

/// Repository for practice questions, attempts, and sessions.
class PracticeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  // ──────────────────────────────────
  // QUESTIONS
  // ──────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _questionsRef =>
      _firestore.collection('users').doc(_uid).collection('practiceQuestions');

  Stream<List<PracticeQuestionModel>> watchQuestions(String chapterId) {
    return _questionsRef
        .where('chapterId', isEqualTo: chapterId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PracticeQuestionModel.fromDocument(d))
            .toList());
  }

  Future<List<PracticeQuestionModel>> getQuestions(String chapterId) async {
    final snap =
        await _questionsRef.where('chapterId', isEqualTo: chapterId).get();
    return snap.docs
        .map((d) => PracticeQuestionModel.fromDocument(d))
        .toList();
  }

  Future<void> addQuestion(PracticeQuestionModel question) {
    return _questionsRef.add(question.toMap());
  }

  Future<void> addQuestions(List<PracticeQuestionModel> questions) async {
    final batch = _firestore.batch();
    for (final q in questions) {
      batch.set(_questionsRef.doc(), q.toMap());
    }
    await batch.commit();
  }

  Future<void> deleteQuestion(String id) => _questionsRef.doc(id).delete();

  // ──────────────────────────────────
  // ATTEMPTS
  // ──────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _attemptsRef =>
      _firestore.collection('users').doc(_uid).collection('practiceAttempts');

  Future<void> saveAttempt(PracticeAttemptModel attempt) {
    return _attemptsRef.add(attempt.toMap());
  }

  Future<void> saveAttempts(List<PracticeAttemptModel> attempts) async {
    final batch = _firestore.batch();
    for (final a in attempts) {
      batch.set(_attemptsRef.doc(), a.toMap());
    }
    await batch.commit();
  }

  // ──────────────────────────────────
  // SESSIONS
  // ──────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _sessionsRef =>
      _firestore.collection('users').doc(_uid).collection('practiceSessions');

  Stream<List<PracticeSessionModel>> watchSessions({String? chapterId}) {
    Query<Map<String, dynamic>> query =
        _sessionsRef.orderBy('completedAt', descending: true);
    if (chapterId != null) {
      query = query.where('chapterId', isEqualTo: chapterId);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((d) => PracticeSessionModel.fromDocument(d)).toList());
  }

  Future<PracticeSessionModel> saveSession(
      PracticeSessionModel session) async {
    final doc = await _sessionsRef.add(session.toMap());
    final snapshot = await doc.get();
    return PracticeSessionModel.fromDocument(
        snapshot);
  }

  /// Gets all sessions for a chapter to compute aggregate stats.
  Future<List<PracticeSessionModel>> getSessionsForChapter(
      String chapterId) async {
    final snap = await _sessionsRef
        .where('chapterId', isEqualTo: chapterId)
        .orderBy('completedAt', descending: true)
        .get();
    return snap.docs
        .map((d) => PracticeSessionModel.fromDocument(d))
        .toList();
  }
}
