import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../notes/data/notes_repository.dart';
import '../../../notes/domain/subject_model.dart';
import '../../../notes/domain/chapter_model.dart';
import '../../../notes/domain/topic_model.dart';
import '../../../notes/domain/note_model.dart';

/// Controller managing the entire notes workspace hierarchy.
/// Provides reactive state for subjects, chapters, topics, and notes.
class NotesController extends ChangeNotifier {
  final NotesRepository _repo = NotesRepository();

  // ── State ──
  List<SubjectModel> _subjects = [];
  List<ChapterModel> _chapters = [];
  List<TopicModel> _topics = [];
  List<NoteModel> _notes = [];
  List<NoteModel> _recentNotes = [];
  bool _isLoading = false;
  String? _error;

  // ── Auto-save ──
  Timer? _autoSaveTimer;
  String? _editingNoteId;
  String _draftTitle = '';
  String _draftContent = '';
  bool _isSaving = false;
  bool _hasPendingChanges = false;

  // ── Subscriptions ──
  StreamSubscription? _subjectsSub;
  StreamSubscription? _chaptersSub;
  StreamSubscription? _topicsSub;
  StreamSubscription? _notesSub;
  StreamSubscription? _recentNotesSub;

  // ── Getters ──
  List<SubjectModel> get subjects => _subjects;
  List<ChapterModel> get chapters => _chapters;
  List<TopicModel> get topics => _topics;
  List<NoteModel> get notes => _notes;
  List<NoteModel> get recentNotes => _recentNotes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSaving => _isSaving;
  bool get hasPendingChanges => _hasPendingChanges;

  // ──────────────────────────────────
  // SUBJECTS
  // ──────────────────────────────────

  void loadSubjects() {
    _subjectsSub?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subjectsSub = _repo.watchSubjects().listen(
      (list) {
        _subjects = list;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addSubject(
    String name, {
    String? description,
    String color = '0xFF6B7280',
  }) async {
    try {
      await _repo.addSubject(name, color, description: description);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateSubject(
    String id, {
    String? name,
    String? color,
    String? description,
  }) async {
    try {
      await _repo.updateSubject(
        id,
        name: name,
        color: color,
        description: description,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _repo.deleteSubject(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ──────────────────────────────────
  // CHAPTERS
  // ──────────────────────────────────

  void loadChapters(String subjectId) {
    _chaptersSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _chaptersSub = _repo
        .watchChapters(subjectId)
        .listen(
          (list) {
            _chapters = list;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> addChapter(String subjectId, String name) async {
    try {
      await _repo.addChapter(subjectId, name);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateChapter(String id, {String? name}) async {
    try {
      await _repo.updateChapter(id, name: name);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteChapter(String id, String subjectId) async {
    try {
      await _repo.deleteChapter(id, subjectId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ──────────────────────────────────
  // TOPICS
  // ──────────────────────────────────

  void loadTopics(String chapterId) {
    _topicsSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _topicsSub = _repo
        .watchTopics(chapterId)
        .listen(
          (list) {
            _topics = list;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> addTopic(String chapterId, String subjectId, String name) async {
    try {
      await _repo.addTopic(chapterId, subjectId, name);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTopic(String id, {String? name}) async {
    try {
      await _repo.updateTopic(id, name: name);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTopic(String id, String chapterId) async {
    try {
      await _repo.deleteTopic(id, chapterId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ──────────────────────────────────
  // NOTES
  // ──────────────────────────────────

  void loadNotes(String topicId) {
    _notesSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _notesSub = _repo
        .watchNotes(topicId)
        .listen(
          (list) {
            _notes = list;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void loadRecentNotes() {
    _recentNotesSub?.cancel();
    _recentNotesSub = _repo.watchRecentNotes(limit: 3).listen((list) {
      _recentNotes = list;
      notifyListeners();
    });
  }

  Future<NoteModel> createNote({
    required String topicId,
    required String chapterId,
    required String subjectId,
  }) async {
    final note = NoteModel.emptyDraft(
      topicId: topicId,
      chapterId: chapterId,
      subjectId: subjectId,
    );
    return await _repo.addNote(note);
  }

  Future<void> deleteNote(String id, String topicId) async {
    try {
      await _repo.deleteNote(id, topicId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ──────────────────────────────────
  // AUTO-SAVE (for note editor)
  // ──────────────────────────────────

  void startEditing(String noteId, String title, String content) {
    _editingNoteId = noteId;
    _draftTitle = title;
    _draftContent = content;
    _hasPendingChanges = false;
  }

  void onEditorChanged(String title, String content) {
    _draftTitle = title;
    _draftContent = content;
    _hasPendingChanges = true;
    notifyListeners();

    // Debounced auto-save: 3 seconds of inactivity
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), _autoSave);
  }

  Future<void> _autoSave() async {
    if (_editingNoteId == null || !_hasPendingChanges) return;
    _isSaving = true;
    notifyListeners();

    try {
      await _repo.updateNote(
        _editingNoteId!,
        title: _draftTitle,
        content: _draftContent,
      );
      _hasPendingChanges = false;
    } catch (e) {
      _error = e.toString();
    }

    _isSaving = false;
    notifyListeners();
  }

  /// Force-saves the current draft (called on back press or explicit save).
  Future<void> saveNow({bool markAsFinal = false}) async {
    _autoSaveTimer?.cancel();
    if (_editingNoteId == null) return;
    _isSaving = true;
    notifyListeners();

    try {
      await _repo.updateNote(
        _editingNoteId!,
        title: _draftTitle,
        content: _draftContent,
        isDraft: !markAsFinal,
      );
      _hasPendingChanges = false;
    } catch (e) {
      _error = e.toString();
    }

    _isSaving = false;
    notifyListeners();
  }

  void stopEditing() {
    _autoSaveTimer?.cancel();
    _editingNoteId = null;
    _hasPendingChanges = false;
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _subjectsSub?.cancel();
    _chaptersSub?.cancel();
    _topicsSub?.cancel();
    _notesSub?.cancel();
    _recentNotesSub?.cancel();
    super.dispose();
  }
}
