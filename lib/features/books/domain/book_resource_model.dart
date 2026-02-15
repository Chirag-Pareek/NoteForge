import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a book/PDF resource.
/// Firestore path: `users/{uid}/books/{id}`
class BookResourceModel {
  final String id;
  final String userId;
  final String subjectId;
  final String title;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final DateTime lastOpenedAt;
  final DateTime uploadedAt;
  final List<String> linkedNoteIds;

  const BookResourceModel({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.title,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.lastOpenedAt,
    required this.uploadedAt,
    required this.linkedNoteIds,
  });

  /// Human-readable file size string.
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  BookResourceModel copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? title,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    DateTime? lastOpenedAt,
    DateTime? uploadedAt,
    List<String>? linkedNoteIds,
  }) {
    return BookResourceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      linkedNoteIds: linkedNoteIds ?? this.linkedNoteIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'subjectId': subjectId,
      'title': title,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'lastOpenedAt': Timestamp.fromDate(lastOpenedAt),
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'linkedNoteIds': linkedNoteIds,
    };
  }

  factory BookResourceModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawLinkedIds =
        (data['linkedNoteIds'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    return BookResourceModel(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      subjectId: (data['subjectId'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      fileName: (data['fileName'] as String?) ?? '',
      fileUrl: (data['fileUrl'] as String?) ?? '',
      fileSize: _toInt(data['fileSize']),
      lastOpenedAt: _toDateTime(data['lastOpenedAt']),
      uploadedAt: _toDateTime(data['uploadedAt']),
      linkedNoteIds: rawLinkedIds,
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
