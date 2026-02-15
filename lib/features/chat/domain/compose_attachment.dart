import 'dart:convert';

import 'package:file_picker/file_picker.dart';

/// Local attachment model for compose flow.
/// This is intentionally storage/upload-agnostic so Firebase upload can be
/// layered later without changing UI code paths.
class ComposeAttachment {
  final String id;
  final String name;
  final String path;
  final int sizeBytes;
  final String extension;

  const ComposeAttachment({
    required this.id,
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.extension,
  });

  factory ComposeAttachment.fromPlatformFile(PlatformFile file) {
    final extension = (file.extension ?? '').toLowerCase();
    return ComposeAttachment(
      id: '${file.path}|${file.name}|${file.size}',
      name: file.name,
      path: file.path ?? '',
      sizeBytes: file.size,
      extension: extension,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'sizeBytes': sizeBytes,
      'extension': extension,
    };
  }

  factory ComposeAttachment.fromJson(Map<String, dynamic> json) {
    return ComposeAttachment(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      extension: json['extension'] as String? ?? '',
    );
  }

  /// Placeholder contract for future Firebase Storage payload mapping.
  Map<String, dynamic> toUploadMetadata() {
    return {
      'localPath': path,
      'fileName': name,
      'sizeBytes': sizeBytes,
      'extension': extension,
    };
  }

  static String encodeList(List<ComposeAttachment> attachments) {
    final data = attachments.map((attachment) => attachment.toJson()).toList();
    return jsonEncode(data);
  }

  static List<ComposeAttachment> decodeList(String jsonString) {
    if (jsonString.trim().isEmpty) {
      return const <ComposeAttachment>[];
    }

    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      return const <ComposeAttachment>[];
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => ComposeAttachment.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((attachment) => attachment.path.isNotEmpty)
        .toList();
  }
}
