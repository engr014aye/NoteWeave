import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SpringTouch extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final HitTestBehavior behavior;

  const SpringTouch({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.95,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<SpringTouch> createState() => _SpringTouchState();
}

class _SpringTouchState extends State<SpringTouch> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _spring = SpringDescription(
    mass: 1.0,
    stiffness: 500.0,
    damping: 28.0,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(
      vsync: this,
      value: 0.0,
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    HapticFeedback.selectionClick();
    final simulation = SpringSimulation(
      _spring,
      _controller.value,
      1.0,
      _controller.velocity,
    );
    _controller.animateWith(simulation);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    final simulation = SpringSimulation(
      _spring,
      _controller.value,
      0.0,
      _controller.velocity,
    );
    _controller.animateWith(simulation);
  }

  void _onTapCancel() {
    if (widget.onTap == null && widget.onLongPress == null) return;
    final simulation = SpringSimulation(
      _spring,
      _controller.value,
      0.0,
      _controller.velocity,
    );
    _controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap != null
          ? () {
              HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      onLongPress: widget.onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              widget.onLongPress!();
            }
          : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value.clamp(0.0, 1.2);
          final scale = 1.0 - (t * (1.0 - widget.scaleDown));
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
