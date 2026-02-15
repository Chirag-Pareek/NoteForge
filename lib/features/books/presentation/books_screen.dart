import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../notes/presentation/controllers/notes_controller.dart';
import 'controllers/books_controller.dart';

/// Books & Resources screen with upload and subject categorization.
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksController>().loadBooks();
      context.read<NotesController>().loadSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Scaffold(
      appBar: AppBar(
        title: Text('Books & Resources', style: AppTextStyles.titleMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _uploadBook(context),
        backgroundColor: isDark
            ? AppColorsDark.primaryButton
            : AppColorsLight.primaryButton,
        foregroundColor: isDark ? Colors.black : Colors.white,
        child: const Icon(Icons.upload_file_outlined),
      ),
      body: Consumer<BooksController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading && ctrl.books.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.isUploading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Uploading...', style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }

          if (ctrl.books.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 64,
                    color: secondaryText,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No books yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap the upload button to add PDFs',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: ctrl.books.length,
            separatorBuilder: (_, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final book = ctrl.books[index];
              return InkWell(
                onTap: () {
                  ctrl.openBook(book.id);
                  // In a real app, this would open a PDF viewer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening ${book.title}...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onLongPress: () =>
                    _showDeleteOption(context, book.id, book.fileName),
                borderRadius: AppRadius.mdBorder,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_outlined,
                          color: Color(0xFFEF4444),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${book.fileSizeFormatted} • Last opened ${_formatDate(book.lastOpenedAt)}',
                              style: AppTextStyles.label.copyWith(
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: secondaryText, size: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _uploadBook(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;
    final title = fileName.replaceAll('.pdf', '');

    // Show subject picker
    if (!context.mounted) return;
    final subjects = context.read<NotesController>().subjects;
    String? selectedSubjectId;

    if (subjects.isNotEmpty) {
      selectedSubjectId = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColorsDark.background
            : AppColorsLight.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign to Subject',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...subjects.map(
                (s) => ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(s.name, style: AppTextStyles.bodyMedium),
                  onTap: () => Navigator.pop(ctx, s.id),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: Text('No subject', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(ctx, ''),
              ),
            ],
          ),
        ),
      );
      if (selectedSubjectId == null) return;
    }

    if (!context.mounted) return;
    context.read<BooksController>().uploadBook(
      file: file,
      title: title,
      subjectId: selectedSubjectId ?? '',
      fileName: fileName,
    );
  }

  void _showDeleteOption(BuildContext context, String id, String fileName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? AppColorsDark.background
          : AppColorsLight.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ListTile(
          leading: Icon(
            Icons.delete_outline,
            color: isDark ? AppColorsDark.error : AppColorsLight.error,
          ),
          title: Text(
            'Delete Book',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColorsDark.error : AppColorsLight.error,
            ),
          ),
          onTap: () {
            Navigator.pop(ctx);
            context.read<BooksController>().deleteBook(id, fileName);
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
