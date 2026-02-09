import 'package:cloud_firestore/cloud_firestore.dart';

/// Low-level Firestore service for profile-related collections.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get usersRef =>
      _firestore.collection('users');

  /// Username index collection used to enforce uniqueness:
  /// `usernames/{normalizedUsername} -> { uid, username, updatedAt }`
  CollectionReference<Map<String, dynamic>> get usernamesRef =>
      _firestore.collection('usernames');

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      usersRef.doc(uid);

  DocumentReference<Map<String, dynamic>> usernameDoc(
    String normalizedUsername,
  ) => usernamesRef.doc(normalizedUsername);

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(String uid) {
    return userDoc(uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    return userDoc(uid).get();
  }

  Future<void> setUser(
    String uid,
    Map<String, dynamic> data, {
    bool merge = true,
  }) {
    return userDoc(uid).set(data, SetOptions(merge: merge));
  }

  Future<T> runTransaction<T>(TransactionHandler<T> transactionHandler) {
    return _firestore.runTransaction(transactionHandler);
  }
}
