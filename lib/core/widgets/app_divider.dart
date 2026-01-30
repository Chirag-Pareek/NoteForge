import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    // DividerTheme is already configured in AppTheme to use the correct border color
    return const Divider(height: 1);
  }
}
