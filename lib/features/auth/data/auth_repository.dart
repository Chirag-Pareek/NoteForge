
import '../domain/user_model.dart';
import 'firebase_auth_service.dart';

// Repository layer that adapts Firebase auth data into domain-level UserModel objects.
class AuthRepository {
  // Internal service wrapper for Firebase auth operations.
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Get current user
  UserModel? get currentUser {
    // Convert Firebase User (if any) into the app's domain model.
    final user = _authService.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  // Auth state changes
  Stream<UserModel?> get authStateChanges {
    // Map Firebase auth stream to domain model stream.
    return _authService.authStateChanges.map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  // Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    // Delegate sign-up to the service, then map to UserModel.
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
    // Delegate sign-in to the service, then map to UserModel.
    final userCredential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    return UserModel.fromFirebaseUser(userCredential.user!);
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    // Supports nullable return when the user cancels the Google flow.
    final userCredential = await _authService.signInWithGoogle();
    if (userCredential != null && userCredential.user != null) {
      // Preserve whether Firebase marks this as a new user.
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      return UserModel.fromFirebaseUser(userCredential.user!, isNewUser: isNewUser);
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    // Sign out of all configured providers.
    await _authService.signOut();
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    // Initiate Firebase password reset flow.
    await _authService.sendPasswordResetEmail(email);
  }

  // Validate email
  bool isValidEmail(String email) {
    // Strict Domain Check: Gmail, iCloud, me.com
    final strictRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@(gmail\.com|icloud\.com|me\.com)$',
      caseSensitive: false,
    );
    // Normalize whitespace before validation.
    return strictRegex.hasMatch(email.trim());
  }

  // Validate password strength
  String? validatePassword(String password) {
    // Return a user-friendly validation error, or null when valid.
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
