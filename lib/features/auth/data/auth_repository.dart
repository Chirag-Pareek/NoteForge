
import '../domain/user_model.dart';
import 'firebase_auth_service.dart';

class AuthRepository {
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Get current user
  UserModel? get currentUser {
    final user = _authService.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  // Auth state changes
  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  // Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );
    return UserModel.fromFirebaseUser(userCredential.user!);
  }

  // Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    return UserModel.fromFirebaseUser(userCredential.user!);
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    final userCredential = await _authService.signInWithGoogle();
    if (userCredential != null && userCredential.user != null) {
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      return UserModel.fromFirebaseUser(userCredential.user!, isNewUser: isNewUser);
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  // Validate email
  bool isValidEmail(String email) {
    // Strict Domain Check: Gmail, iCloud, me.com
    final strictRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@(gmail\.com|icloud\.com|me\.com)$',
      caseSensitive: false,
    );
    return strictRegex.hasMatch(email.trim());
  }

  // Validate password strength
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    // Special character check (simplified)
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
}
