import 'package:flutter/material.dart';

class SoftEntrance extends StatelessWidget {
  const SoftEntrance({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: child,
      builder:
          (_, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 6 * (1 - value)),
              child: child,
            ),
          ),
    );
  }
}

class PressFeedback extends StatefulWidget {
  const PressFeedback({super.key, required this.child});
  final Widget child;
  @override
  State<PressFeedback> createState() => _PressFeedbackState();
}

class _PressFeedbackState extends State<PressFeedback> {
  bool _pressed = false;
  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _set(true),
    onPointerUp: (_) => _set(false),
    onPointerCancel: (_) => _set(false),
    onPointerMove: (_) => _set(false),
    child: AnimatedScale(
      scale: _pressed && !MediaQuery.disableAnimationsOf(context) ? .985 : 1,
      duration:
          MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 100),
      child: widget.child,
    ),
  );
}
