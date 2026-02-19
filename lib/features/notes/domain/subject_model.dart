import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a study subject.
/// Firestore path: `users/{uid}/subjects/{id}`
class SubjectModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final int chaptersCount;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubjectModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.chaptersCount,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  SubjectModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    int? chaptersCount,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      chaptersCount: chaptersCount ?? this.chaptersCount,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'chaptersCount': chaptersCount,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory SubjectModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return SubjectModel(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      chaptersCount: _toInt(data['chaptersCount']),
      color: (data['color'] as String?) ?? '0xFF6B7280',
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
