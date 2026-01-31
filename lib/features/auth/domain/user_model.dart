class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isNewUser;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isNewUser = false,
  });

  factory UserModel.fromFirebaseUser(dynamic firebaseUser, {bool isNewUser = false}) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      isNewUser: isNewUser,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, isNewUser: $isNewUser)';
  }
}
