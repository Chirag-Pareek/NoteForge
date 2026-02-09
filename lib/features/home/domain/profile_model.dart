import 'package:cloud_firestore/cloud_firestore.dart';

/// Strongly-typed user profile model for `users/{uid}`.
class ProfileModel {
  final String uid;
  final String displayName;
  final String username;
  final String classOrField;
  final String email;
  final String? photoUrl;
  final int streak;
  final double performanceScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Optional extra profile fields not part of the fixed schema.
  final Map<String, dynamic> extras;

  const ProfileModel({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.classOrField,
    required this.email,
    required this.photoUrl,
    required this.streak,
    required this.performanceScore,
    required this.createdAt,
    required this.updatedAt,
    this.extras = const <String, dynamic>{},
  });

  ProfileModel copyWith({
    String? uid,
    String? displayName,
    String? username,
    String? classOrField,
    String? email,
    String? photoUrl,
    bool clearPhotoUrl = false,
    int? streak,
    double? performanceScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? extras,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      classOrField: classOrField ?? this.classOrField,
      email: email ?? this.email,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      streak: streak ?? this.streak,
      performanceScore: performanceScore ?? this.performanceScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      extras: extras ?? this.extras,
    );
  }

  Map<String, dynamic> toMap({
    bool includeTimestamps = true,
    bool includeStats = true,
  }) {
    final map = <String, dynamic>{
      'displayName': displayName,
      'username': username,
      'classOrField': classOrField,
      'email': email,
      'photoUrl': photoUrl,
      ...extras,
    };

    if (includeStats) {
      map['streak'] = streak;
      map['performanceScore'] = performanceScore;
    }

    if (includeTimestamps) {
      map['updatedAt'] = FieldValue.serverTimestamp();
    }

    return map;
  }

  factory ProfileModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final fixedKeys = <String>{
      'displayName',
      'username',
      'classOrField',
      'email',
      'photoUrl',
      'streak',
      'performanceScore',
      'createdAt',
      'updatedAt',
    };

    final extras = <String, dynamic>{};
    for (final entry in data.entries) {
      if (!fixedKeys.contains(entry.key)) {
        extras[entry.key] = entry.value;
      }
    }

    return ProfileModel(
      uid: doc.id,
      displayName: (data['displayName'] as String?) ?? '',
      username: (data['username'] as String?) ?? '',
      classOrField: (data['classOrField'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      streak: _toInt(data['streak']),
      performanceScore: _toDouble(data['performanceScore']),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      extras: extras,
    );
  }

  static String normalizeUsername(String username) {
    return username.trim().toLowerCase();
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}
