import 'package:flutter/material.dart';
import 'package:noteforge/features/community/presentation/widgets/connection_tile.dart';

/// Deprecated: use ConnectionTile for global connections.
@Deprecated('Use ConnectionTile instead.')
class FriendTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool isOnline;
  final bool isRequest;

  const FriendTile({
    super.key,
    required this.name,
    required this.subtitle,
    this.isOnline = false,
    this.isRequest = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConnectionTile(
      name: name,
      field: subtitle,
      username: _usernameFromName(name),
    );
  }

  String _usernameFromName(String value) {
    return value.toLowerCase().replaceAll(' ', '.');
  }
}
