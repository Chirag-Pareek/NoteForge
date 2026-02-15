import 'package:flutter/material.dart';
import 'package:noteforge/features/home/presentation/edit_profile_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/notes/presentation/subjects_screen.dart';
import '../../features/notes/presentation/chapters_screen.dart';
import '../../features/notes/presentation/topics_screen.dart';
import '../../features/notes/presentation/notes_list_screen.dart';
import '../../features/notes/presentation/note_editor_screen.dart';
import '../../features/practice/presentation/practice_select_screen.dart';
import '../../features/practice/presentation/practice_chapters_screen.dart';
import '../../features/practice/presentation/practice_session_screen.dart';
import '../../features/practice/presentation/practice_results_screen.dart';
import '../../features/practice/presentation/practice_history_screen.dart';
import '../../features/books/presentation/books_screen.dart';
import '../../features/study_plan/presentation/study_plan_screen.dart';
import '../navigation/main_shell.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    switch (settings.name) {

      // 🔥 ROOT ROUTE
      case '/':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case AppRoutes.profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainShell());

      case AppRoutes.profilEdit:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      // ── Notes Workspace ──
      case AppRoutes.subjects:
        return MaterialPageRoute(builder: (_) => const SubjectsScreen());

      case AppRoutes.chapters:
        return MaterialPageRoute(
          builder: (_) => ChaptersScreen(
            subjectId: args['subjectId'] as String,
            subjectName: args['subjectName'] as String,
          ),
        );

      case AppRoutes.topics:
        return MaterialPageRoute(
          builder: (_) => TopicsScreen(
            chapterId: args['chapterId'] as String,
            subjectId: args['subjectId'] as String,
            chapterName: args['chapterName'] as String,
          ),
        );

      case AppRoutes.notesList:
        return MaterialPageRoute(
          builder: (_) => NotesListScreen(
            topicId: args['topicId'] as String,
            chapterId: args['chapterId'] as String,
            subjectId: args['subjectId'] as String,
            topicName: args['topicName'] as String,
          ),
        );

      case AppRoutes.noteEditor:
        return MaterialPageRoute(
          builder: (_) => NoteEditorScreen(
            noteId: args['noteId'] as String,
            initialTitle: args['title'] as String? ?? '',
            initialContent: args['content'] as String? ?? '',
            topicId: args['topicId'] as String? ?? '',
            chapterId: args['chapterId'] as String? ?? '',
            subjectId: args['subjectId'] as String? ?? '',
          ),
        );

      // ── Practice Engine ──
      case AppRoutes.practiceSelect:
        return MaterialPageRoute(
            builder: (_) => const PracticeSelectScreen());

      case AppRoutes.practiceChapters:
        return MaterialPageRoute(
          builder: (_) => PracticeChaptersScreen(
            subjectId: args['subjectId'] as String,
            subjectName: args['subjectName'] as String,
          ),
        );

      case AppRoutes.practiceSession:
        return MaterialPageRoute(
          builder: (_) => PracticeSessionScreen(
            chapterId: args['chapterId'] as String,
            subjectId: args['subjectId'] as String,
            chapterName: args['chapterName'] as String,
          ),
        );

      case AppRoutes.practiceResults:
        return MaterialPageRoute(
          builder: (_) => PracticeResultsScreen(
            sessionId: args['sessionId'] as String,
            correct: args['correct'] as int,
            total: args['total'] as int,
            accuracy: args['accuracy'] as double,
            weakTopics: List<String>.from(args['weakTopics'] ?? []),
          ),
        );

      case AppRoutes.practiceHistory:
        return MaterialPageRoute(
            builder: (_) => const PracticeHistoryScreen());

      // ── Books & Resources ──
      case AppRoutes.books:
        return MaterialPageRoute(builder: (_) => const BooksScreen());

      // ── Smart Study ──
      case AppRoutes.studyPlan:
        return MaterialPageRoute(builder: (_) => const StudyPlanScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
