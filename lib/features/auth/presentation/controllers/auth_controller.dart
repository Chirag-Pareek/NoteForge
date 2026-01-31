import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';

enum AuthResult { success, newUser, cancelled, failure }

class AuthController extends ChangeNotifier {
  late final AuthRepository _authRepository;
  late final StreamSubscription _authSubscription;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && !_isLoading;

  /// ✅ Dependency Injection Friendly
  AuthController({AuthRepository? repository}) {
    _authRepository = repository ?? AuthRepository();
    _initializeAuthListener();
  }

  /// 🔥 Listen to auth state (CRITICAL)
  void _initializeAuthListener() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// 🌐 Internet Check (Production Safe)
  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return result != ConnectivityResult.none;
  }

  /// 🔥 Firebase Error Mapper
  String _mapFirebaseError(dynamic e) {
    final message = e.toString();

    if (message.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }

    if (message.contains('weak-password')) {
      return 'Password is too weak.';
    }

    if (message.contains('user-not-found')) {
      return 'No account found for this email.';
    }

    if (message.contains('wrong-password')) {
      return 'Incorrect password.';
    }

    if (message.contains('invalid-email')) {
      return 'Invalid email address.';
    }

    if (message.contains('network-request-failed')) {
      return 'Network error. Check your internet connection.';
    }

    return 'Authentication failed. Please try again.';
  }

  /// ---------------------------
  /// SIGN UP
  /// ---------------------------

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _clearMessages();

    if (!await _hasInternet()) {
      _setError('No internet connection');
      return false;
    }

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _setError('All fields are required');
      return false;
    }

    if (!_authRepository.isValidEmail(email)) {
      _setError('Enter a valid Gmail or Apple email.');
      return false;
    }

    if (password != confirmPassword) {
      _setError('Passwords do not match.');
      return false;
    }

    final passwordError = _authRepository.validatePassword(password);
    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    _setLoading(true);

    try {
      await _authRepository.signUpWithEmail(email: email, password: password);

      _successMessage = 'Account created successfully!';
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_mapFirebaseError(e));
      _setLoading(false);
      return false;
    }
  }

  /// ---------------------------
  /// LOGIN
  /// ---------------------------

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _clearMessages();

    if (!await _hasInternet()) {
      _setError('No internet connection');
      return false;
    }

    if (email.isEmpty || password.isEmpty) {
      _setError('Email and password are required.');
      return false;
    }

    if (!_authRepository.isValidEmail(email)) {
      _setError('Enter a valid Gmail or Apple email.');
      return false;
    }

    _setLoading(true);

    try {
      await _authRepository.signInWithEmail(email: email, password: password);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_mapFirebaseError(e));
      _setLoading(false);
      return false;
    }
  }

  /// ---------------------------
  /// GOOGLE SIGN IN
  /// ---------------------------

  Future<AuthResult> signInWithGoogle() async {
    _clearMessages();

    if (!await _hasInternet()) {
      _setError('No internet connection');
      return AuthResult.failure;
    }

    _setLoading(true);

    try {
      final user = await _authRepository.signInWithGoogle();

      _setLoading(false);

      if (user == null) {
        return AuthResult.cancelled;
      }

      if (user.isNewUser) {
        return AuthResult.newUser;
      }

      return AuthResult.success;
    } catch (e) {
      _setError(_mapFirebaseError(e));
      _setLoading(false);
      return AuthResult.failure;
    }
  }

  /// ---------------------------
  /// PASSWORD RESET
  /// ---------------------------

  Future<bool> resetPassword(String email) async {
    _clearMessages();

    if (!await _hasInternet()) {
      _setError('No internet connection');
      return false;
    }

    if (email.isEmpty) {
      _setError('Please enter your email.');
      return false;
    }

    if (!_authRepository.isValidEmail(email)) {
      _setError('Enter a valid Gmail or Apple email.');
      return false;
    }

    _setLoading(true);

    try {
      await _authRepository.sendPasswordResetEmail(email);

      _successMessage = 'Password reset link sent!';
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_mapFirebaseError(e));
      _setLoading(false);
      return false;
    }
  }

  /// ---------------------------
  /// LOGOUT
  /// ---------------------------

  Future<void> signOut() async {
    _clearMessages();
    _setLoading(true);

    try {
      await _authRepository.signOut();
      _setLoading(false);
    } catch (e) {
      _setError(_mapFirebaseError(e));
      _setLoading(false);
    }
  }

  /// ---------------------------
  /// HELPERS
  /// ---------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 🔥 Prevent Memory Leak
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
