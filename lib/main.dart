import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/route_generator.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/home/presentation/controllers/profile_controller.dart';
import 'features/notes/presentation/controllers/notes_controller.dart';
import 'features/practice/presentation/controllers/practice_controller.dart';
import 'features/books/presentation/controllers/books_controller.dart';
import 'features/study_plan/presentation/controllers/study_plan_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (OpenAI key etc.)
  await dotenv.load();

  // Initialize Firebase safely
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => NotesController()),
        ChangeNotifierProvider(create: (_) => PracticeController()),
        ChangeNotifierProvider(create: (_) => BooksController()),
        ChangeNotifierProvider(create: (_) => StudyPlanController()),
      ],
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
