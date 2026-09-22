import 'package:joicrememory/l10n/localization.dart';
import 'package:flutter/material.dart';

/// Static placeholders also work with reduced motion and screen readers.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.cards = true, this.count = 2});
  final bool cards;
  final int count;
  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.loading,
    liveRegion: true,
    child: ExcludeSemantics(
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cards ? Theme.of(context).colorScheme.surface : null,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: EdgeInsets.all(cards ? 16 : 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cards) ...[_Bone(height: 128), SizedBox(height: 18)],
                      FractionallySizedBox(
                        widthFactor: .72,
                        child: _Bone(height: 20),
                      ),
                      SizedBox(height: 12),
                      FractionallySizedBox(
                        widthFactor: .45,
                        child: _Bone(height: 12),
                      ),
                      SizedBox(height: 12),
                      _Bone(height: 12),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _Bone extends StatelessWidget {
  const _Bone({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}
