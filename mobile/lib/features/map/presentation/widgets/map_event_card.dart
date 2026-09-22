import 'package:joicrememory/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../events/domain/entities/event.dart';
import '../../../events/presentation/event_category.dart';
import '../../../events/presentation/widgets/event_card.dart';

class MapEventCard extends StatelessWidget {
  const MapEventCard({
    super.key,
    required this.event,
    required this.onOpen,
    required this.onClose,
  });
  final Event event;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final distance = event.distanceMeters;
    final distanceLabel =
        distance == null
            ? context.l10n.distanceUnavailable
            : distance < 1000
            ? context.l10n.mAway((distance.round()).toString())
            : context.l10n.kmAway(
              ((distance / 1000).toStringAsFixed(1)).toString(),
            );
    return Material(
      color: colors.surface,
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.surface(context)),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          categoryIcon(event.category),
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            categoryLabel(
                              event.category,
                              strings: context.l10n,
                            ),
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          tooltip: context.l10n.closeCard,
                          icon: Icon(Icons.close),
                          iconSize: 20,
                        ),
                      ],
                    ),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      DateFormat(
                        'dd.MM · HH:mm',
                      ).format(event.startsAt.toLocal()),
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '${event.locationName} · $distanceLabel',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onOpen,
                  icon: Icon(Icons.arrow_forward, size: 18),
                  label: Text(context.l10n.viewEvent289),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
