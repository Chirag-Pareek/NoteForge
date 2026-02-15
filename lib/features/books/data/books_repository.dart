import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/book_resource_model.dart';

/// Repository for book/PDF resources.
class BooksRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _booksRef =>
      _firestore.collection('users').doc(_uid).collection('books');

  Stream<List<BookResourceModel>> watchBooks({String? subjectId}) {
    Query<Map<String, dynamic>> query =
        _booksRef.orderBy('uploadedAt', descending: true);
    if (subjectId != null) {
      query = query.where('subjectId', isEqualTo: subjectId);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((d) => BookResourceModel.fromDocument(d)).toList());
  }

  /// Uploads a PDF file to Firebase Storage and saves metadata to Firestore.
  Future<BookResourceModel> uploadBook({
    required File file,
    required String title,
    required String subjectId,
    required String fileName,
  }) async {
    // Upload to storage
    final storageRef = _storage.ref().child('users/$_uid/books/$fileName');
    final uploadTask = await storageRef.putFile(file);
    final fileUrl = await uploadTask.ref.getDownloadURL();
    final fileSize = await file.length();

    final now = DateTime.now();
    final book = BookResourceModel(
      id: '',
      userId: _uid,
      subjectId: subjectId,
      title: title,
      fileName: fileName,
      fileUrl: fileUrl,
      fileSize: fileSize,
      lastOpenedAt: now,
      uploadedAt: now,
      linkedNoteIds: const [],
    );

    final doc = await _booksRef.add(book.toMap());
    final snapshot = await doc.get();
    return BookResourceModel.fromDocument(
        snapshot);
  }

  Future<void> updateLastOpened(String id) {
    return _booksRef.doc(id).update({
      'lastOpenedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBook(String id, String fileName) async {
    await _booksRef.doc(id).delete();
    try {
      await _storage.ref().child('users/$_uid/books/$fileName').delete();
    } catch (_) {
      // File may already be deleted from storage
    }
  }

  Future<void> linkNoteToBook(String bookId, String noteId) {
    return _booksRef.doc(bookId).update({
      'linkedNoteIds': FieldValue.arrayUnion([noteId]),
    });
  }
}
