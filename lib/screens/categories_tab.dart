import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/models/category_model.dart';
import '../core/state/notes_provider.dart';
import '../core/state/theme_provider.dart';
import '../core/widgets/spring_touch.dart';
import 'category_detail_screen.dart';

class CategoriesTab extends StatefulWidget {
  final NotesProvider notesProvider;
  final ThemeProvider themeProvider;

  const CategoriesTab({
    super.key,
    required this.notesProvider,
    required this.themeProvider,
  });

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  void _showCreateCategoryDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();
    Color selectedColor = AppColors.categoryPalette.first;

    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CupertinoAlertDialog(
              title: const Text('New Notebook'),
              content: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoTextField(
                      controller: textController,
                      autofocus: true,
                      placeholder: 'Notebook Title',
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Theme Accent:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppColors.categoryPalette.map((color) {
                        final isSelected = color.toARGB32() == selectedColor.toARGB32();
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setDialogState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    CupertinoIcons.checkmark,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(ctx),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Create'),
                  onPressed: () {
                    final name = textController.text.trim();
                    if (name.isNotEmpty) {
                      widget.notesProvider.addCategory(
                        name,
                        selectedColor.toARGB32(),
                      );
                    }
                    Navigator.pop(ctx);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, NoteCategory cat) {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Delete "${cat.name}"?'),
        message: const Text(
          'Notes inside this notebook will be preserved and moved to your default notebook.',
        ),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              widget.notesProvider.deleteCategory(cat.id, cat.name);
            },
            child: const Text('Delete Notebook'),
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
    final accent = AppColors.getAccent(isDark);

    return ListenableBuilder(
      listenable: widget.notesProvider,
      builder: (context, _) {
        final categories = widget.notesProvider.categories;

        return Scaffold(
          backgroundColor: bg,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  'Notebooks',
                  style: TextStyle(
                    fontFamily: AppStyles.fontPrimary,
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                backgroundColor: cardBg.withValues(alpha: 0.82),
                border: Border(bottom: BorderSide(color: border, width: 0.8)),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _showCreateCategoryDialog(context),
                  child: Icon(
                    CupertinoIcons.plus_circle_fill,
                    color: accent,
                    size: 24,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.08,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cat = categories[index];
                      final noteCount = widget.notesProvider.getNoteCountForCategory(cat.name);

                      return SpringTouch(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => CategoryDetailScreen(
                                category: cat,
                                notesProvider: widget.notesProvider,
                                themeProvider: widget.themeProvider,
                              ),
                            ),
                          );
                        },
                        onLongPress: cat.isCustom
                            ? () => _confirmDeleteCategory(context, cat)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: border, width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: cat.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(cat.name),
                                      color: cat.color,
                                      size: 20,
                                    ),
                                  ),
                                  if (cat.isCustom)
                                    GestureDetector(
                                      onTap: () => _confirmDeleteCategory(context, cat),
                                      child: Icon(
                                        CupertinoIcons.ellipsis,
                                        size: 18,
                                        color: textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: AppStyles.titleSmall(textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$noteCount ${noteCount == 1 ? 'note' : 'notes'}',
                                    style: AppStyles.bodySmall(textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower == 'work') return CupertinoIcons.briefcase_fill;
    if (lower == 'study') return CupertinoIcons.book_fill;
    if (lower == 'ideas') return CupertinoIcons.lightbulb_fill;
    if (lower == 'journal') return CupertinoIcons.bookmark_fill;
    return CupertinoIcons.folder_fill;
  }
}
