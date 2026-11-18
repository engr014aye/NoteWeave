import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/models/category_model.dart';
import '../core/models/note_model.dart';
import '../core/state/notes_provider.dart';
import '../core/state/theme_provider.dart';
import '../core/widgets/empty_state_view.dart';
import '../core/widgets/spring_touch.dart';
import 'note_editor_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final NoteCategory category;
  final NotesProvider notesProvider;
  final ThemeProvider themeProvider;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.notesProvider,
    required this.themeProvider,
  });

  void _confirmDeleteNote(BuildContext context, Note note) {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Delete Note'),
        message: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              notesProvider.deleteNote(note.id);
            },
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final textController = TextEditingController(text: category.name);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Rename Notebook'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: textController,
            autofocus: true,
            placeholder: 'Notebook name',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Save'),
            onPressed: () {
              final newName = textController.text.trim();
              if (newName.isNotEmpty) {
                notesProvider.renameCategory(category.id, newName);
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;
    final bg = AppColors.getBackground(isDark);
    final cardBg = AppColors.getCard(isDark);
    final border = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final textTertiary = AppColors.getTextTertiary(isDark);
    final accent = AppColors.getAccent(isDark);

    return ListenableBuilder(
      listenable: notesProvider,
      builder: (context, _) {
        final categoryNotes = notesProvider.allNotes
            .where((n) => n.category.toLowerCase() == category.name.toLowerCase())
            .toList();

        return Scaffold(
          backgroundColor: bg,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  category.name,
                  style: TextStyle(
                    fontFamily: AppStyles.fontPrimary,
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                backgroundColor: cardBg.withValues(alpha: 0.82),
                border: Border(bottom: BorderSide(color: border, width: 0.8)),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.back, color: accent, size: 24),
                      Text(' Notebooks', style: TextStyle(color: accent)),
                    ],
                  ),
                ),
                trailing: category.isCustom
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _showRenameDialog(context),
                        child: Icon(CupertinoIcons.pencil, color: accent, size: 20),
                      )
                    : null,
              ),
              if (categoryNotes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: CupertinoIcons.doc_text,
                    title: 'No Notes in ${category.name}',
                    message: 'Tap the button below to start writing your first note in this notebook.',
                    buttonLabel: 'Create Note',
                    onButtonPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => NoteEditorScreen(
                            initialCategory: category.name,
                            notesProvider: notesProvider,
                            themeProvider: themeProvider,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final note = categoryNotes[index];
                        return _buildNoteItem(
                          context: context,
                          note: note,
                          isDark: isDark,
                          cardBg: cardBg,
                          border: border,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          textTertiary: textTertiary,
                          accent: accent,
                        );
                      },
                      childCount: categoryNotes.length,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: SpringTouch(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => NoteEditorScreen(
                    initialCategory: category.name,
                    notesProvider: notesProvider,
                    themeProvider: themeProvider,
                  ),
                ),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: category.color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteItem({
    required BuildContext context,
    required Note note,
    required bool isDark,
    required Color cardBg,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color accent,
  }) {
    return Dismissible(
      key: Key('cat_note_${note.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          _confirmDeleteNote(context, note);
          return false;
        } else {
          notesProvider.togglePin(note.id);
          return false;
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          note.isPinned ? CupertinoIcons.pin_slash_fill : CupertinoIcons.pin_fill,
          color: Colors.white,
          size: 22,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          CupertinoIcons.trash_fill,
          color: Colors.white,
          size: 22,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SpringTouch(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => NoteEditorScreen(
                  initialNote: note,
                  notesProvider: notesProvider,
                  themeProvider: themeProvider,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title.trim().isNotEmpty ? note.title : 'Untitled Note',
                        style: AppStyles.titleSmall(textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        CupertinoIcons.pin_fill,
                        size: 15,
                        color: Color(0xFFF59E0B),
                      ),
                    ],
                  ],
                ),
                if (note.content.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note.content.replaceAll(RegExp(r'[#*•>_-]'), '').trim(),
                    style: AppStyles.bodyMedium(textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy').format(note.updatedAt),
                      style: AppStyles.bodySmall(textTertiary),
                    ),
                    const Spacer(),
                    if (note.tags.isNotEmpty)
                      Row(
                        children: note.tags.take(2).map((t) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              '#$t',
                              style: AppStyles.bodySmall(accent),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
