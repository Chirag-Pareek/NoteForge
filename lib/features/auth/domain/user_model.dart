// Domain model representing an authenticated user in the app.
class UserModel {
  // Unique identifier from Firebase Auth.
  final String uid;
  // Optional email address.
  final String? email;
  // Optional display name (e.g., Google profile name).
  final String? displayName;
  // Optional avatar/photo URL.
  final String? photoURL;
  // Indicates whether this account was just created.
  final bool isNewUser;

  // Standard constructor for building a UserModel instance.
  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isNewUser = false,
  });

  // Factory to convert a Firebase user object into a UserModel.
  factory UserModel.fromFirebaseUser(
    dynamic firebaseUser, {
    bool isNewUser = false,
  }) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      isNewUser: isNewUser,
    );
  }

  @override
  // Helpful debug representation.
  String toString() {
    return 'UserModel(uid: $uid, email: $email, isNewUser: $isNewUser)';
  }
}
