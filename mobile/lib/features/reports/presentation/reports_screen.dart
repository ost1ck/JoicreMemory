import 'package:joicrememory/l10n/localization.dart';
import '../../../core/ui/loading_skeleton.dart';
import '../../../app/app_scope.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_error_message.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../core/ui/app_snack_bar.dart';
import '../../events/presentation/event_category.dart';
import 'report_pdf_service.dart';
import '../domain/entities/user_report.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.session});

  final AuthController session;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPdfService get _pdfService => ReportPdfService(strings: context.l10n);
  late Future<UserReport> _reportFuture;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _reportFuture = AppScope.read(context).reports.getMyReport();
  }

  Future<void> _refresh() async {
    setState(() {
      _reportFuture = AppScope.read(context).reports.getMyReport();
    });
    await _reportFuture;
  }

  Future<void> _print(UserReport report) async {
    setState(() => _isPrinting = true);

    try {
      await _pdfService.printReport(report);
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(
          context,
          context.localizeMessage(apiErrorMessage(error)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.reports)),
      body: SafeArea(
        child: FutureBuilder<UserReport>(
          future: _reportFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                padding: EdgeInsets.all(24),
                children: [LoadingSkeleton(cards: false, count: 5)],
              );
            }

            if (snapshot.hasError) {
              return _ReportError(
                message: context.localizeMessage(
                  apiErrorMessage(
                    snapshot.error ?? context.l10n.couldNotGenerateTheReport,
                  ),
                ),
                onRetry: _refresh,
              );
            }

            final report = snapshot.data;
            if (report == null) {
              return _ReportError(
                message: context.l10n.couldNotGenerateTheReport,
                onRetry: _refresh,
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
                children: [
                  _ReportHeader(report: report),
                  SizedBox(height: 12),
                  _PrintReportButton(
                    isPrinting: _isPrinting,
                    onPressed: () => _print(report),
                  ),
                  SizedBox(height: 32),
                  _SummaryMetrics(report: report),
                  Divider(height: 48),
                  _CategoryPieChart(report: report),
                  Divider(height: 48),
                  _ActivityBars(report: report),
                  Divider(height: 48),
                  _ReportEventSection(
                    title: context.l10n.createdEvents,
                    emptyText: context.l10n.youHavenTCreatedAnyEventsYet,
                    events: report.createdEvents,
                    showParticipants: true,
                  ),
                  Divider(height: 48),
                  _ReportEventSection(
                    title: context.l10n.myParticipation,
                    emptyText: context.l10n.youHavenTJoinedAnyEventsYet,
                    events: report.joinedEvents,
                    showParticipants: false,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.report});

  final UserReport report;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.analytics_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.personalReport,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(report.user.fullName),
                SizedBox(height: 2),
                Text(
                  context.l10n.updated(
                    (dateFormat.format(
                      report.generatedAt.toLocal(),
                    )).toString(),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrintReportButton extends StatelessWidget {
  const _PrintReportButton({required this.isPrinting, required this.onPressed});

  final bool isPrinting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isPrinting ? null : onPressed,
      icon:
          isPrinting
              ? SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : Icon(Icons.print_outlined),
      label: Text(
        isPrinting
            ? context.l10n.preparingPdf
            : context.l10n.generateAndPrintPdf,
      ),
    );
  }
}

class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics({required this.report});

  final UserReport report;

  @override
  Widget build(BuildContext context) {
    final summary = report.summary;
    final metrics = [
      _MetricData(
        label: context.l10n.created,
        value: summary.createdEvents.toString(),
      ),
      _MetricData(
        label: context.l10n.joined,
        value: summary.joinedEvents.toString(),
      ),
      _MetricData(
        label: context.l10n.participants,
        value: summary.organizedParticipantTotal.toString(),
      ),
      _MetricData(
        label: context.l10n.fillRate,
        value: '${summary.averageFillRatePercent}%',
      ),
      _MetricData(
        label: context.l10n.plannedHrs,
        value: summary.totalParticipationHours.toStringAsFixed(1),
      ),
      _MetricData(
        label: context.l10n.upcoming,
        value: summary.upcomingEvents.toString(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.insights_outlined,
              title: context.l10n.myContribution,
            ),
            SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 28,
              children: [
                for (final data in metrics)
                  SizedBox(
                    width:
                        (constraints.maxWidth - 24 * (columns - 1)) / columns,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.value,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          data.label,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  const _CategoryPieChart({required this.report});

  final UserReport report;

  @override
  Widget build(BuildContext context) {
    final categories = report.summary.categories;
    final colors = _chartColors(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.pie_chart_outline,
            title: context.l10n.eventsByCategory,
          ),
          SizedBox(height: 16),
          if (categories.isEmpty)
            Text(context.l10n.noChartDataYet)
          else ...[
            SizedBox(
              height: 210,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 42,
                  sectionsSpace: 3,
                  sections:
                      categories.asMap().entries.map((entry) {
                        final category = entry.value;
                        final color = colors[entry.key % colors.length];

                        return PieChartSectionData(
                          value: category.totalCount.toDouble(),
                          title: category.totalCount.toString(),
                          color: color,
                          radius: 58,
                          titleStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children:
                  categories.asMap().entries.map((entry) {
                    final category = entry.value;
                    final color = colors[entry.key % colors.length];

                    return _LegendItem(
                      color: color,
                      label:
                          '${categoryLabel(category.category, strings: context.l10n)} (${category.totalCount})',
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityBars extends StatelessWidget {
  const _ActivityBars({required this.report});

  final UserReport report;

  @override
  Widget build(BuildContext context) {
    final summary = report.summary;
    final maxValue = [
      summary.createdEvents,
      summary.joinedEvents,
      summary.upcomingEvents,
      summary.completedEvents,
    ].fold<int>(1, (max, value) => value > max ? value : max);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.bar_chart_outlined,
            title: context.l10n.activity,
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue.toDouble() + 1,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget:
                          (value, meta) => Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(switch (value.toInt()) {
                              0 => context.l10n.created20,
                              1 => context.l10n.joined,
                              2 => context.l10n.upcoming21,
                              _ => context.l10n.ended,
                            }, style: Theme.of(context).textTheme.bodySmall),
                          ),
                    ),
                  ),
                ),
                barGroups: [
                  _bar(0, summary.createdEvents, AppColors.leaf),
                  _bar(1, summary.joinedEvents, AppColors.coral),
                  _bar(2, summary.upcomingEvents, AppColors.sky),
                  _bar(3, summary.completedEvents, AppColors.berry),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, int value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          color: color,
          width: 24,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}

class _ReportEventSection extends StatelessWidget {
  const _ReportEventSection({
    required this.title,
    required this.emptyText,
    required this.events,
    required this.showParticipants,
  });

  final String title;
  final String emptyText;
  final List<ReportEvent> events;
  final bool showParticipants;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.summarize_outlined, title: title),
          SizedBox(height: 8),
          if (events.isEmpty)
            Text(emptyText)
          else
            ...events
                .take(5)
                .map(
                  (event) => _ReportEventTile(
                    event: event,
                    showParticipants: showParticipants,
                  ),
                ),
          if (events.length > 5) ...[
            SizedBox(height: 8),
            Text(
              context.l10n.thePdfWillIncludeMoreEvents(
                (events.length - 5).toString(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportEventTile extends StatelessWidget {
  const _ReportEventTile({required this.event, required this.showParticipants});

  final ReportEvent event;
  final bool showParticipants;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM HH:mm');
    final max = event.maxParticipants;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.event_note_outlined),
      title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${categoryLabel(event.category, strings: context.l10n)} · ${dateFormat.format(event.startsAt.toLocal())}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        showParticipants
            ? max == null
                ? '${event.participantCount}'
                : '${event.participantCount}/$max'
            : event.hasKnownDuration
            ? context.l10n.hrs(
              (event.durationHours.toStringAsFixed(1)).toString(),
            )
            : context.l10n.noEndTime,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _ReportError extends StatelessWidget {
  const _ReportError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48),
            SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData({required this.label, required this.value});
  final String label;
  final String value;
}

List<Color> _chartColors(BuildContext context) {
  return [
    AppColors.leaf,
    AppColors.coral,
    AppColors.sky,
    AppColors.sun,
    AppColors.berry,
    AppColors.teal,
    Theme.of(context).colorScheme.secondary,
  ];
}
