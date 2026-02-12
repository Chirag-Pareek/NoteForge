import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared Firestore paths and field names for profile documents.
class FirestoreUtils {
  const FirestoreUtils._();

  static const String usersCollection = 'users';
  static const String usernamesCollection = 'usernames';

  static const String fieldUid = 'uid';
  static const String fieldDisplayName = 'displayName';
  static const String fieldUsername = 'username';
  static const String fieldBio = 'bio';
  static const String fieldSchool = 'school';
  static const String fieldGrade = 'grade';
  static const String fieldPhotoUrl = 'photoUrl';
  static const String fieldUpdatedAt = 'updatedAt';

  static DocumentReference<Map<String, dynamic>> userDoc(
    FirebaseFirestore db,
    String uid,
  ) {
    return db.collection(usersCollection).doc(uid);
  }

  static DocumentReference<Map<String, dynamic>> usernameDoc(
    FirebaseFirestore db,
    String normalizedUsername,
  ) {
    return db.collection(usernamesCollection).doc(normalizedUsername);
  }
}
