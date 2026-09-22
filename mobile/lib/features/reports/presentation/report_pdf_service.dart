import 'package:flutter/widgets.dart' show Locale;
import 'package:joicrememory/l10n/localization.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../events/presentation/event_category.dart';
import '../domain/entities/user_report.dart';

class ReportPdfService {
  const ReportPdfService({AppLocalizations? strings})
    : _providedStrings = strings;
  final AppLocalizations? _providedStrings;
  AppLocalizations get _strings =>
      _providedStrings ?? lookupAppLocalizations(const Locale('uk'));

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
        pageTheme: pw.PageTheme(
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
                title: _strings.createdEvents,
                events: report.createdEvents,
                dateFormat: dateFormat,
              ),
              pw.SizedBox(height: 18),
              _eventsTable(
                title: _strings.eventsTheUserHasJoined,
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
          _strings.joicrememoryReport,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Text(_strings.user((report.user.fullName).toString())),
        pw.Text(_strings.email((report.user.email).toString())),
        pw.Text(
          _strings.generated(
            (dateFormat.format(report.generatedAt.toLocal())).toString(),
          ),
        ),
      ],
    );
  }

  pw.Widget _summaryTable(UserReport report) {
    final summary = report.summary;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(_strings.summary),
        pw.TableHelper.fromTextArray(
          headers: [_strings.metric, _strings.value],
          data: [
            [_strings.eventsCreated, summary.createdEvents.toString()],
            [_strings.eventsJoined, summary.joinedEvents.toString()],
            [
              _strings.participantsInMyEvents,
              summary.organizedParticipantTotal.toString(),
            ],
            [_strings.averageFillRate, '${summary.averageFillRatePercent}%'],
            [
              _strings.plannedHoursEventsWithAnEndTime,
              summary.totalParticipationHours.toStringAsFixed(1),
            ],
            [_strings.upcomingEvents, summary.upcomingEvents.toString()],
            [_strings.completedEvents, summary.completedEvents.toString()],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: pw.BoxDecoration(color: PdfColor(0.84, 0.93, 0.86)),
          cellPadding: pw.EdgeInsets.all(7),
        ),
      ],
    );
  }

  pw.Widget _categoryTable(UserReport report) {
    final categories = report.summary.categories;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(_strings.categories),
        if (categories.isEmpty)
          pw.Text(_strings.noCategoryDataYet)
        else
          pw.TableHelper.fromTextArray(
            headers: [
              _strings.category,
              _strings.created,
              _strings.joined,
              _strings.participants45,
            ],
            data:
                categories
                    .map(
                      (category) => [
                        categoryLabel(category.category, strings: _strings),
                        category.createdCount.toString(),
                        category.joinedCount.toString(),
                        category.participantCount.toString(),
                      ],
                    )
                    .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: pw.BoxDecoration(
              color: PdfColor(0.84, 0.93, 0.86),
            ),
            cellPadding: pw.EdgeInsets.all(7),
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
          pw.Text(_strings.noEventsInThisSection)
        else
          pw.TableHelper.fromTextArray(
            headers: [
              _strings.title,
              _strings.category,
              _strings.date,
              _strings.place,
              _strings.participants45,
            ],
            data:
                events
                    .map(
                      (event) => [
                        event.title,
                        categoryLabel(event.category, strings: _strings),
                        _eventDate(event, dateFormat),
                        event.locationName,
                        _participantText(event),
                      ],
                    )
                    .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: pw.BoxDecoration(
              color: PdfColor(0.84, 0.93, 0.86),
            ),
            cellPadding: pw.EdgeInsets.all(6),
          ),
      ],
    );
  }

  pw.Widget _participantsBlock(ReportEvent event, DateFormat dateFormat) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(_strings.participants50((event.title).toString())),
        if (event.participants.isEmpty)
          pw.Text(_strings.noParticipantsYet)
        else
          pw.TableHelper.fromTextArray(
            headers: [
              _strings.name,
              _strings.email53,
              _strings.role,
              _strings.dateJoined,
            ],
            data:
                event.participants
                    .map(
                      (participant) => [
                        participant.fullName,
                        participant.email,
                        participant.role == 'organizer'
                            ? _strings.organizer
                            : _strings.participant,
                        dateFormat.format(participant.joinedAt.toLocal()),
                      ],
                    )
                    .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: pw.BoxDecoration(
              color: PdfColor(0.84, 0.93, 0.86),
            ),
            cellPadding: pw.EdgeInsets.all(6),
          ),
      ],
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8),
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
      return _strings.noEndTime58((startsAt).toString());
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
