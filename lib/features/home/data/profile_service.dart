import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/profile_model.dart';
import 'firestore_utils.dart';

/// Base exception for profile-related failures.
class ProfileException implements Exception {
  final String message;

  const ProfileException(this.message);

  @override
  String toString() => message;
}

/// Thrown when an authenticated user is required but not available.
class ProfileAuthException extends ProfileException {
  const ProfileAuthException([super.message = 'Please sign in again.']);
}

/// Thrown when submitted profile data is invalid.
class ProfileValidationException extends ProfileException {
  const ProfileValidationException(super.message);
}

/// Thrown when a username is already owned by another user.
class UsernameTakenException extends ProfileException {
  const UsernameTakenException([
    super.message = 'This username is already taken.',
  ]);
}

/// Thrown for Firestore/Storage persistence failures.
class ProfilePersistenceException extends ProfileException {
  const ProfilePersistenceException([
    super.message = 'Unable to save profile changes. Please try again.',
  ]);
}

/// Service responsible for profile reads, writes, and photo uploads.
class ProfileService {
  ProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Returns the current user id or throws when unauthenticated.
  String get currentUid => _requireCurrentUid();

  /// Fetches the current user's profile once from `users/{uid}`.
  Future<ProfileModel?> fetchProfile() async {
    final uid = _requireCurrentUid();

    try {
      final doc = await FirestoreUtils.userDoc(_firestore, uid).get();
      if (!doc.exists) {
        return null;
      }
      return ProfileModel.fromJson(doc.id, doc.data() ?? <String, dynamic>{});
    } on FirebaseException {
      throw const ProfilePersistenceException(
        'Failed to load your profile. Please try again.',
      );
    }
  }

  /// Listens to realtime profile changes for the current user.
  Stream<ProfileModel?> watchProfile() {
    final uid = _requireCurrentUid();

    return FirestoreUtils.userDoc(_firestore, uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return ProfileModel.fromJson(doc.id, doc.data() ?? <String, dynamic>{});
    });
  }

  /// Ensures [username] is unique across all users except [currentUid].
  Future<void> validateUniqueUsername({
    required String username,
    required String currentUid,
  }) async {
    final normalized = ProfileModel.normalizeUsername(username);
    if (normalized.isEmpty) {
      throw const ProfileValidationException('Username cannot be empty.');
    }

    try {
      final usernameSnapshot = await FirestoreUtils.usernameDoc(
        _firestore,
        normalized,
      ).get();

      if (!usernameSnapshot.exists) {
        return;
      }

      final ownerUid =
          (usernameSnapshot.data()?[FirestoreUtils.fieldUid] as String?) ?? '';
      if (ownerUid != currentUid) {
        throw const UsernameTakenException();
      }
    } on ProfileException {
      rethrow;
    } on FirebaseException {
      throw const ProfilePersistenceException(
        'Could not validate username right now. Please try again.',
      );
    }
  }

  /// Uploads the selected profile photo and returns its download URL.
  Future<String> uploadProfilePhoto({
    required String uid,
    required XFile photoFile,
  }) async {
    try {
      final bytes = await photoFile.readAsBytes();
      if (bytes.isEmpty) {
        throw const ProfilePersistenceException(
          'Selected image is empty. Please choose another photo.',
        );
      }

      final extension = _extractFileExtension(photoFile.path);
      final contentType = _contentTypeForExtension(extension);
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}';
      final path = 'users/$uid/profile/$fileName.$extension';

      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: contentType,
        cacheControl: 'public,max-age=3600',
      );

      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } on ProfileException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ProfilePersistenceException(_uploadErrorMessage(e));
    } catch (_) {
      throw const ProfilePersistenceException(
        'Failed to process profile photo. Please choose a valid image.',
      );
    }
  }

  /// Updates profile fields and optionally uploads a new profile photo.
  Future<void> updateProfile({
    String? displayName,
    required String username,
    required String bio,
    required String school,
    required String grade,
    XFile? photoFile,
  }) async {
    final uid = _requireCurrentUid();
    final trimmedUsername = username.trim();
    final normalizedNewUsername = ProfileModel.normalizeUsername(
      trimmedUsername,
    );

    if (normalizedNewUsername.isEmpty) {
      throw const ProfileValidationException('Username cannot be empty.');
    }

    final trimmedDisplayName = displayName?.trim();
    final trimmedBio = bio.trim();
    final trimmedSchool = school.trim();
    final trimmedGrade = grade.trim();

    String? uploadedPhotoUrl;
    var uploadedInThisRequest = false;

    try {
      if (photoFile != null) {
        uploadedPhotoUrl = await uploadProfilePhoto(
          uid: uid,
          photoFile: photoFile,
        );
        uploadedInThisRequest = true;
      }

      await _firestore.runTransaction<void>((transaction) async {
        final userRef = FirestoreUtils.userDoc(_firestore, uid);
        final userSnapshot = await transaction.get(userRef);
        final userData = userSnapshot.data() ?? <String, dynamic>{};

        final existingUsername =
            (userData[FirestoreUtils.fieldUsername] as String?) ?? '';
        final normalizedExistingUsername = ProfileModel.normalizeUsername(
          existingUsername,
        );
        final isUsernameChanged =
            normalizedExistingUsername != normalizedNewUsername;

        final newUsernameRef = FirestoreUtils.usernameDoc(
          _firestore,
          normalizedNewUsername,
        );
        final newUsernameSnapshot = await transaction.get(newUsernameRef);

        if (newUsernameSnapshot.exists) {
          final ownerUid =
              (newUsernameSnapshot.data()?[FirestoreUtils.fieldUid]
                  as String?) ??
              '';
          if (ownerUid != uid) {
            throw const UsernameTakenException();
          }
        }

        transaction.set(newUsernameRef, <String, dynamic>{
          FirestoreUtils.fieldUid: uid,
          FirestoreUtils.fieldUsername: trimmedUsername,
          FirestoreUtils.fieldUpdatedAt: FieldValue.serverTimestamp(),
        });

        if (isUsernameChanged && normalizedExistingUsername.isNotEmpty) {
          final oldUsernameRef = FirestoreUtils.usernameDoc(
            _firestore,
            normalizedExistingUsername,
          );
          final oldUsernameSnapshot = await transaction.get(oldUsernameRef);

          if (oldUsernameSnapshot.exists) {
            final oldOwnerUid =
                (oldUsernameSnapshot.data()?[FirestoreUtils.fieldUid]
                    as String?) ??
                '';
            if (oldOwnerUid == uid) {
              transaction.delete(oldUsernameRef);
            }
          }
        }

        final updates = <String, dynamic>{
          FirestoreUtils.fieldUsername: trimmedUsername,
          FirestoreUtils.fieldBio: trimmedBio,
          FirestoreUtils.fieldSchool: trimmedSchool,
          FirestoreUtils.fieldGrade: trimmedGrade,
          FirestoreUtils.fieldUpdatedAt: FieldValue.serverTimestamp(),
        };

        if (trimmedDisplayName != null) {
          updates[FirestoreUtils.fieldDisplayName] = trimmedDisplayName;
        }
        if (uploadedPhotoUrl != null) {
          updates[FirestoreUtils.fieldPhotoUrl] = uploadedPhotoUrl;
        }

        transaction.set(userRef, updates, SetOptions(merge: true));
      });
    } on ProfileException {
      if (uploadedInThisRequest && uploadedPhotoUrl != null) {
        await _bestEffortDeleteByUrl(uploadedPhotoUrl);
      }
      rethrow;
    } on FirebaseException {
      if (uploadedInThisRequest && uploadedPhotoUrl != null) {
        await _bestEffortDeleteByUrl(uploadedPhotoUrl);
      }
      throw const ProfilePersistenceException();
    } catch (_) {
      if (uploadedInThisRequest && uploadedPhotoUrl != null) {
        await _bestEffortDeleteByUrl(uploadedPhotoUrl);
      }
      throw const ProfilePersistenceException();
    }
  }

  String _requireCurrentUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ProfileAuthException();
    }
    return user.uid;
  }

  String _extractFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1 || lastDot == path.length - 1) {
      return 'jpg';
    }

    final rawExt = path.substring(lastDot + 1).trim().toLowerCase();
    final ext = rawExt.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (ext.isEmpty || ext.length > 5) {
      return 'jpg';
    }
    return ext;
  }

  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _bestEffortDeleteByUrl(String? downloadUrl) async {
    if (downloadUrl == null || downloadUrl.isEmpty) {
      return;
    }
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } on FirebaseException {
      // Cleanup should not mask the main operation error.
    }
  }

  String _uploadErrorMessage(FirebaseException e) {
    if (kDebugMode) {
      debugPrint('Profile photo upload failed: [${e.code}] ${e.message}');
    }

    switch (e.code) {
      case 'permission-denied':
      case 'unauthorized':
        return 'Photo upload permission denied. Check Firebase Storage rules for authenticated users.';
      case 'retry-limit-exceeded':
      case 'network-request-failed':
        return 'Network issue while uploading photo. Please try again.';
      case 'canceled':
        return 'Photo upload was cancelled.';
      default:
        return e.message == null || e.message!.trim().isEmpty
            ? 'Failed to upload profile photo. Please try again.'
            : 'Failed to upload profile photo: ${e.message}';
    }
  }
}
