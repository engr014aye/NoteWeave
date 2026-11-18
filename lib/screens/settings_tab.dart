import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/state/notes_provider.dart';
import '../core/state/theme_provider.dart';
import '../core/widgets/spring_touch.dart';
import 'privacy_policy_screen.dart';

class SettingsTab extends StatelessWidget {
  final ThemeProvider themeProvider;
  final NotesProvider notesProvider;

  const SettingsTab({
    super.key,
    required this.themeProvider,
    required this.notesProvider,
  });

  void _showDefaultCategoryPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = themeProvider.isDarkMode;
    final categories = notesProvider.categories;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(
          'Default Notebook for New Notes',
          style: AppStyles.titleSmall(AppColors.getTextPrimary(isDark)),
        ),
        actions: categories.map((cat) {
          final isSelected = cat.name.toLowerCase() == notesProvider.defaultCategory.toLowerCase();
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              notesProvider.setDefaultCategory(cat.name);
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

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;
    final bg = AppColors.getBackground(isDark);
    final cardBg = AppColors.getCard(isDark);
    final border = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final accent = AppColors.getAccent(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              'Settings',
              style: TextStyle(
                fontFamily: AppStyles.fontPrimary,
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: cardBg.withValues(alpha: 0.82),
            border: Border(bottom: BorderSide(color: border, width: 0.8)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1: APPEARANCE
                  _buildSectionHeader('APPEARANCE', textSecondary),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border, width: 0.8),
                    ),
                    child: Column(
                      children: [
                        // Theme switcher
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                                      color: accent,
                                      size: 19,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Dark Theme',
                                    style: AppStyles.bodyMedium(textPrimary).copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoSwitch(
                                value: isDark,
                                activeTrackColor: accent,
                                onChanged: (val) {
                                  HapticFeedback.lightImpact();
                                  themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(color: border.withValues(alpha: 0.5), height: 1, indent: 52),
                        // Editor Text Size selector
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.textformat_size,
                                      color: Color(0xFF10B981),
                                      size: 19,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Editor Text Size',
                                    style: AppStyles.bodyMedium(textPrimary).copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoSlidingSegmentedControl<AppTextSize>(
                                  groupValue: themeProvider.textSize,
                                  backgroundColor: isDark ? const Color(0xFF1F2633) : const Color(0xFFF1F3F7),
                                  thumbColor: cardBg,
                                  children: {
                                    AppTextSize.compact: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'Compact',
                                        style: TextStyle(
                                          fontFamily: AppStyles.fontPrimary,
                                          fontSize: 13,
                                          fontWeight: themeProvider.textSize == AppTextSize.compact
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                    AppTextSize.standard: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'Standard',
                                        style: TextStyle(
                                          fontFamily: AppStyles.fontPrimary,
                                          fontSize: 13,
                                          fontWeight: themeProvider.textSize == AppTextSize.standard
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                    AppTextSize.large: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'Large',
                                        style: TextStyle(
                                          fontFamily: AppStyles.fontPrimary,
                                          fontSize: 13,
                                          fontWeight: themeProvider.textSize == AppTextSize.large
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                  },
                                  onValueChanged: (size) {
                                    if (size != null) {
                                      HapticFeedback.selectionClick();
                                      themeProvider.setTextSize(size);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // SECTION 2: WRITING DEFAULTS
                  _buildSectionHeader('WRITING DEFAULTS', textSecondary),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border, width: 0.8),
                    ),
                    child: SpringTouch(
                      onTap: () => _showDefaultCategoryPicker(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                CupertinoIcons.folder_fill,
                                color: Color(0xFFF59E0B),
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Default Notebook',
                                style: AppStyles.bodyMedium(textPrimary).copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              notesProvider.defaultCategory,
                              style: AppStyles.bodyMedium(textSecondary),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              CupertinoIcons.chevron_forward,
                              size: 16,
                              color: textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // SECTION 3: ABOUT
                  _buildSectionHeader('ABOUT', textSecondary),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border, width: 0.8),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: CupertinoIcons.sparkles,
                          iconColor: accent,
                          title: 'App Name',
                          value: 'NoteWeave',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        Divider(color: border.withValues(alpha: 0.5), height: 1, indent: 52),
                        _buildInfoRow(
                          icon: CupertinoIcons.info_circle_fill,
                          iconColor: const Color(0xFF8B5CF6),
                          title: 'Version',
                          value: '1.0.0',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        Divider(color: border.withValues(alpha: 0.5), height: 1, indent: 52),
                        _buildInfoRow(
                          icon: CupertinoIcons.building_2_fill,
                          iconColor: const Color(0xFF06B6D4),
                          title: 'Developer',
                          value: 'Nexus Vice Ltd',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        Divider(color: border.withValues(alpha: 0.5), height: 1, indent: 52),
                        _buildInfoRow(
                          icon: CupertinoIcons.mail_solid,
                          iconColor: const Color(0xFFEC4899),
                          title: 'Contact',
                          value: 'info@amorith.com',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        Divider(color: border.withValues(alpha: 0.5), height: 1, indent: 52),
                        SpringTouch(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.lock_shield_fill,
                                    color: Color(0xFF10B981),
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Privacy Policy',
                                    style: AppStyles.bodyMedium(textPrimary).copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_forward,
                                  size: 16,
                                  color: textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: AppStyles.fontPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppStyles.bodyMedium(textPrimary).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppStyles.bodyMedium(textSecondary),
          ),
        ],
      ),
    );
  }
}
