import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/subject_model.dart';
import '../domain/chapter_model.dart';
import '../domain/topic_model.dart';
import '../domain/note_model.dart';

/// Repository for the notes workspace hierarchy.
/// Handles CRUD for subjects, chapters, topics, and notes.
class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  // ──────────────────────────────────
  // SUBJECTS
  // ──────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _subjectsRef =>
      _firestore.collection('users').doc(_uid).collection('subjects');

  Stream<List<SubjectModel>> watchSubjects() {
    return _subjectsRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => SubjectModel.fromDocument(d)).toList(),
        );
  }

  Future<SubjectModel> addSubject(
    String name,
    String color, {
    String? description,
  }) async {
    final now = DateTime.now();
    final doc = await _subjectsRef.add(
      SubjectModel(
        id: '',
        userId: _uid,
        name: name,
        description: description?.trim() ?? '',
        chaptersCount: 0,
        color: color,
        createdAt: now,
        updatedAt: now,
      ).toMap(),
    );
    final snapshot = await doc.get();
    return SubjectModel.fromDocument(snapshot);
  }

  Future<void> updateSubject(
    String id, {
    String? name,
    String? color,
    String? description,
  }) {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (name != null) data['name'] = name;
    if (color != null) data['color'] = color;
    if (description != null) data['description'] = description;
    return _subjectsRef.doc(id).update(data);
  }

  Future<void> deleteSubject(String id) => _subjectsRef.doc(id).delete();

  Future<void> _updateSubjectChaptersCount(String subjectId) async {
    final count =
        (await _chaptersRef
                .where('subjectId', isEqualTo: subjectId)
                .count()
                .get())
            .count;
    await _subjectsRef.doc(subjectId).update({
      'chaptersCount': count ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────────────────────────
  // CHAPTERS
  // ──────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _chaptersRef =>
      _firestore.collection('users').doc(_uid).collection('chapters');

  Stream<List<ChapterModel>> watchChapters(String subjectId) {
    return _chaptersRef
        .where('subjectId', isEqualTo: subjectId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => ChapterModel.fromDocument(d)).toList(),
        );
  }

  Future<ChapterModel> addChapter(String subjectId, String name) async {
    final now = DateTime.now();
    final doc = await _chaptersRef.add(
      ChapterModel(
        id: '',
        subjectId: subjectId,
        name: name,
        topicsCount: 0,
        completedTopics: 0,
        createdAt: now,
        updatedAt: now,
      ).toMap(),
    );
    await _updateSubjectChaptersCount(subjectId);
    final snapshot = await doc.get();
    return ChapterModel.fromDocument(snapshot);
  }

  Future<void> updateChapter(String id, {String? name}) {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (name != null) data['name'] = name;
    return _chaptersRef.doc(id).update(data);
  }

  Future<void> deleteChapter(String id, String subjectId) async {
    await _chaptersRef.doc(id).delete();
    await _updateSubjectChaptersCount(subjectId);
  }

  Future<void> _updateChapterTopicsCount(String chapterId) async {
    final count =
        (await _topicsRef
                .where('chapterId', isEqualTo: chapterId)
                .count()
                .get())
            .count;
    await _chaptersRef.doc(chapterId).update({
      'topicsCount': count ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────────────────────────
  // TOPICS
  // ──────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _topicsRef =>
      _firestore.collection('users').doc(_uid).collection('topics');

  Stream<List<TopicModel>> watchTopics(String chapterId) {
    return _topicsRef
        .where('chapterId', isEqualTo: chapterId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => TopicModel.fromDocument(d)).toList(),
        );
  }

  Future<TopicModel> addTopic(
    String chapterId,
    String subjectId,
    String name,
  ) async {
    final now = DateTime.now();
    final doc = await _topicsRef.add(
      TopicModel(
        id: '',
        chapterId: chapterId,
        subjectId: subjectId,
        name: name,
        notesCount: 0,
        createdAt: now,
        updatedAt: now,
      ).toMap(),
    );
    await _updateChapterTopicsCount(chapterId);
    final snapshot = await doc.get();
    return TopicModel.fromDocument(snapshot);
  }

  Future<void> updateTopic(String id, {String? name}) {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (name != null) data['name'] = name;
    return _topicsRef.doc(id).update(data);
  }

  Future<void> deleteTopic(String id, String chapterId) async {
    await _topicsRef.doc(id).delete();
    await _updateChapterTopicsCount(chapterId);
  }

  Future<void> _updateTopicNotesCount(String topicId) async {
    final count =
        (await _notesRef.where('topicId', isEqualTo: topicId).count().get())
            .count;
    await _topicsRef.doc(topicId).update({
      'notesCount': count ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────────────────────────
  // NOTES
  // ──────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _notesRef =>
      _firestore.collection('users').doc(_uid).collection('notes');

  Stream<List<NoteModel>> watchNotes(String topicId) {
    return _notesRef
        .where('topicId', isEqualTo: topicId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => NoteModel.fromDocument(d)).toList(),
        );
  }

  /// Fetches most recently updated notes across all topics.
  Stream<List<NoteModel>> watchRecentNotes({int limit = 5}) {
    return _notesRef
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => NoteModel.fromDocument(d)).toList(),
        );
  }

  Future<NoteModel> addNote(NoteModel note) async {
    final doc = await _notesRef.add(note.toMap());
    await _updateTopicNotesCount(note.topicId);
    final snapshot = await doc.get();
    return NoteModel.fromDocument(snapshot);
  }

  Future<void> updateNote(
    String id, {
    String? title,
    String? content,
    bool? isDraft,
  }) {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (isDraft != null) data['isDraft'] = isDraft;
    return _notesRef.doc(id).update(data);
  }

  Future<void> deleteNote(String id, String topicId) async {
    await _notesRef.doc(id).delete();
    await _updateTopicNotesCount(topicId);
  }
}
