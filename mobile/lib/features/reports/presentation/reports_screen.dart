import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_error_message.dart';
import '../../../core/session/app_session.dart';
import '../../../core/ui/app_snack_bar.dart';
import '../../events/data/event_category.dart';
import '../data/report_pdf_service.dart';
import '../data/user_report.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.session});

  final AppSession session;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _pdfService = const ReportPdfService();
  late Future<UserReport> _reportFuture;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _reportFuture = widget.session.reportApi.getMyReport();
  }

  Future<void> _refresh() async {
    setState(() {
      _reportFuture = widget.session.reportApi.getMyReport();
    });
    await _reportFuture;
  }

  Future<void> _print(UserReport report) async {
    setState(() => _isPrinting = true);

    try {
      await _pdfService.printReport(report);
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, apiErrorMessage(error));
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
      appBar: AppBar(title: const Text('Звіти')),
      body: SafeArea(
        child: FutureBuilder<UserReport>(
          future: _reportFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ReportError(
                message: apiErrorMessage(
                  snapshot.error ?? 'Не вдалося сформувати звіт.',
                ),
                onRetry: _refresh,
              );
            }

            final report = snapshot.data;
            if (report == null) {
              return _ReportError(
                message: 'Не вдалося сформувати звіт.',
                onRetry: _refresh,
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _ReportHeader(report: report),
                  const SizedBox(height: 12),
                  _PrintReportButton(
                    isPrinting: _isPrinting,
                    onPressed: () => _print(report),
                  ),
                  const SizedBox(height: 12),
                  _SummaryGrid(report: report),
                  const SizedBox(height: 12),
                  _CategoryPieChart(report: report),
                  const SizedBox(height: 12),
                  _ActivityBars(report: report),
                  const SizedBox(height: 12),
                  _ReportEventSection(
                    title: 'Створені події',
                    emptyText: 'Ти ще не створював подій.',
                    events: report.createdEvents,
                    showParticipants: true,
                  ),
                  const SizedBox(height: 12),
                  _ReportEventSection(
                    title: 'Моя участь',
                    emptyText: 'Ти ще не долучався до подій.',
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.analytics_outlined,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Персональний звіт',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(report.user.fullName),
                  const SizedBox(height: 2),
                  Text(
                    'Оновлено ${dateFormat.format(report.generatedAt.toLocal())}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
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
              ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.print_outlined),
      label: Text(
        isPrinting ? 'Підготовка PDF...' : 'Сформувати і друкувати PDF',
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.report});

  final UserReport report;

  @override
  Widget build(BuildContext context) {
    final summary = report.summary;
    final metrics = [
      _MetricData(
        icon: Icons.event_available_outlined,
        label: 'Створено',
        value: summary.createdEvents.toString(),
        color: AppColors.leaf,
      ),
      _MetricData(
        icon: Icons.volunteer_activism_outlined,
        label: 'Участь',
        value: summary.joinedEvents.toString(),
        color: AppColors.coral,
      ),
      _MetricData(
        icon: Icons.groups_outlined,
        label: 'Учасників',
        value: summary.organizedParticipantTotal.toString(),
        color: AppColors.sky,
      ),
      _MetricData(
        icon: Icons.insights_outlined,
        label: 'Заповненість',
        value: '${summary.averageFillRatePercent}%',
        color: AppColors.sun,
      ),
      _MetricData(
        icon: Icons.timer_outlined,
        label: 'Планові год.',
        value: summary.totalParticipationHours.toStringAsFixed(1),
        color: AppColors.berry,
      ),
      _MetricData(
        icon: Icons.upcoming_outlined,
        label: 'Майбутні',
        value: summary.upcomingEvents.toString(),
        color: AppColors.teal,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.42,
      ),
      itemBuilder: (context, index) => _MetricCard(data: metrics[index]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(data.icon, color: data.color, size: 22),
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  data.value,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.pie_chart_outline,
              title: 'Події за категоріями',
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              const Text('Ще немає даних для діаграми.')
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
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 14),
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
                            '${categoryLabel(category.category)} (${category.totalCount})',
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(icon: Icons.bar_chart_outlined, title: 'Активність'),
            const SizedBox(height: 16),
            SizedBox(
              height: 190,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue.toDouble() + 1,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget:
                            (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(switch (value.toInt()) {
                                0 => 'Створ.',
                                1 => 'Участь',
                                2 => 'Майб.',
                                _ => 'Зав.',
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(icon: Icons.summarize_outlined, title: title),
            const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              Text('У PDF буде ще ${events.length - 5} подій.'),
            ],
          ],
        ),
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
      leading: const Icon(Icons.event_note_outlined),
      title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${categoryLabel(event.category)} · ${dateFormat.format(event.startsAt.toLocal())}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        showParticipants
            ? max == null
                ? '${event.participantCount}'
                : '${event.participantCount}/$max'
            : event.hasKnownDuration
            ? '${event.durationHours.toStringAsFixed(1)} год'
            : 'без кінця',
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
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
        const SizedBox(width: 6),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Спробувати ще раз'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
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
