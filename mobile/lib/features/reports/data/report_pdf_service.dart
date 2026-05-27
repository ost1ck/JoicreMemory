import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../events/data/event_category.dart';
import 'user_report.dart';

class ReportPdfService {
  const ReportPdfService();

  Future<void> printReport(UserReport report) async {
    final bytes = await buildReportPdf(report);
    await Printing.layoutPdf(
      name: 'joicrememory-report.pdf',
      onLayout: (_) async => bytes,
    );
  }

  Future<Uint8List> buildReportPdf(UserReport report) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final medium = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Medium.ttf'),
    );
    final theme = pw.ThemeData.withFont(base: regular, bold: medium);
    final document = pw.Document(theme: theme);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(28),
          pageFormat: PdfPageFormat.a4,
        ),
        build:
            (context) => [
              _header(report, dateFormat),
              pw.SizedBox(height: 16),
              _summaryTable(report),
              pw.SizedBox(height: 18),
              _categoryTable(report),
              pw.SizedBox(height: 18),
              _eventsTable(
                title: 'Створені події',
                events: report.createdEvents,
                dateFormat: dateFormat,
              ),
              pw.SizedBox(height: 18),
              _eventsTable(
                title: 'Події, де користувач є учасником',
                events: report.joinedEvents,
                dateFormat: dateFormat,
              ),
              pw.SizedBox(height: 18),
              ...report.createdEvents.map(
                (event) => _participantsBlock(event, dateFormat),
              ),
            ],
      ),
    );

    return document.save();
  }

  pw.Widget _header(UserReport report, DateFormat dateFormat) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Звіт JoicreMemory',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Text('Користувач: ${report.user.fullName}'),
        pw.Text('Пошта: ${report.user.email}'),
        pw.Text(
          'Сформовано: ${dateFormat.format(report.generatedAt.toLocal())}',
        ),
      ],
    );
  }

  pw.Widget _summaryTable(UserReport report) {
    final summary = report.summary;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Коротка аналітика'),
        pw.TableHelper.fromTextArray(
          headers: const ['Показник', 'Значення'],
          data: [
            ['Створено подій', summary.createdEvents.toString()],
            ['Участь у подіях', summary.joinedEvents.toString()],
            [
              'Учасників у моїх подіях',
              summary.organizedParticipantTotal.toString(),
            ],
            ['Середня заповненість', '${summary.averageFillRatePercent}%'],
            [
              'Планові години (де вказано завершення)',
              summary.totalParticipationHours.toStringAsFixed(1),
            ],
            ['Майбутні події', summary.upcomingEvents.toString()],
            ['Завершені події', summary.completedEvents.toString()],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: const pw.BoxDecoration(
            color: PdfColor(0.84, 0.93, 0.86),
          ),
          cellPadding: const pw.EdgeInsets.all(7),
        ),
      ],
    );
  }

  pw.Widget _categoryTable(UserReport report) {
    final categories = report.summary.categories;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Категорії'),
        if (categories.isEmpty)
          pw.Text('Даних за категоріями ще немає.')
        else
          pw.TableHelper.fromTextArray(
            headers: const ['Категорія', 'Створено', 'Участь', 'Учасники'],
            data:
                categories
                    .map(
                      (category) => [
                        categoryLabel(category.category),
                        category.createdCount.toString(),
                        category.joinedCount.toString(),
                        category.participantCount.toString(),
                      ],
                    )
                    .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor(0.84, 0.93, 0.86),
            ),
            cellPadding: const pw.EdgeInsets.all(7),
          ),
      ],
    );
  }

  pw.Widget _eventsTable({
    required String title,
    required List<ReportEvent> events,
    required DateFormat dateFormat,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        if (events.isEmpty)
          pw.Text('Немає подій для цього розділу.')
        else
          pw.TableHelper.fromTextArray(
            headers: const ['Назва', 'Категорія', 'Дата', 'Місце', 'Учасники'],
            data:
                events
                    .map(
                      (event) => [
                        event.title,
                        categoryLabel(event.category),
                        _eventDate(event, dateFormat),
                        event.locationName,
                        _participantText(event),
                      ],
                    )
                    .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor(0.84, 0.93, 0.86),
            ),
            cellPadding: const pw.EdgeInsets.all(6),
          ),
      ],
    );
  }

  pw.Widget _participantsBlock(ReportEvent event, DateFormat dateFormat) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Учасники: ${event.title}'),
        if (event.participants.isEmpty)
          pw.Text('Учасників ще немає.')
        else
          pw.TableHelper.fromTextArray(
            headers: const ['Імʼя', 'Пошта', 'Роль', 'Дата долучення'],
            data:
                event.participants
                    .map(
                      (participant) => [
                        participant.fullName,
                        participant.email,
                        participant.role == 'organizer'
                            ? 'Організатор'
                            : 'Учасник',
                        dateFormat.format(participant.joinedAt.toLocal()),
                      ],
                    )
                    .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor(0.84, 0.93, 0.86),
            ),
            cellPadding: const pw.EdgeInsets.all(6),
          ),
      ],
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  String _eventDate(ReportEvent event, DateFormat dateFormat) {
    final startsAt = dateFormat.format(event.startsAt.toLocal());
    final endsAt = event.endsAt;

    if (endsAt == null) {
      return '$startsAt (без завершення)';
    }

    return '$startsAt - ${dateFormat.format(endsAt.toLocal())}';
  }

  String _participantText(ReportEvent event) {
    final max = event.maxParticipants;
    if (max == null) {
      return event.participantCount.toString();
    }

    return '${event.participantCount}/$max';
  }
}
