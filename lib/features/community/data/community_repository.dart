import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/community_post_model.dart';

/// Repository for community feed operations.
///
/// Includes:
/// - creating posts
/// - liking / unliking
/// - realtime post streams (optionally filtered by subject)
class CommunityRepository {
  CommunityRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _postsRef =>
      _firestore.collection('community_posts');

  /// Creates a new public community post and returns the created post id.
  Future<String> createPost({
    required String authorId,
    required String authorName,
    required String authorUsername,
    required String subjectTag,
    required String content,
  }) async {
    try {
      final docRef = _postsRef.doc();
      await docRef.set({
        'authorId': authorId,
        'authorName': authorName,
        'authorUsername': authorUsername,
        'subjectTag': subjectTag.trim(),
        'content': content.trim(),
        'likes': <String>[],
        // Server timestamp avoids client clock drift.
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create post: ${e.message ?? e.code}');
    } catch (_) {
      throw Exception('Failed to create post.');
    }
  }

  /// Toggles current user's like for the given post.
  ///
  /// Uses a transaction to avoid race conditions between multiple clients.
  Future<void> toggleLikePost({
    required String postId,
    required String userId,
  }) async {
    final postRef = _postsRef.doc(postId);

    try {
      await _firestore.runTransaction((transaction) async {
        final postSnap = await transaction.get(postRef);
        if (!postSnap.exists) {
          throw Exception('Post not found.');
        }

        final data = postSnap.data() ?? <String, dynamic>{};
        final likes = (data['likes'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<String>()
            .toList();

        final alreadyLiked = likes.contains(userId);

        transaction.update(postRef, {
          'likes': alreadyLiked
              ? FieldValue.arrayRemove(<String>[userId])
              : FieldValue.arrayUnion(<String>[userId]),
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update like: ${e.message ?? e.code}');
    }
  }

  /// Explicitly likes a post.
  Future<void> likePost({
    required String postId,
    required String userId,
  }) async {
    try {
      await _postsRef.doc(postId).update({
        'likes': FieldValue.arrayUnion(<String>[userId]),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to like post: ${e.message ?? e.code}');
    }
  }

  /// Explicitly unlikes a post.
  Future<void> unlikePost({
    required String postId,
    required String userId,
  }) async {
    try {
      await _postsRef.doc(postId).update({
        'likes': FieldValue.arrayRemove(<String>[userId]),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to unlike post: ${e.message ?? e.code}');
    }
  }

  /// Realtime stream of public posts ordered by newest first.
  ///
  /// Set [subjectTag] to only receive posts for one subject.
  Stream<List<CommunityPostModel>> streamPublicPosts({
    String? subjectTag,
    int limit = 100,
  }) {
    Query<Map<String, dynamic>> query = _postsRef
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (subjectTag != null && subjectTag.trim().isNotEmpty) {
      query = query.where('subjectTag', isEqualTo: subjectTag.trim());
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(CommunityPostModel.fromDocument)
          .toList(growable: false),
    );
  }
}
