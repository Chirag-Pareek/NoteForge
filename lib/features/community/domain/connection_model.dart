import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a connection friend under:
/// `connections/{uid}/friends/{friendUid}`
class ConnectionFriend {
  final String uid;
  final String displayName;
  final String username;
  final String classOrField;
  final DateTime connectedAt;

  const ConnectionFriend({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.classOrField,
    required this.connectedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'username': username,
      'classOrField': classOrField,
      'connectedAt': Timestamp.fromDate(connectedAt),
    };
  }

  factory ConnectionFriend.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final connectedAtRaw = data['connectedAt'];

    return ConnectionFriend(
      uid: doc.id,
      displayName: (data['displayName'] as String?) ?? '',
      username: (data['username'] as String?) ?? '',
      classOrField: (data['classOrField'] as String?) ?? '',
      connectedAt: connectedAtRaw is Timestamp
          ? connectedAtRaw.toDate()
          : DateTime.now(),
    );
  }
}

/// Model for an incoming connection request under:
/// `connections/{uid}/requests/{requestUid}`
///
/// In this implementation, `requestUid` is the sender uid.
class ConnectionRequest {
  final String requestUid;
  final String fromUid;
  final String displayName;
  final String username;
  final String classOrField;
  final DateTime sentAt;

  const ConnectionRequest({
    required this.requestUid,
    required this.fromUid,
    required this.displayName,
    required this.username,
    required this.classOrField,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'displayName': displayName,
      'username': username,
      'classOrField': classOrField,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }

  factory ConnectionRequest.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final sentAtRaw = data['sentAt'];

    return ConnectionRequest(
      requestUid: doc.id,
      fromUid: (data['fromUid'] as String?) ?? doc.id,
      displayName: (data['displayName'] as String?) ?? '',
      username: (data['username'] as String?) ?? '',
      classOrField: (data['classOrField'] as String?) ?? '',
      sentAt: sentAtRaw is Timestamp ? sentAtRaw.toDate() : DateTime.now(),
    );
  }
}
