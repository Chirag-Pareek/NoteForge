import 'package:cloud_firestore/cloud_firestore.dart';

/// Strongly-typed user profile model for `users/{uid}`.
class ProfileModel {
  final String uid;
  final String displayName;
  final String username;
  final String bio;
  final String school;
  final String grade;
  final String photoUrl;
  final DateTime? updatedAt;

  const ProfileModel({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.bio,
    required this.school,
    required this.grade,
    required this.photoUrl,
    required this.updatedAt,
  });

  ProfileModel copyWith({
    String? uid,
    String? displayName,
    String? username,
    String? bio,
    String? school,
    String? grade,
    String? photoUrl,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      school: school ?? this.school,
      grade: grade ?? this.grade,
      photoUrl: photoUrl ?? this.photoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this profile into a Firestore-friendly JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'displayName': displayName,
      'username': username,
      'bio': bio,
      'school': school,
      'grade': grade,
      'photoUrl': photoUrl,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Builds a [ProfileModel] from Firestore JSON.
  factory ProfileModel.fromJson(String uid, Map<String, dynamic> json) {
    return ProfileModel(
      uid: uid,
      displayName: (json['displayName'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      bio: (json['bio'] as String?) ?? '',
      school: (json['school'] as String?) ?? '',
      grade: (json['grade'] as String?) ?? '',
      photoUrl: (json['photoUrl'] as String?) ?? '',
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  /// Normalizes usernames for case-insensitive uniqueness checks.
  static String normalizeUsername(String username) {
    return username.trim().toLowerCase();
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
