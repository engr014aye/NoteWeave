import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/models/note_model.dart';
import '../core/state/notes_provider.dart';
import '../core/state/theme_provider.dart';
import '../core/widgets/cupertino_search_bar.dart';
import '../core/widgets/empty_state_view.dart';
import '../core/widgets/spring_touch.dart';
import 'note_editor_screen.dart';

class NotesTab extends StatefulWidget {
  final NotesProvider notesProvider;
  final ThemeProvider themeProvider;

  const NotesTab({
    super.key,
    required this.notesProvider,
    required this.themeProvider,
  });

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              widget.notesProvider.deleteNote(note.id);
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

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeProvider.isDarkMode;
    final bg = AppColors.getBackground(isDark);
    final cardBg = AppColors.getCard(isDark);
    final border = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final textTertiary = AppColors.getTextTertiary(isDark);
    final accent = AppColors.getAccent(isDark);

    return ListenableBuilder(
      listenable: widget.notesProvider,
      builder: (context, _) {
        final pinnedNotes = widget.notesProvider.pinnedNotes;
        final unpinnedNotes = widget.notesProvider.unpinnedNotes;
        final allFiltered = widget.notesProvider.filteredNotes;
        final categories = widget.notesProvider.categories;

        return Scaffold(
          backgroundColor: bg,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  'NoteWeave',
                  style: TextStyle(
                    fontFamily: AppStyles.fontPrimary,
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                backgroundColor: cardBg.withValues(alpha: 0.82),
                border: Border(bottom: BorderSide(color: border, width: 0.8)),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CupertinoSearchBarWidget(
                    controller: _searchController,
                    onChanged: (q) => widget.notesProvider.setSearchQuery(q),
                    onClear: () => widget.notesProvider.setSearchQuery(''),
                  ),
                ),
              ),

              // Horizontal Bouncing Category Filter Pills
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final catName = isAll ? 'All' : categories[index - 1].name;
                      final isSelected = isAll
                          ? (widget.notesProvider.selectedCategoryFilter == null ||
                              widget.notesProvider.selectedCategoryFilter == 'All')
                          : (widget.notesProvider.selectedCategoryFilter?.toLowerCase() ==
                              catName.toLowerCase());

                      final pillColor = isAll
                          ? accent
                          : categories[index - 1].color;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SpringTouch(
                          onTap: () {
                            widget.notesProvider.setCategoryFilter(isAll ? null : catName);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? pillColor
                                  : (isDark ? const Color(0xFF1B2230) : const Color(0xFFEEF0F5)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? pillColor
                                    : border.withValues(alpha: 0.6),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isAll) ...[
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : pillColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  catName,
                                  style: TextStyle(
                                    fontFamily: AppStyles.fontPrimary,
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? Colors.white : textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              if (allFiltered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: CupertinoIcons.doc_text_search,
                    title: widget.notesProvider.searchQuery.isNotEmpty
                        ? 'No Notes Found'
                        : 'No Notes Yet',
                    message: widget.notesProvider.searchQuery.isNotEmpty
                        ? 'No notes match "${widget.notesProvider.searchQuery}". Try a different keyword.'
                        : 'Capture your thoughts, plans, and ideas with effortless speed.',
                    buttonLabel: widget.notesProvider.searchQuery.isEmpty ? 'Write First Note' : null,
                    onButtonPressed: widget.notesProvider.searchQuery.isEmpty
                        ? () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => NoteEditorScreen(
                                  notesProvider: widget.notesProvider,
                                  themeProvider: widget.themeProvider,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                )
              else ...[
                // Pinned Section
                if (pinnedNotes.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.pin_fill,
                            size: 13,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PINNED',
                            style: TextStyle(
                              fontFamily: AppStyles.fontPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final note = pinnedNotes[index];
                          return _buildNoteCard(
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
                        childCount: pinnedNotes.length,
                      ),
                    ),
                  ),
                ],

                // All / Recent Section
                if (unpinnedNotes.isNotEmpty) ...[
                  if (pinnedNotes.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'NOTES',
                          style: TextStyle(
                            fontFamily: AppStyles.fontPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final note = unpinnedNotes[index];
                          return _buildNoteCard(
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
                        childCount: unpinnedNotes.length,
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
                ),
              ],
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(
              bottom: 64 + MediaQuery.of(context).padding.bottom,
            ),
            child: SpringTouch(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => NoteEditorScreen(
                      notesProvider: widget.notesProvider,
                      themeProvider: widget.themeProvider,
                    ),
                  ),
                );
              },
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
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
          ),
        );
      },
    );
  }

  Widget _buildNoteCard({
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
    // Find category color
    final catObj = widget.notesProvider.categories.firstWhere(
      (c) => c.name.toLowerCase() == note.category.toLowerCase(),
      orElse: () => widget.notesProvider.categories.first,
    );

    return Dismissible(
      key: Key('note_${note.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          _confirmDeleteNote(context, note);
          return false;
        } else {
          widget.notesProvider.togglePin(note.id);
          return false;
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B),
          borderRadius: BorderRadius.circular(18),
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
          borderRadius: BorderRadius.circular(18),
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
                  notesProvider: widget.notesProvider,
                  themeProvider: widget.themeProvider,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category pill badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catObj.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: catObj.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            note.category,
                            style: TextStyle(
                              fontFamily: AppStyles.fontPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: catObj.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (note.isPinned)
                      const Icon(
                        CupertinoIcons.pin_fill,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  note.title.trim().isNotEmpty ? note.title : 'Untitled Note',
                  style: AppStyles.titleSmall(textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                      DateFormat('MMM d, yyyy • h:mm a').format(note.updatedAt),
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
