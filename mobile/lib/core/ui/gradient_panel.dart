import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';

class GradientPanel extends StatelessWidget {
  const GradientPanel({
    super.key,
    required this.child,
    this.accent = false,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final bool accent;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient:
          accent ? AppGradients.accent(context) : AppGradients.surface(context),
      borderRadius: BorderRadius.circular(24),
      border:
          accent
              ? null
              : Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: .45),
              ),
    ),
    child: Padding(padding: padding, child: child),
  );
}
