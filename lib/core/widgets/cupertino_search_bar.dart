import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class CupertinoSearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String placeholder;

  const CupertinoSearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.placeholder = 'Search notes, tags, or ideas...',
  });

  @override
  State<CupertinoSearchBarWidget> createState() => _CupertinoSearchBarWidgetState();
}

class _CupertinoSearchBarWidgetState extends State<CupertinoSearchBarWidget> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_textListener);
  }

  void _textListener() {
    final has = widget.controller.text.isNotEmpty;
    if (has != _hasText) {
      setState(() {
        _hasText = has;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getInputBg(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textTertiary = AppColors.getTextTertiary(isDark);

    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getBorder(isDark).withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            CupertinoIcons.search,
            size: 18,
            color: textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              style: AppStyles.bodyMedium(textPrimary),
              cursorColor: AppColors.getAccent(isDark),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: AppStyles.bodyMedium(textTertiary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.controller.clear();
                widget.onClear();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  CupertinoIcons.clear_circled_solid,
                  size: 18,
                  color: textTertiary,
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
