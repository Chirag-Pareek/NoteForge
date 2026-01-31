import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/route_generator.dart';

class MainNavigator extends StatelessWidget {
  const MainNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: AppRoutes.home,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
