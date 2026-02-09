import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/challenge_model.dart';

/// Repository for challenge lifecycle and realtime challenge data.
class ChallengeRepository {
  ChallengeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _challengesRef =>
      _firestore.collection('challenges');

  /// Creates a challenge and returns the new challenge id.
  Future<String> createChallenge({
    required String title,
    required String createdBy,
    required DateTime startDate,
    required DateTime endDate,
    List<String> participants = const <String>[],
  }) async {
    if (title.trim().isEmpty) {
      throw Exception('Challenge title is required.');
    }

    if (endDate.isBefore(startDate)) {
      throw Exception('Challenge end date must be after start date.');
    }

    final uniqueParticipants = <String>{...participants, createdBy}.toList();

    try {
      final docRef = _challengesRef.doc();
      await docRef.set({
        'title': title.trim(),
        'createdBy': createdBy,
        'participants': uniqueParticipants,
        'scores': <String, double>{},
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
      });

      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create challenge: ${e.message ?? e.code}');
    }
  }

  /// Adds a participant to an existing challenge.
  Future<void> joinChallenge({
    required String challengeId,
    required String uid,
  }) async {
    try {
      await _challengesRef.doc(challengeId).update({
        'participants': FieldValue.arrayUnion(<String>[uid]),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to join challenge: ${e.message ?? e.code}');
    }
  }

  /// Submits or updates a user's challenge score.
  Future<void> submitResult({
    required String challengeId,
    required String uid,
    required num score,
  }) async {
    final challengeRef = _challengesRef.doc(challengeId);

    try {
      await _firestore.runTransaction((transaction) async {
        final challengeSnap = await transaction.get(challengeRef);
        if (!challengeSnap.exists) {
          throw Exception('Challenge not found.');
        }

        final challenge = ChallengeModel.fromDocument(challengeSnap);
        final now = DateTime.now();

        if (now.isBefore(challenge.startDate)) {
          throw Exception('Challenge has not started yet.');
        }

        if (now.isAfter(challenge.endDate)) {
          throw Exception('Challenge has ended.');
        }

        if (!challenge.participants.contains(uid)) {
          throw Exception('Only participants can submit a result.');
        }

        transaction.update(challengeRef, {'scores.$uid': score.toDouble()});
      });
    } on FirebaseException catch (e) {
      throw Exception(
        'Failed to submit challenge result: ${e.message ?? e.code}',
      );
    }
  }

  /// Returns sorted scores (highest first).
  Future<List<ChallengeScore>> compareScores(String challengeId) async {
    final challenge = await getChallenge(challengeId);
    if (challenge == null) {
      throw Exception('Challenge not found.');
    }

    return challenge.sortedScores;
  }

  /// Determines current winner from submitted scores.
  ///
  /// When top scores are tied, [ChallengeWinner.isTie] is true.
  Future<ChallengeWinner?> determineWinner(String challengeId) async {
    final sortedScores = await compareScores(challengeId);
    if (sortedScores.isEmpty) {
      return null;
    }

    final top = sortedScores.first;
    final tieCount = sortedScores
        .where((score) => score.score == top.score)
        .length;

    return ChallengeWinner(uid: top.uid, score: top.score, isTie: tieCount > 1);
  }

  /// Reads one challenge document once.
  Future<ChallengeModel?> getChallenge(String challengeId) async {
    try {
      final snapshot = await _challengesRef.doc(challengeId).get();
      if (!snapshot.exists) {
        return null;
      }

      return ChallengeModel.fromDocument(snapshot);
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch challenge: ${e.message ?? e.code}');
    }
  }

  /// Realtime updates for a single challenge.
  Stream<ChallengeModel?> streamChallenge(String challengeId) {
    return _challengesRef.doc(challengeId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return ChallengeModel.fromDocument(snapshot);
    });
  }

  /// Realtime updates for challenges that include [uid] as a participant.
  Stream<List<ChallengeModel>> streamChallengesForUser(
    String uid, {
    bool includeEnded = true,
  }) {
    return _challengesRef
        .where('participants', arrayContains: uid)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
          var challenges = snapshot.docs
              .map(ChallengeModel.fromDocument)
              .toList(growable: false);

          if (!includeEnded) {
            challenges = challenges
                .where((challenge) => !challenge.hasEnded)
                .toList(growable: false);
          }

          return challenges;
        });
  }
}
