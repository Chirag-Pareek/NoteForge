import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/study_plan_model.dart';
import '../domain/revision_session_model.dart';

/// Repository for study plans and revision sessions.
class StudyPlanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  // ──────────────────────────────────
  // STUDY PLANS
  // ──────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _plansRef =>
      _firestore.collection('users').doc(_uid).collection('studyPlans');

  Stream<List<StudyPlanModel>> watchPlans() {
    return _plansRef
        .orderBy('date', descending: true)
        .limit(7)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => StudyPlanModel.fromDocument(d)).toList());
  }

  Future<StudyPlanModel?> getTodayPlan() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final snap = await _plansRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('date', isLessThan: Timestamp.fromDate(todayEnd))
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return StudyPlanModel.fromDocument(snap.docs.first);
  }

  Future<StudyPlanModel> savePlan(StudyPlanModel plan) async {
    if (plan.id.isEmpty) {
      final doc = await _plansRef.add(plan.toMap());
      final snapshot = await doc.get();
      return StudyPlanModel.fromDocument(
          snapshot);
    } else {
      await _plansRef.doc(plan.id).update(plan.toMap());
      return plan;
    }
  }

  Future<void> updateTaskCompletion(
      String planId, int taskIndex, bool isCompleted) async {
    final doc = await _plansRef.doc(planId).get();
    if (!doc.exists) return;

    final plan = StudyPlanModel.fromDocument(doc);
    final updatedTasks = List<StudyTask>.from(plan.tasks);
    if (taskIndex < updatedTasks.length) {
      updatedTasks[taskIndex] =
          updatedTasks[taskIndex].copyWith(isCompleted: isCompleted);
    }

    final allCompleted = updatedTasks.every((t) => t.isCompleted);
    await _plansRef.doc(planId).update({
      'tasks': updatedTasks.map((t) => t.toMap()).toList(),
      'isCompleted': allCompleted,
      'adjustedAt': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────────────────────────
  // REVISION SESSIONS
  // ──────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _revisionsRef =>
      _firestore.collection('users').doc(_uid).collection('revisionSessions');

  Stream<List<RevisionSessionModel>> watchRevisions() {
    return _revisionsRef.snapshots().map((snap) =>
        snap.docs.map((d) => RevisionSessionModel.fromDocument(d)).toList());
  }

  /// Gets topics due for review today.
  Future<List<RevisionSessionModel>> getDueRevisions() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day + 1);
    final snap = await _revisionsRef
        .where('nextReviewDate',
            isLessThanOrEqualTo: Timestamp.fromDate(today))
        .get();
    return snap.docs
        .map((d) => RevisionSessionModel.fromDocument(d))
        .toList();
  }

  Future<void> saveRevision(RevisionSessionModel session) async {
    if (session.id.isEmpty) {
      await _revisionsRef.add(session.toMap());
    } else {
      await _revisionsRef.doc(session.id).update(session.toMap());
    }
  }

  Future<void> addTopicForRevision({
    required String topicId,
    required String chapterId,
    required String subjectId,
    required String topicName,
  }) async {
    // Check if already exists
    final existing = await _revisionsRef
        .where('topicId', isEqualTo: topicId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final session = RevisionSessionModel.create(
      userId: _uid,
      topicId: topicId,
      chapterId: chapterId,
      subjectId: subjectId,
      topicName: topicName,
    );
    await _revisionsRef.add(session.toMap());
  }

  /// Gets count of completed reviews for streak tracking.
  Future<int> getReviewCountForDate(DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final snap = await _revisionsRef
        .where('lastReviewedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('lastReviewedAt', isLessThan: Timestamp.fromDate(dayEnd))
        .count()
        .get();
    return snap.count ?? 0;
  }
}
