import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage service for profile images.
class StorageService {
  StorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads a profile image and returns its download URL.
  Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
    String fileExtension = 'jpg',
    String? contentType,
  }) async {
    try {
      final safeExt = fileExtension.trim().toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'users/$uid/profile/profile_$timestamp.$safeExt';

      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: contentType ?? 'image/jpeg',
        cacheControl: 'public,max-age=86400',
      );

      await ref.putData(bytes, metadata);
      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload profile photo: ${e.message ?? e.code}');
    }
  }

  /// Best-effort cleanup for uploaded files when an operation fails later.
  Future<void> deleteByUrl(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } on FirebaseException {
      // Ignore cleanup errors to avoid masking original operation failures.
    }
  }
}
