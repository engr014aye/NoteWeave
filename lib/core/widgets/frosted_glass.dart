import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color backgroundColor;
  final Border? border;
  final BorderRadius? borderRadius;

  const FrostedGlass({
    super.key,
    required this.child,
    this.blur = 20.0,
    required this.backgroundColor,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: border,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
