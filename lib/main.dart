import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/route_generator.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/home/presentation/controllers/profile_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (OpenAI key etc.)
  await dotenv.load();

  // Initialize Firebase safely
  await Firebase.initializeApp();

  // Provide profile controller globally so profile and edit profile screens
  // can share realtime profile state and update actions.
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteForge',
      debugShowCheckedModeBanner: false,

      // ✅ Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ✅ AuthGate decides where user goes
      home: const AuthGate(),

      // ✅ Keep your route generator
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
