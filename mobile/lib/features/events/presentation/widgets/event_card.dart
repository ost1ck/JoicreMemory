import 'package:joicrememory/l10n/localization.dart';
import '../../../../core/ui/soft_motion.dart';
import '../../../../core/theme/app_gradients.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/event.dart';
import '../event_category.dart';

IconData categoryIcon(String category) => switch (category) {
  'volunteering' => Icons.volunteer_activism_outlined,
  'charity' => Icons.favorite_border,
  'cleanup' => Icons.eco_outlined,
  'education' => Icons.school_outlined,
  'community' => Icons.people_outline,
  'emergency' => Icons.bolt_outlined,
  _ => Icons.auto_awesome_outlined,
};

String eventDate(Event event) =>
    DateFormat('dd.MM · HH:mm').format(event.startsAt.toLocal());
String shortMonth(DateTime date, {String locale = 'uk'}) =>
    locale == 'en'
        ? DateFormat.MMM('en').format(date).toUpperCase()
        : [
          'СІЧ',
          'ЛЮТ',
          'БЕР',
          'КВІ',
          'ТРА',
          'ЧЕР',
          'ЛИП',
          'СЕР',
          'ВЕР',
          'ЖОВ',
          'ЛИС',
          'ГРУ',
        ][date.month - 1];

String participantLabel(int count, {String locale = 'uk'}) {
  if (locale == 'en') {
    return '$count ${count == 1 ? 'participant' : 'participants'}';
  }
  final tens = count % 100;
  final ones = count % 10;
  final word =
      tens >= 11 && tens <= 14
          ? 'учасників'
          : ones == 1
          ? 'учасник'
          : ones >= 2 && ones <= 4
          ? 'учасники'
          : 'учасників';
  return '$count $word';
}

/// Shared event preview. The entire surface opens details; it never joins an event.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.featured = false,
  });
  final Event event;
  final VoidCallback onTap;
  final bool featured;

  static double featuredHeight(BuildContext context) {
    // The carousel reserves two title lines and five metadata/action lines.
    final scaler = MediaQuery.textScalerOf(context);
    return 148 +
        math.max(0, scaler.scale(24) - 24) +
        100 +
        scaler.scale(18) * 2.5 +
        scaler.scale(13) * 6.8;
  }

  String? _status(BuildContext context, DateTime now) => switch (event.phaseAt(
    now,
  )) {
    EventPhase.cancelled => context.l10n.cancelled,
    EventPhase.completed => context.l10n.completed,
    EventPhase.draft => context.l10n.draft,
    EventPhase.ended => context.l10n.pastEvent,
    EventPhase.ongoing => context.l10n.happeningNow,
    EventPhase.today => context.l10n.today,
    EventPhase.upcoming => null,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = event.startsAt.toLocal();
    final status = _status(context, DateTime.now());
    final capacity = event.maxParticipants;
    final remaining =
        capacity == null
            ? null
            : math.max(0, capacity - event.participantCount);
    final availability =
        status ??
        (remaining == null
            ? context.l10n.openToEveryone
            : remaining == 0
            ? context.l10n.noPlacesLeft
            : context.l10n.placesLeft((remaining).toString()));
    final metadataStyle = TextStyle(
      color: colors.onSurfaceVariant,
      fontSize: 13,
      height: 1.35,
    );
    final content = Padding(
      padding: EdgeInsets.all(featured ? 16 : 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: featured ? 18 : 21,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -.3,
            ),
          ),
          SizedBox(height: 12),
          _InfoLine(
            icon: Icons.place_outlined,
            text: event.locationName,
            style: metadataStyle,
          ),
          SizedBox(height: 6),
          _InfoLine(
            icon: Icons.schedule_outlined,
            text:
                '${DateFormat('dd.MM.yyyy · HH:mm').format(date)}${event.distanceMeters == null ? '' : ' · ${_distance(context, event.distanceMeters!)}'}',
            style: metadataStyle,
          ),
          SizedBox(height: 16),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: .6),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 18,
                  color: colors.onSecondaryContainer,
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participantLabel(
                        event.participantCount,
                        locale: context.l10n.localeName,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      availability,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            event.status == 'cancelled'
                                ? colors.error
                                : colors.onSurfaceVariant,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                context.l10n.view,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: colors.primary,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
    return SoftEntrance(
      child: PressFeedback(
        child: Semantics(
          button: true,
          onTap: onTap,
          label: context.l10n.viewEvent(
            (event.title).toString(),
            (categoryLabel(event.category, strings: context.l10n)).toString(),
            (DateFormat('dd.MM.yyyy HH:mm').format(date)).toString(),
            (event.locationName).toString(),
            (participantLabel(
              event.participantCount,
              locale: context.l10n.localeName,
            )).toString(),
            (availability).toString(),
          ),
          excludeSemantics: true,
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppGradients.surface(context),
              ),
              child: InkWell(
                onTap: onTap,
                excludeFromSemantics: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EventCover(event: event, height: featured ? 148 : 174),
                    content,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _distance(BuildContext context, double meters) =>
    meters < 1000
        ? context.l10n.m((meters.round()).toString())
        : context.l10n.km(
          ((meters / 1000)
              .toStringAsFixed(1)
              .replaceAll(
                '.',
                context.l10n.localeName == 'uk' ? ',' : '.',
              )).toString(),
        );

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.text,
    required this.style,
  });
  final IconData icon;
  final String text;
  final TextStyle style;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: style.color),
      SizedBox(width: 7),
      Expanded(
        child: Text(
          text,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class EventCover extends StatelessWidget {
  const EventCover({super.key, required this.event, required this.height});
  final Event event;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = event.startsAt.toLocal();
    final tint = switch (event.category) {
      'cleanup' => Color(0xFF49664D),
      'education' => Color(0xFF596783),
      'community' => Color(0xFF9A703D),
      'charity' => Color(0xFF925965),
      'emergency' => Color(0xFFA94B36),
      'volunteering' => Color(0xFF9B6448),
      _ => Color(0xFF77628A),
    };
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base =
        Color.lerp(
          tint,
          dark ? Color(0xFF211C18) : Color(0xFFF2E6D5),
          dark ? .25 : .55,
        )!;
    final foreground =
        dark ? Color(0xFFF8EDE0) : Color.lerp(tint, Colors.black, .3)!;
    final fallback = DecoratedBox(
      key: Key('category-cover'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, Color.lerp(base, tint, .25)!],
        ),
      ),
      child: CustomPaint(
        painter: _CoverPattern(foreground.withValues(alpha: .14)),
        child: Align(
          alignment: Alignment(.48, .65),
          child: Transform.rotate(
            angle: -.14,
            child: Icon(
              categoryIcon(event.category),
              size: 102,
              color: foreground.withValues(alpha: .75),
            ),
          ),
        ),
      ),
    );
    final url = event.imageUrl?.trim();
    final uri = url == null ? null : Uri.tryParse(url);
    final valid =
        uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'https' || uri.scheme == 'http');
    return SizedBox(
      height:
          height + math.max(0, MediaQuery.textScalerOf(context).scale(24) - 24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (valid)
            Image.network(
              url!,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              frameBuilder:
                  (context, child, frame, synchronous) =>
                      frame == null ? fallback : child,
              errorBuilder: (_, _, _) => fallback,
            )
          else
            fallback,
          // Opaque badges stay readable over both photos and illustrations.
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoryIcon(event.category),
                          size: 14,
                          color: colors.onSurface,
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            categoryLabel(
                              event.category,
                              strings: context.l10n,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${date.day}'.padLeft(2, '0'),
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 23,
                          height: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        shortMonth(date, locale: context.l10n.localeName),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverPattern extends CustomPainter {
  const _CoverPattern(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
    final center = Offset(size.width * .76, size.height * .87);
    for (final radius in [58.0, 86.0, 116.0, 149.0]) {
      canvas.drawCircle(center, radius, paint);
    }
    paint.style = PaintingStyle.fill;
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 5; col++) {
        canvas.drawCircle(
          Offset(23 + col * 11, size.height - 22 - row * 11),
          1.4,
          paint,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoverPattern oldDelegate) => oldDelegate.color != color;
}
