import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/profile_repository.dart';
import '../../domain/profile_model.dart';

/// Controller for profile state and edit operations.
///
/// Exposes:
/// - realtime profile listening
/// - profile update operations
/// - loading / saving / error states
class ProfileController extends ChangeNotifier {
  ProfileController({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository();

  final ProfileRepository _repository;

  StreamSubscription<ProfileModel?>? _profileSub;

  ProfileModel? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  /// Begins realtime profile listening for [uid].
  Future<void> startProfileListener(String uid) async {
    _setLoading(true);
    _clearError(notify: false);

    await _profileSub?.cancel();
    _profileSub = _repository
        .streamProfile(uid)
        .listen(
          (profile) {
            _profile = profile;
            _setLoading(false);
          },
          onError: (Object error) {
            _setError(error.toString());
          },
        );
  }

  /// Stops realtime listener to avoid leaks when screen/view-model is disposed.
  Future<void> stopProfileListener() async {
    await _profileSub?.cancel();
    _profileSub = null;
  }

  /// One-time fetch for fresh profile data.
  Future<void> loadProfile(String uid) async {
    _setLoading(true);
    _clearError(notify: false);
    try {
      _profile = await _repository.getProfile(uid);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Updates editable profile fields.
  Future<bool> updateProfile({
    required String uid,
    String? displayName,
    String? username,
    String? classOrField,
    String? email,
    Uint8List? profileImageBytes,
    String imageFileExtension = 'jpg',
    String? imageContentType,
    Map<String, dynamic> additionalFields = const <String, dynamic>{},
  }) async {
    _setSaving(true);
    _clearError(notify: false);

    try {
      await _repository.updateProfile(
        uid: uid,
        displayName: displayName,
        username: username,
        classOrField: classOrField,
        email: email,
        profileImageBytes: profileImageBytes,
        imageFileExtension: imageFileExtension,
        imageContentType: imageContentType,
        additionalFields: additionalFields,
      );

      _setSaving(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setSaving(false);
      return false;
    }
  }

  /// Checks username availability (useful before submission).
  Future<bool> isUsernameAvailable(String username, {String? currentUid}) {
    return _repository.isUsernameAvailable(
      username: username,
      excludingUid: currentUid,
    );
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

  void _clearError({required bool notify}) {
    _errorMessage = null;
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }
}
