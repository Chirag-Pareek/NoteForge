import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/challenge_repository.dart';
import '../domain/challenge_model.dart';

/// Backend controller for challenge state + realtime subscriptions.
///
/// No UI logic is included. UI can listen to this controller via Provider,
/// Riverpod adapters, or direct ChangeNotifier listeners.
class ChallengeController extends ChangeNotifier {
  ChallengeController({ChallengeRepository? repository})
    : _repository = repository ?? ChallengeRepository();

  final ChallengeRepository _repository;

  StreamSubscription<List<ChallengeModel>>? _userChallengesSub;
  StreamSubscription<ChallengeModel?>? _selectedChallengeSub;

  bool _isLoading = false;
  String? _errorMessage;
  List<ChallengeModel> _userChallenges = const <ChallengeModel>[];
  ChallengeModel? _selectedChallenge;
  ChallengeWinner? _winner;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ChallengeModel> get userChallenges => _userChallenges;
  ChallengeModel? get selectedChallenge => _selectedChallenge;
  ChallengeWinner? get winner => _winner;

  /// Starts realtime listener for all challenges for a user.
  Future<void> watchUserChallenges(
    String uid, {
    bool includeEnded = true,
  }) async {
    _setLoading(true);
    _clearError(notify: false);

    await _userChallengesSub?.cancel();

    _userChallengesSub = _repository
        .streamChallengesForUser(uid, includeEnded: includeEnded)
        .listen(
          (challenges) {
            _userChallenges = challenges;
            _setLoading(false);
          },
          onError: (Object error) {
            _setError(error.toString());
          },
        );
  }

  /// Starts realtime listener for a single challenge.
  Future<void> watchChallenge(String challengeId) async {
    _setLoading(true);
    _clearError(notify: false);

    await _selectedChallengeSub?.cancel();

    _selectedChallengeSub = _repository
        .streamChallenge(challengeId)
        .listen(
          (challenge) {
            _selectedChallenge = challenge;
            _setLoading(false);
          },
          onError: (Object error) {
            _setError(error.toString());
          },
        );
  }

  Future<String?> createChallenge({
    required String title,
    required String createdBy,
    required DateTime startDate,
    required DateTime endDate,
    List<String> participants = const <String>[],
  }) async {
    _setLoading(true);
    _clearError(notify: false);

    try {
      final challengeId = await _repository.createChallenge(
        title: title,
        createdBy: createdBy,
        startDate: startDate,
        endDate: endDate,
        participants: participants,
      );

      _setLoading(false);
      return challengeId;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<void> joinChallenge({
    required String challengeId,
    required String uid,
  }) async {
    _setLoading(true);
    _clearError(notify: false);

    try {
      await _repository.joinChallenge(challengeId: challengeId, uid: uid);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> submitResult({
    required String challengeId,
    required String uid,
    required num score,
  }) async {
    _setLoading(true);
    _clearError(notify: false);

    try {
      await _repository.submitResult(
        challengeId: challengeId,
        uid: uid,
        score: score,
      );
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> refreshWinner(String challengeId) async {
    _clearError(notify: false);

    try {
      _winner = await _repository.determineWinner(challengeId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearError() {
    _clearError(notify: true);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError({required bool notify}) {
    _errorMessage = null;
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userChallengesSub?.cancel();
    _selectedChallengeSub?.cancel();
    super.dispose();
  }
}
