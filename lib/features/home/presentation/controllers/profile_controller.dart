import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/profile_service.dart';
import '../../domain/profile_model.dart';

/// Controller for profile state and edit operations.
///
/// Exposes:
/// - realtime profile listening
/// - profile update operations
/// - loading / saving / error states
class ProfileController extends ChangeNotifier {
  ProfileController({ProfileService? service})
    : _service = service ?? ProfileService();

  final ProfileService _service;

  StreamSubscription<ProfileModel?>? _profileSubscription;

  ProfileModel? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  /// Begins realtime profile listening for the currently authenticated user.
  Future<void> startProfileListener() async {
    await stopProfileListener();
    _setLoading(true);
    _clearError(notify: false);

    try {
      _profileSubscription = _service.watchProfile().listen(
        (profile) {
          _profile = profile;
          _isLoading = false;
          notifyListeners();
        },
        onError: (Object error) {
          _isLoading = false;
          _setError(_messageFromError(error));
        },
      );
    } on ProfileException catch (e) {
      _isLoading = false;
      _setError(e.message);
    } catch (_) {
      _isLoading = false;
      _setError('Failed to start profile updates. Please try again.');
    }
  }

  /// Stops realtime listener to avoid leaks when screen/view-model is disposed.
  Future<void> stopProfileListener() async {
    await _profileSubscription?.cancel();
    _profileSubscription = null;
  }

  /// One-time profile fetch for the currently authenticated user.
  Future<void> loadProfile() async {
    _setLoading(true);
    _clearError(notify: false);

    try {
      _profile = await _service.fetchProfile();
      _setLoading(false);
    } on ProfileException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Failed to load profile. Please try again.');
    }
  }

  /// Updates editable profile fields and optional profile photo.
  Future<bool> updateProfile({
    String? displayName,
    required String username,
    required String bio,
    required String school,
    required String grade,
    XFile? photoFile,
  }) async {
    _setSaving(true);
    _clearError(notify: false);

    try {
      await _service.updateProfile(
        displayName: displayName,
        username: username,
        bio: bio,
        school: school,
        grade: grade,
        photoFile: photoFile,
      );

      _profile = await _service.fetchProfile();
      _setSaving(false);
      notifyListeners();
      return true;
    } on ProfileException catch (e) {
      _setError(e.message);
      _setSaving(false);
      return false;
    } catch (e) {
      _setError('Failed to update profile. Please try again.');
      _setSaving(false);
      return false;
    }
  }

  /// Validates username uniqueness using case-insensitive matching.
  Future<bool> validateUsername(String username) async {
    try {
      final uid = _profile?.uid ?? _service.currentUid;
      await _service.validateUniqueUsername(
        username: username,
        currentUid: uid,
      );
      _clearError(notify: true);
      return true;
    } on ProfileException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Could not validate username. Please try again.');
      return false;
    }
  }

  void clearError() {
    _clearError(notify: true);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  String _messageFromError(Object error) {
    if (error is ProfileException) {
      return error.message;
    }
    return 'Profile updates failed. Please try again.';
  }

  void _clearError({required bool notify}) {
    _errorMessage = null;
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
