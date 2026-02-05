import 'package:flutter/material.dart';
import 'package:noteforge/features/community/presentation/connections_screen.dart';

/// Deprecated: use ConnectionsScreen.
@Deprecated('Use ConnectionsScreen instead.')
class FriendsScreen extends StatelessWidget {
  final double topPadding;

  const FriendsScreen({
    super.key,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ConnectionsScreen(topPadding: topPadding);
  }
}
