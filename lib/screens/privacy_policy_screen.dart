import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/widgets/spring_touch.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String privacyPolicyUrl =
      'https://doc-hosting.flycricket.io/noteweave-privacy-policy/095d0cad-a9bc-45ff-8df7-1f678d656437/privacy';

  const PrivacyPolicyScreen({super.key});

  Future<void> _openOnlinePolicy() async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(privacyPolicyUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Fallback to platform default
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBackground(isDark);
    final cardBg = AppColors.getCard(isDark);
    final border = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final textTertiary = AppColors.getTextTertiary(isDark);
    final accent = AppColors.getAccent(isDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.back,
            color: accent,
            size: 24,
          ),
        ),
        title: Text(
          'Privacy Policy',
          style: AppStyles.titleSmall(textPrimary),
        ),
        centerTitle: true,
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: _openOnlinePolicy,
            child: Icon(
              CupertinoIcons.arrow_up_right_square,
              color: accent,
              size: 22,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Online Policy Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.globe,
                          color: accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Online Privacy Policy',
                          style: AppStyles.titleSmall(textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'The official NoteWeave Privacy Policy is published and hosted on the web at Flycricket:',
                    style: AppStyles.bodyMedium(textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    privacyPolicyUrl,
                    style: AppStyles.bodySmall(accent).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  SpringTouch(
                    onTap: _openOnlinePolicy,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Open Online Policy',
                            style: AppStyles.labelBold(Colors.white),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            CupertinoIcons.arrow_up_right,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Zero Data Collection Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.shield_fill,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Zero Data Collection Guarantee',
                          style: AppStyles.titleSmall(textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NoteWeave was intentionally crafted with a privacy-first foundation. We believe your thoughts, writings, and ideas are strictly yours alone.',
                    style: AppStyles.bodyMedium(textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '1. Complete Privacy by Design',
              content:
                  'NoteWeave operates with zero network trackers, zero analytics telemetry, and zero remote servers. Everything you write is processed exclusively on your device.',
              primaryColor: textPrimary,
              secondaryColor: textSecondary,
            ),
            const SizedBox(height: 18),
            _buildSection(
              title: '2. Zero Tracking & No Advertisements',
              content:
                  'We do not track your behavior, identity, or usage habits. There are no advertising SDKs, third-party user trackers, or marketing profiling embedded in NoteWeave.',
              primaryColor: textPrimary,
              secondaryColor: textSecondary,
            ),
            const SizedBox(height: 18),
            _buildSection(
              title: '3. Data Ownership & Control',
              content:
                  'You have total and absolute ownership of your notes and categories. When you delete a note or category inside the app, it is removed immediately.',
              primaryColor: textPrimary,
              secondaryColor: textSecondary,
            ),
            const SizedBox(height: 18),
            _buildSection(
              title: '4. Contact & Online Reference',
              content:
                  'If you have any questions or inquiries regarding our privacy commitment, please reach out to Nexus Vice Ltd at info@amorith.com or review the policy online at:\n$privacyPolicyUrl',
              primaryColor: textPrimary,
              secondaryColor: textSecondary,
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Nexus Vice Ltd • NoteWeave 1.0.0',
                style: AppStyles.bodySmall(textTertiary),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.titleSmall(primaryColor),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: AppStyles.bodyMedium(secondaryColor),
        ),
      ],
    );
  }
}
