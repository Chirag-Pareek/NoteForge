import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/route_generator.dart';

class AuthNavigator extends StatelessWidget {
  const AuthNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
