import 'package:cloud_firestore/cloud_firestore.dart';

/// Strongly-typed model for study challenges.
class ChallengeModel {
  final String id;
  final String title;
  final String createdBy;
  final List<String> participants;
  final Map<String, double> scores;
  final DateTime startDate;
  final DateTime endDate;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.participants,
    required this.scores,
    required this.startDate,
    required this.endDate,
  });

  bool get isActive {
    final now = DateTime.now();
    return !now.isBefore(startDate) && !now.isAfter(endDate);
  }

  bool get hasEnded => DateTime.now().isAfter(endDate);

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? createdBy,
    List<String>? participants,
    Map<String, double>? scores,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdBy: createdBy ?? this.createdBy,
      participants: participants ?? this.participants,
      scores: scores ?? this.scores,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Returns sorted scores in descending order.
  List<ChallengeScore> get sortedScores {
    final list = scores.entries
        .map((entry) => ChallengeScore(uid: entry.key, score: entry.value))
        .toList();

    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdBy': createdBy,
      'participants': participants,
      'scores': scores,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }

  factory ChallengeModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final participants =
        (data['participants'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<String>()
            .toList(growable: false);

    final rawScores =
        (data['scores'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final scores = <String, double>{};
    for (final entry in rawScores.entries) {
      final value = entry.value;
      if (value is num) {
        scores[entry.key] = value.toDouble();
      }
    }

    final startRaw = data['startDate'];
    final endRaw = data['endDate'];

    return ChallengeModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
      participants: participants,
      scores: scores,
      startDate: startRaw is Timestamp ? startRaw.toDate() : DateTime.now(),
      endDate: endRaw is Timestamp ? endRaw.toDate() : DateTime.now(),
    );
  }
}

class ChallengeScore {
  final String uid;
  final double score;

  const ChallengeScore({required this.uid, required this.score});
}

class ChallengeWinner {
  final String uid;
  final double score;
  final bool isTie;

  const ChallengeWinner({
    required this.uid,
    required this.score,
    required this.isTie,
  });
}
