import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/connection_model.dart';

/// Service that manages social connection requests and friend relationships.
class ConnectionsService {
  ConnectionsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _friendsRef(String uid) {
    return _firestore.collection('connections').doc(uid).collection('friends');
  }

  CollectionReference<Map<String, dynamic>> _requestsRef(String uid) {
    return _firestore.collection('connections').doc(uid).collection('requests');
  }

  /// Sends a connection request from [fromUid] to [toUid].
  ///
  /// Stores request in: `connections/{toUid}/requests/{fromUid}`
  Future<void> sendConnectionRequest({
    required String fromUid,
    required String toUid,
  }) async {
    if (fromUid == toUid) {
      throw Exception('You cannot send a request to yourself.');
    }

    final fromUserRef = _usersRef.doc(fromUid);
    final toUserRef = _usersRef.doc(toUid);
    final requestRef = _requestsRef(toUid).doc(fromUid);
    final fromFriendRef = _friendsRef(fromUid).doc(toUid);
    final toFriendRef = _friendsRef(toUid).doc(fromUid);

    try {
      await _firestore.runTransaction((transaction) async {
        final fromUserSnap = await transaction.get(fromUserRef);
        final toUserSnap = await transaction.get(toUserRef);
        final requestSnap = await transaction.get(requestRef);
        final fromFriendSnap = await transaction.get(fromFriendRef);
        final toFriendSnap = await transaction.get(toFriendRef);

        if (!fromUserSnap.exists || !toUserSnap.exists) {
          throw Exception('User profile does not exist.');
        }

        if (fromFriendSnap.exists || toFriendSnap.exists) {
          throw Exception('You are already connected.');
        }

        if (requestSnap.exists) {
          throw Exception('Connection request already sent.');
        }

        final fromData = fromUserSnap.data() ?? <String, dynamic>{};

        transaction.set(requestRef, {
          'fromUid': fromUid,
          'displayName': (fromData['displayName'] as String?) ?? '',
          'username': (fromData['username'] as String?) ?? '',
          'classOrField': (fromData['classOrField'] as String?) ?? '',
          // Server timestamp keeps request ordering stable across devices.
          'sentAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to send request: ${e.message ?? e.code}');
    }
  }

  /// Accepts an incoming request.
  ///
  /// - Adds each user to the other's `friends` subcollection.
  /// - Removes the incoming request doc.
  Future<void> acceptConnectionRequest({
    required String currentUid,
    required String requestUid,
  }) async {
    final requestRef = _requestsRef(currentUid).doc(requestUid);
    final currentUserRef = _usersRef.doc(currentUid);
    final senderUserRef = _usersRef.doc(requestUid);
    final currentFriendsDocRef = _friendsRef(currentUid).doc(requestUid);
    final senderFriendsDocRef = _friendsRef(requestUid).doc(currentUid);

    try {
      await _firestore.runTransaction((transaction) async {
        final requestSnap = await transaction.get(requestRef);
        if (!requestSnap.exists) {
          throw Exception('Connection request not found.');
        }

        final currentUserSnap = await transaction.get(currentUserRef);
        final senderUserSnap = await transaction.get(senderUserRef);

        if (!currentUserSnap.exists || !senderUserSnap.exists) {
          throw Exception('One or both user profiles are missing.');
        }

        final currentUserData = currentUserSnap.data() ?? <String, dynamic>{};
        final senderUserData = senderUserSnap.data() ?? <String, dynamic>{};

        transaction.set(currentFriendsDocRef, {
          'displayName': (senderUserData['displayName'] as String?) ?? '',
          'username': (senderUserData['username'] as String?) ?? '',
          'classOrField': (senderUserData['classOrField'] as String?) ?? '',
          'connectedAt': FieldValue.serverTimestamp(),
        });

        transaction.set(senderFriendsDocRef, {
          'displayName': (currentUserData['displayName'] as String?) ?? '',
          'username': (currentUserData['username'] as String?) ?? '',
          'classOrField': (currentUserData['classOrField'] as String?) ?? '',
          'connectedAt': FieldValue.serverTimestamp(),
        });

        transaction.delete(requestRef);
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to accept request: ${e.message ?? e.code}');
    }
  }

  /// Rejects an incoming request by deleting it.
  Future<void> rejectConnectionRequest({
    required String currentUid,
    required String requestUid,
  }) async {
    try {
      await _requestsRef(currentUid).doc(requestUid).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to reject request: ${e.message ?? e.code}');
    }
  }

  /// Realtime friends list updates for a user.
  Stream<List<ConnectionFriend>> streamFriends(String uid) {
    return _friendsRef(uid)
        .orderBy('connectedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConnectionFriend.fromDocument)
              .toList(growable: false),
        );
  }

  /// Realtime incoming request updates for a user.
  Stream<List<ConnectionRequest>> streamIncomingRequests(String uid) {
    return _requestsRef(uid)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConnectionRequest.fromDocument)
              .toList(growable: false),
        );
  }

  /// Fetches the current friends list once.
  Future<List<ConnectionFriend>> getFriends(String uid) async {
    try {
      final snapshot = await _friendsRef(
        uid,
      ).orderBy('connectedAt', descending: true).get();

      return snapshot.docs
          .map(ConnectionFriend.fromDocument)
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch friends: ${e.message ?? e.code}');
    }
  }

  /// Fetches incoming requests once.
  Future<List<ConnectionRequest>> getIncomingRequests(String uid) async {
    try {
      final snapshot = await _requestsRef(
        uid,
      ).orderBy('sentAt', descending: true).get();

      return snapshot.docs
          .map(ConnectionRequest.fromDocument)
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch requests: ${e.message ?? e.code}');
    }
  }
}
