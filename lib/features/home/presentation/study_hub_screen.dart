import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_outlined_button.dart';
import '../../notes/domain/note_model.dart';
import '../../notes/presentation/controllers/notes_controller.dart';
import 'widgets/note_list_card.dart';
import 'widgets/smart_action_card.dart';

/// Study hub surface with responsive layout for phone and tablet.
class StudyHubScreen extends StatefulWidget {
  const StudyHubScreen({super.key});

  @override
  State<StudyHubScreen> createState() => _StudyHubScreenState();
}

class _StudyHubScreenState extends State<StudyHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!mounted) {
        return;
      }

      if (!_searchFocusNode.hasFocus &&
          _searchQuery.trim().isEmpty &&
          _isSearchMode) {
        setState(() {
          _isSearchMode = false;
        });
        return;
      }

      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesController>().loadRecentNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isTablet = !AppBreakpoints.isMobile(width);
        final horizontalPadding = AppBreakpoints.pageHorizontalPadding(width);
        final contentWidth = AppBreakpoints.pageMaxContentWidth(width);
        final actionCardAspectRatio = AppBreakpoints.isDesktop(width)
            ? 1.1
            : isTablet
            ? 1.0
            : 0.92;
        final sectionTitleStyle = AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
        );
        final isSearching =
            _isSearchMode ||
            _searchFocusNode.hasFocus ||
            _searchQuery.trim().isNotEmpty;

        final smartActions = <_StudyAction>[
          _StudyAction(
            icon: Icons.youtube_searched_for_outlined,
            label: 'Search YT',
            onTap: () => Navigator.pushNamed(context, AppRoutes.studyPlan),
          ),
          _StudyAction(
            icon: Icons.lightbulb_outline,
            label: 'Solve Notes',
            onTap: () => Navigator.pushNamed(context, AppRoutes.subjects),
          ),
          _StudyAction(
            icon: Icons.note_add_outlined,
            label: 'Create Notes',
            onTap: () => Navigator.pushNamed(context, AppRoutes.subjects),
          ),
          _StudyAction(
            icon: Icons.quiz_outlined,
            label: 'MCQs',
            onTap: () => Navigator.pushNamed(context, AppRoutes.practiceSelect),
          ),
          _StudyAction(
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDFs',
            onTap: () => Navigator.pushNamed(context, AppRoutes.books),
          ),
          _StudyAction(
            icon: Icons.menu_book_outlined,
            label: 'Books',
            onTap: () => Navigator.pushNamed(context, AppRoutes.books),
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: const SizedBox(),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              'Study Hub',
              style:
                  (isTablet
                          ? AppTextStyles.titleLarge
                          : AppTextStyles.titleMedium)
                      .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () {
                            if (!_isSearchMode) {
                              setState(() {
                                _isSearchMode = true;
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  _searchFocusNode.requestFocus();
                                }
                              });
                              return;
                            }
                            if (!_searchFocusNode.hasFocus) {
                              _searchFocusNode.requestFocus();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet
                                  ? AppSpacing.xl
                                  : AppSpacing.lg,
                              vertical: isTablet
                                  ? AppSpacing.lg
                                  : AppSpacing.lg,
                            ),
                            decoration: BoxDecoration(
                              color: lightBg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: borderColor),
                              boxShadow: AppEffects.subtleDepth(
                                Theme.of(context).brightness,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: isTablet ? 22 : 20,
                                  color: secondaryText,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    switchInCurve: Curves.easeOut,
                                    switchOutCurve: Curves.easeIn,
                                    child: isSearching
                                        ? TextField(
                                            key: const ValueKey<String>(
                                              'studyhub-search-input',
                                            ),
                                            controller: _searchController,
                                            focusNode: _searchFocusNode,
                                            onChanged: (value) {
                                              setState(() {
                                                _searchQuery = value;
                                              });
                                            },
                                            style:
                                                (isTablet
                                                        ? AppTextStyles
                                                              .bodyLarge
                                                        : AppTextStyles
                                                              .bodyMedium)
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color,
                                                    ),
                                            cursorColor: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                            decoration:
                                                InputDecoration.collapsed(
                                                  hintText: 'Search...',
                                                  hintStyle:
                                                      (isTablet
                                                              ? AppTextStyles
                                                                    .bodyLarge
                                                              : AppTextStyles
                                                                    .bodyMedium)
                                                          .copyWith(
                                                            color:
                                                                secondaryText,
                                                          ),
                                                ),
                                          )
                                        : _StudyHubSearchHintText(
                                            key: const ValueKey<String>(
                                              'studyhub-search-hint',
                                            ),
                                            isTablet: isTablet,
                                            color: secondaryText,
                                          ),
                                  ),
                                ),
                                if (isSearching)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                        _isSearchMode = false;
                                      });
                                      _searchFocusNode.unfocus();
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: isTablet ? 20 : 18,
                                      color: secondaryText,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    splashRadius: 18,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      Text('Smart Actions', style: sectionTitleStyle),
                      const SizedBox(height: AppSpacing.md),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: actionCardAspectRatio,
                        children: smartActions
                            .map(
                              (action) => SmartActionCard(
                                icon: action.icon,
                                label: action.label,
                                onTap: action.onTap,
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      Row(
                        children: [
                          Text('My Notes', style: sectionTitleStyle),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.subjects,
                            ),
                            child: Text(
                              'See all',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Consumer<NotesController>(
                        builder: (context, ctrl, _) {
                          final query = _searchQuery.trim().toLowerCase();
                          final filteredNotes = ctrl.recentNotes.where((note) {
                            if (query.isEmpty) {
                              return true;
                            }
                            final title = note.title.toLowerCase();
                            final content = note.content.toLowerCase();
                            return title.contains(query) ||
                                content.contains(query);
                          }).toList();

                          final visibleNotes = query.isEmpty
                              ? filteredNotes.take(2).toList()
                              : filteredNotes;
                          if (visibleNotes.isEmpty) {
                            return NoteListCard(
                              title: query.isEmpty
                                  ? 'No notes yet'
                                  : 'No matching notes',
                              subtitle: query.isEmpty
                                  ? 'Start by generating your first note'
                                  : 'Try another search term',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.subjects,
                              ),
                            );
                          }

                          return Column(
                            children: visibleNotes.map((note) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: NoteListCard(
                                  title: _subjectTopicTitle(note),
                                  subtitle:
                                      'Updated ${_formatRelativeTime(note.updatedAt)}',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.noteEditor,
                                      arguments: {
                                        'noteId': note.id,
                                        'title': note.title,
                                        'content': note.content,
                                        'topicId': note.topicId,
                                        'chapterId': note.chapterId,
                                        'subjectId': note.subjectId,
                                      },
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      AppOutlinedButton(
                        label: 'Generate New Note',
                        isFullWidth: true,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.subjects),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      Text('Practice Zone', style: sectionTitleStyle),
                      const SizedBox(height: AppSpacing.md),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: actionCardAspectRatio * 1.08,
                        children: [
                          Align(
                            child: FractionallySizedBox(
                              widthFactor: 0.94,
                              heightFactor: 0.92,
                              child: SmartActionCard(
                                icon: Icons.quiz_outlined,
                                label: 'MCQs',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.practiceSelect,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            child: FractionallySizedBox(
                              widthFactor: 0.94,
                              heightFactor: 0.92,
                              child: SmartActionCard(
                                icon: Icons.edit_outlined,
                                label: 'Fill Blanks',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.practiceSelect,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      Text('Smart Study Tools', style: sectionTitleStyle),
                      const SizedBox(height: AppSpacing.md),

                      NoteListCard(
                        title: 'AI Study Plan',
                        subtitle: 'Personalized schedule',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.studyPlan),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      NoteListCard(
                        title: 'Revision Mode',
                        subtitle: 'Smart spaced repetition',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.studyPlan),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _subjectTopicTitle(NoteModel note) {
    final raw = note.title.trim();
    if (raw.isEmpty) {
      return 'Subject - Topic';
    }

    if (raw.contains('-')) {
      final parts = raw
          .split('-')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.length >= 2) {
        return '${parts.first} - ${parts.sublist(1).join(' - ')}';
      }
    }

    return raw;
  }

  String _formatRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) {
      return 'just now';
    }
    if (diff.inHours < 1) {
      final minutes = diff.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inDays < 1) {
      final hours = diff.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      final days = diff.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }

    final years = (diff.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }
}

class _StudyAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _StudyAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _StudyHubSearchHintText extends StatefulWidget {
  final bool isTablet;
  final Color color;

  const _StudyHubSearchHintText({
    super.key,
    required this.isTablet,
    required this.color,
  });

  @override
  State<_StudyHubSearchHintText> createState() =>
      _StudyHubSearchHintTextState();
}

class _StudyHubSearchHintTextState extends State<_StudyHubSearchHintText> {
  static const List<String> _phrases = [
    'Search any notes...',
    'Search any chapters...',
    'Search any PDFs...',
    'Seach any MCQs..',
  ];

  int _phraseIndex = 0;
  int _charIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 70), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        final phrase = _phrases[_phraseIndex];
        if (_charIndex < phrase.length) {
          _charIndex++;
        } else {
          _timer?.cancel();
          Future.delayed(const Duration(milliseconds: 700), () {
            if (!mounted) {
              return;
            }
            setState(() {
              _charIndex = 0;
              _phraseIndex = (_phraseIndex + 1) % _phrases.length;
            });
            _startTyping();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final phrase = _phrases[_phraseIndex];
    final visibleText = phrase.substring(0, _charIndex);

    return Text(
      visibleText,
      style:
          (widget.isTablet ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium)
              .copyWith(color: widget.color),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
