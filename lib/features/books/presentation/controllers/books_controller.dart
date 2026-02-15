import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/books_repository.dart';
import '../../domain/book_resource_model.dart';

/// Controller for books and PDF resources.
class BooksController extends ChangeNotifier {
  final BooksRepository _repo = BooksRepository();

  List<BookResourceModel> _books = [];
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0;
  String? _error;
  StreamSubscription? _booksSub;

  List<BookResourceModel> get books => _books;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;

  /// Groups books by subject ID.
  Map<String, List<BookResourceModel>> get booksBySubject {
    final map = <String, List<BookResourceModel>>{};
    for (final book in _books) {
      map.putIfAbsent(book.subjectId, () => []).add(book);
    }
    return map;
  }

  void loadBooks({String? subjectId}) {
    _booksSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _booksSub = _repo.watchBooks(subjectId: subjectId).listen(
      (list) {
        _books = list;
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

  Future<void> uploadBook({
    required File file,
    required String title,
    required String subjectId,
    required String fileName,
  }) async {
    _isUploading = true;
    _uploadProgress = 0;
    _error = null;
    notifyListeners();

    try {
      await _repo.uploadBook(
        file: file,
        title: title,
        subjectId: subjectId,
        fileName: fileName,
      );
      _uploadProgress = 1.0;
    } catch (e) {
      _error = e.toString();
    }

    _isUploading = false;
    notifyListeners();
  }

  Future<void> openBook(String id) async {
    await _repo.updateLastOpened(id);
  }

  Future<void> deleteBook(String id, String fileName) async {
    try {
      await _repo.deleteBook(id, fileName);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _booksSub?.cancel();
    super.dispose();
  }
}
