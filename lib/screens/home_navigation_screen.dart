import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/state/notes_provider.dart';
import '../core/state/theme_provider.dart';
import '../core/widgets/spring_touch.dart';
import 'categories_tab.dart';
import 'notes_tab.dart';
import 'settings_tab.dart';

class HomeNavigationScreen extends StatefulWidget {
  final NotesProvider notesProvider;
  final ThemeProvider themeProvider;

  const HomeNavigationScreen({
    super.key,
    required this.notesProvider,
    required this.themeProvider,
  });

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeProvider.isDarkMode;
    final cardBg = AppColors.getCard(isDark);
    final border = AppColors.getBorder(isDark);
    final accent = AppColors.getAccent(isDark);
    final textTertiary = AppColors.getTextTertiary(isDark);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          NotesTab(
            notesProvider: widget.notesProvider,
            themeProvider: widget.themeProvider,
          ),
          CategoriesTab(
            notesProvider: widget.notesProvider,
            themeProvider: widget.themeProvider,
          ),
          SettingsTab(
            themeProvider: widget.themeProvider,
            notesProvider: widget.notesProvider,
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(color: border, width: 0.8),
              ),
            ),
            padding: EdgeInsets.only(
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(
                  index: 0,
                  label: 'Notes',
                  activeIcon: CupertinoIcons.doc_text_fill,
                  inactiveIcon: CupertinoIcons.doc_text,
                  accentColor: accent,
                  inactiveColor: textTertiary,
                ),
                _buildTabItem(
                  index: 1,
                  label: 'Categories',
                  activeIcon: CupertinoIcons.folder_fill,
                  inactiveIcon: CupertinoIcons.folder,
                  accentColor: accent,
                  inactiveColor: textTertiary,
                ),
                _buildTabItem(
                  index: 2,
                  label: 'Settings',
                  activeIcon: CupertinoIcons.gear_alt_fill,
                  inactiveIcon: CupertinoIcons.gear_alt,
                  accentColor: accent,
                  inactiveColor: textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required Color accentColor,
    required Color inactiveColor,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: SpringTouch(
        scaleDown: 0.92,
        onTap: () {
          if (_currentIndex != index) {
            HapticFeedback.selectionClick();
            setState(() {
              _currentIndex = index;
            });
          }
        },
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                size: 24,
                color: isSelected ? accentColor : inactiveColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppStyles.fontPrimary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? accentColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
