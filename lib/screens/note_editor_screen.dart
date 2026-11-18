import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/models/note_model.dart';
import '../core/state/notes_provider.dart';
import '../core/state/theme_provider.dart';
import '../core/widgets/spring_touch.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? initialNote;
  final String? initialCategory;
  final NotesProvider notesProvider;
  final ThemeProvider themeProvider;

  const NoteEditorScreen({
    super.key,
    this.initialNote,
    this.initialCategory,
    required this.notesProvider,
    required this.themeProvider,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagInputController;
  late final FocusNode _titleFocusNode;
  late final FocusNode _contentFocusNode;

  late String _noteId;
  late String _selectedCategory;
  late bool _isPinned;
  late List<String> _tags;
  late DateTime _createdAt;
  late DateTime _updatedAt;

  Timer? _debounceTimer;
  bool _isNewNote = true;
  bool _isAddingTag = false;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.initialNote == null;

    if (_isNewNote) {
      _noteId = 'note_${DateTime.now().millisecondsSinceEpoch}';
      _selectedCategory = widget.initialCategory ?? widget.notesProvider.defaultCategory;
      _isPinned = false;
      _tags = [];
      _createdAt = DateTime.now();
      _updatedAt = DateTime.now();
      _titleController = TextEditingController();
      _contentController = TextEditingController();
    } else {
      final note = widget.initialNote!;
      _noteId = note.id;
      _selectedCategory = note.category;
      _isPinned = note.isPinned;
      _tags = List.from(note.tags);
      _createdAt = note.createdAt;
      _updatedAt = note.updatedAt;
      _titleController = TextEditingController(text: note.title);
      _contentController = TextEditingController(text: note.content);
    }

    _tagInputController = TextEditingController();
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);

    // Auto-focus title if newly created note
    if (_isNewNote) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _titleFocusNode.requestFocus();
      });
    }
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _autoSave();
    });
  }

  void _autoSave() {
    final title = _titleController.text;
    final content = _contentController.text;

    // Discard empty untitled notes automatically
    if (title.trim().isEmpty && content.trim().isEmpty) {
      if (!_isNewNote) {
        widget.notesProvider.deleteNote(_noteId);
      }
      return;
    }

    _updatedAt = DateTime.now();
    final note = Note(
      id: _noteId,
      title: title,
      content: content,
      category: _selectedCategory,
      isPinned: _isPinned,
      tags: _tags,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
    );

    widget.notesProvider.saveNote(note);
    if (_isNewNote) {
      _isNewNote = false;
    }
  }

  void _togglePin() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPinned = !_isPinned;
    });
    _autoSave();
  }

  void _insertFormatting(String prefix, [String suffix = '']) {
    HapticFeedback.selectionClick();
    final text = _contentController.text;
    final selection = _contentController.selection;

    if (!selection.isValid) {
      // Append to end
      final newText = '$text$prefix$suffix';
      _contentController.text = newText;
      _contentController.selection = TextSelection.collapsed(
        offset: newText.length - suffix.length,
      );
      _contentFocusNode.requestFocus();
      return;
    }

    final start = selection.start;
    final end = selection.end;
    final selectedText = text.substring(start, end);
    final replacement = '$prefix$selectedText$suffix';

    final newText = text.replaceRange(start, end, replacement);
    _contentController.text = newText;
    _contentController.selection = TextSelection(
      baseOffset: start + prefix.length,
      extentOffset: end + prefix.length,
    );
    _contentFocusNode.requestFocus();
  }

  void _showCategoryPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = widget.notesProvider.categories;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(
          'Select Notebook',
          style: AppStyles.titleSmall(AppColors.getTextPrimary(isDark)),
        ),
        actions: categories.map((cat) {
          final isSelected = cat.name.toLowerCase() == _selectedCategory.toLowerCase();
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedCategory = cat.name;
              });
              _autoSave();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: cat.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  cat.name,
                  style: TextStyle(
                    fontFamily: AppStyles.fontPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.getAccent(isDark) : AppColors.getTextPrimary(isDark),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark,
                    size: 16,
                    color: AppColors.getAccent(isDark),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          isDefaultAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _addTag(String tag) {
    final clean = tag.trim().replaceAll('#', '');
    if (clean.isNotEmpty && !_tags.contains(clean)) {
      setState(() {
        _tags.add(clean);
        _tagInputController.clear();
        _isAddingTag = false;
      });
      _autoSave();
    }
  }

  void _removeTag(String tag) {
    HapticFeedback.selectionClick();
    setState(() {
      _tags.remove(tag);
    });
    _autoSave();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _autoSave();
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBackground(isDark);
    final cardBg = AppColors.getCard(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final textTertiary = AppColors.getTextTertiary(isDark);
    final accent = AppColors.getAccent(isDark);
    final border = AppColors.getBorder(isDark);
    final fontScale = widget.themeProvider.fontScale;

    // Find category color
    final catObj = widget.notesProvider.categories.firstWhere(
      (c) => c.name.toLowerCase() == _selectedCategory.toLowerCase(),
      orElse: () => widget.notesProvider.categories.first,
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _autoSave();
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _autoSave();
              Navigator.pop(context);
            },
            child: Icon(
              CupertinoIcons.back,
              color: accent,
              size: 24,
            ),
          ),
          title: SpringTouch(
            onTap: () => _showCategoryPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: catObj.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: catObj.color.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: catObj.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedCategory,
                    style: TextStyle(
                      fontFamily: AppStyles.fontPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: catObj.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 11,
                    color: catObj.color,
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: _togglePin,
              child: Icon(
                _isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                color: _isPinned ? const Color(0xFFF59E0B) : textSecondary,
                size: 22,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & read time row
                    Row(
                      children: [
                        Text(
                          DateFormat('MMMM d, yyyy • h:mm a').format(_updatedAt),
                          style: AppStyles.bodySmall(textTertiary),
                        ),
                        const Spacer(),
                        Text(
                          '${_calculateWordCount(_contentController.text)} words',
                          style: AppStyles.bodySmall(textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Title Field
                    TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      style: AppStyles.titleLarge(textPrimary).copyWith(
                        fontSize: 26 * fontScale,
                      ),
                      cursorColor: accent,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: AppStyles.titleLarge(textTertiary).copyWith(
                          fontSize: 26 * fontScale,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags Bar
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ..._tags.map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1F2633) : const Color(0xFFEFF1F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: border.withValues(alpha: 0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '#$tag',
                                  style: AppStyles.bodySmall(accent).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _removeTag(tag),
                                  child: Icon(
                                    CupertinoIcons.clear,
                                    size: 11,
                                    color: textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isAddingTag)
                          Container(
                            width: 110,
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1F2633) : const Color(0xFFEFF1F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: accent, width: 1),
                            ),
                            child: TextField(
                              controller: _tagInputController,
                              autofocus: true,
                              style: AppStyles.bodySmall(textPrimary),
                              cursorColor: accent,
                              onSubmitted: _addTag,
                              decoration: const InputDecoration(
                                hintText: 'new tag...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 6),
                              ),
                            ),
                          )
                        else
                          SpringTouch(
                            onTap: () {
                              setState(() {
                                _isAddingTag = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: border,
                                  style: BorderStyle.solid,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.add,
                                    size: 12,
                                    color: textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tag',
                                    style: AppStyles.bodySmall(textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: border.withValues(alpha: 0.4), height: 1),
                    const SizedBox(height: 16),

                    // Content Field
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      style: AppStyles.bodyLarge(textPrimary, scaleFactor: fontScale),
                      cursorColor: accent,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Start writing your thoughts, notes, or ideas...',
                        hintStyle: AppStyles.bodyLarge(textTertiary, scaleFactor: fontScale),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Bottom Cupertino Formatting Toolbar
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(
                  top: BorderSide(color: border, width: 0.8),
                ),
              ),
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 6,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? 8
                    : MediaQuery.of(context).padding.bottom + 6,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildToolbarButton(
                      label: 'H1',
                      isDark: isDark,
                      onTap: () => _insertFormatting('\n# '),
                    ),
                    _buildToolbarButton(
                      label: 'H2',
                      isDark: isDark,
                      onTap: () => _insertFormatting('\n## '),
                    ),
                    _buildToolbarButton(
                      icon: CupertinoIcons.bold,
                      isDark: isDark,
                      onTap: () => _insertFormatting('**', '**'),
                    ),
                    _buildToolbarButton(
                      icon: CupertinoIcons.italic,
                      isDark: isDark,
                      onTap: () => _insertFormatting('*', '*'),
                    ),
                    _buildToolbarButton(
                      icon: CupertinoIcons.list_bullet,
                      isDark: isDark,
                      onTap: () => _insertFormatting('\n• '),
                    ),
                    _buildToolbarButton(
                      icon: CupertinoIcons.list_number,
                      isDark: isDark,
                      onTap: () => _insertFormatting('\n1. '),
                    ),
                    _buildToolbarButton(
                      icon: CupertinoIcons.quote_bubble,
                      isDark: isDark,
                      onTap: () => _insertFormatting('\n> '),
                    ),
                    _buildToolbarButton(
                      icon: CupertinoIcons.minus,
                      isDark: isDark,
                      onTap: () => _insertFormatting('\n---\n'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    String? label,
    IconData? icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final textSecondary = AppColors.getTextSecondary(isDark);
    return SpringTouch(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon != null
            ? Icon(
                icon,
                size: 19,
                color: textSecondary,
              )
            : Text(
                label!,
                style: TextStyle(
                  fontFamily: AppStyles.fontPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: textSecondary,
                ),
              ),
      ),
    );
  }

  int _calculateWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}
