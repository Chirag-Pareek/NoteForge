import 'package:cloud_firestore/cloud_firestore.dart';

/// Strongly-typed model for a public community feed post.
class CommunityPostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String subjectTag;
  final String content;
  final List<String> likes;
  final DateTime createdAt;

  const CommunityPostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    required this.subjectTag,
    required this.content,
    required this.likes,
    required this.createdAt,
  });

  /// Number of users who liked this post.
  int get likesCount => likes.length;

  /// Checks whether a specific user has liked the post.
  bool isLikedBy(String uid) => likes.contains(uid);

  CommunityPostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorUsername,
    String? subjectTag,
    String? content,
    List<String>? likes,
    DateTime? createdAt,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      subjectTag: subjectTag ?? this.subjectTag,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'subjectTag': subjectTag,
      'content': content,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommunityPostModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final rawLikes = (data['likes'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<String>()
        .toList(growable: false);

    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();

    return CommunityPostModel(
      id: doc.id,
      authorId: (data['authorId'] as String?) ?? '',
      authorName: (data['authorName'] as String?) ?? '',
      authorUsername: (data['authorUsername'] as String?) ?? '',
      subjectTag: (data['subjectTag'] as String?) ?? '',
      content: (data['content'] as String?) ?? '',
      likes: rawLikes,
      createdAt: createdAt,
    );
  }
}
