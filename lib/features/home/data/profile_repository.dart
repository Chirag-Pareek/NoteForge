import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/profile_model.dart';
import 'firestore_service.dart';
import 'storage_service.dart';

/// Repository that coordinates profile reads/writes across Firestore and Storage.
class ProfileRepository {
  ProfileRepository({
    FirestoreService? firestoreService,
    StorageService? storageService,
  }) : _firestoreService = firestoreService ?? FirestoreService(),
       _storageService = storageService ?? StorageService();

  final FirestoreService _firestoreService;
  final StorageService _storageService;

  /// Realtime profile updates for `users/{uid}`.
  Stream<ProfileModel?> streamProfile(String uid) {
    return _firestoreService.streamUser(uid).map((doc) {
      if (!doc.exists) {
        return null;
      }
      return ProfileModel.fromDocument(doc);
    });
  }

  /// Single profile fetch.
  Future<ProfileModel?> getProfile(String uid) async {
    try {
      final doc = await _firestoreService.getUser(uid);
      if (!doc.exists) {
        return null;
      }
      return ProfileModel.fromDocument(doc);
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch profile: ${e.message ?? e.code}');
    }
  }

  /// Checks if a username is available.
  ///
  /// Uses username index docs to avoid query scans and race conditions.
  Future<bool> isUsernameAvailable({
    required String username,
    String? excludingUid,
  }) async {
    final normalized = ProfileModel.normalizeUsername(username);
    if (normalized.isEmpty) {
      return false;
    }

    try {
      final doc = await _firestoreService.usernameDoc(normalized).get();
      if (!doc.exists) {
        return true;
      }

      if (excludingUid == null) {
        return false;
      }

      final ownerUid = (doc.data()?['uid'] as String?) ?? '';
      return ownerUid == excludingUid;
    } on FirebaseException catch (e) {
      throw Exception('Failed to check username: ${e.message ?? e.code}');
    }
  }

  /// Updates profile fields and optionally uploads a new profile image.
  ///
  /// Supports:
  /// - displayName
  /// - username (uniqueness enforced)
  /// - classOrField
  /// - photoUrl via Firebase Storage upload
  /// - extra fields through [additionalFields]
  Future<void> updateProfile({
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
    String? uploadedPhotoUrl;
    bool uploadedInThisCall = false;

    try {
      // Upload first so Firestore can be updated with the final stable URL.
      if (profileImageBytes != null) {
        uploadedPhotoUrl = await _storageService.uploadProfilePhoto(
          uid: uid,
          bytes: profileImageBytes,
          fileExtension: imageFileExtension,
          contentType: imageContentType,
        );
        uploadedInThisCall = true;
      }

      await _firestoreService.runTransaction<void>((transaction) async {
        final userRef = _firestoreService.userDoc(uid);
        final userSnap = await transaction.get(userRef);

        if (!userSnap.exists) {
          throw Exception('User profile not found.');
        }

        final existingData = userSnap.data() ?? <String, dynamic>{};
        final existingUsername = (existingData['username'] as String?) ?? '';
        final normalizedExistingUsername = ProfileModel.normalizeUsername(
          existingUsername,
        );

        final hasUsernameUpdate = username != null;
        final requestedUsername = (username ?? existingUsername).trim();
        final normalizedRequestedUsername = ProfileModel.normalizeUsername(
          requestedUsername,
        );

        if (hasUsernameUpdate && normalizedRequestedUsername.isEmpty) {
          throw Exception('Username cannot be empty.');
        }

        final isUsernameChanged =
            hasUsernameUpdate &&
            normalizedRequestedUsername != normalizedExistingUsername;

        if (isUsernameChanged) {
          final newUsernameRef = _firestoreService.usernameDoc(
            normalizedRequestedUsername,
          );
          final newUsernameSnap = await transaction.get(newUsernameRef);

          if (newUsernameSnap.exists) {
            final ownerUid = (newUsernameSnap.data()?['uid'] as String?) ?? '';
            if (ownerUid != uid) {
              throw Exception('Username is already taken.');
            }
          }

          transaction.set(newUsernameRef, {
            'uid': uid,
            'username': requestedUsername,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          if (normalizedExistingUsername.isNotEmpty) {
            final oldUsernameRef = _firestoreService.usernameDoc(
              normalizedExistingUsername,
            );
            final oldUsernameSnap = await transaction.get(oldUsernameRef);
            final oldOwnerUid =
                (oldUsernameSnap.data()?['uid'] as String?) ?? '';
            if (oldOwnerUid == uid) {
              transaction.delete(oldUsernameRef);
            }
          }
        }

        final updateData = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
          ...additionalFields,
        };

        if (displayName != null) {
          updateData['displayName'] = displayName.trim();
        }
        if (hasUsernameUpdate) {
          updateData['username'] = requestedUsername;
        }
        if (classOrField != null) {
          updateData['classOrField'] = classOrField.trim();
        }
        if (email != null) {
          updateData['email'] = email.trim();
        }
        if (uploadedPhotoUrl != null) {
          updateData['photoUrl'] = uploadedPhotoUrl;
        }

        transaction.set(userRef, updateData, SetOptions(merge: true));
      });
    } on FirebaseException catch (e) {
      if (uploadedInThisCall && uploadedPhotoUrl != null) {
        await _storageService.deleteByUrl(uploadedPhotoUrl);
      }
      throw Exception('Failed to update profile: ${e.message ?? e.code}');
    } catch (e) {
      if (uploadedInThisCall && uploadedPhotoUrl != null) {
        await _storageService.deleteByUrl(uploadedPhotoUrl);
      }
      throw Exception('Failed to update profile: $e');
    }
  }
}
