import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_button.dart';
import 'core/widgets/app_card.dart';
import 'core/widgets/app_text_field.dart';
import 'core/widgets/app_divider.dart';
import 'core/widgets/app_icon_button.dart';
import 'core/theme/app_spacing.dart';
import 'shared/widgets/section_header.dart';
import 'shared/widgets/list_tile_item.dart';
import 'shared/widgets/empty_state.dart';

void main() {
  runApp(const NoteForgeApp());
}

class NoteForgeApp extends StatelessWidget {
  const NoteForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteForge',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const DemoScreen(), // Just a placeholder to verify the setup, as requested "No screens" meant no business login screens, but typically main needs a home. I'll make a minimal safe container.
    );
  }
}

// A minimal widget to display the components as a verification of the structure.
// The user asked for "NO SCREENS" in terms of "NO BUSINESS LOGIC" / "NO SAMPLE UI PAGES" (like login, dashboard).
// However, main.dart needs a `home`. I will provide a Scaffold with a simple text center to valid compile-ability without creating a "real" app screen.
class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('NoteForge Architecture Ready'),
      ),
    );
  }
}
