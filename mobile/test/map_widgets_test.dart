import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joicrememory/core/theme/app_theme.dart';
import 'package:joicrememory/features/map/presentation/widgets/map_event_card.dart';
import 'package:joicrememory/features/map/presentation/widgets/map_filters_sheet.dart';
import 'support/fakes.dart';

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'map card actions remain accessible: dark=$dark scale=$scale',
        (tester) async {
          tester.view.physicalSize = const Size(320, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var opened = false;
          var closed = false;
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Scaffold(
                  body: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 280,
                      child: MapEventCard(
                        event: testEvent('one'),
                        onOpen: () => opened = true,
                        onClose: () => closed = true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.textContaining('Відстань недоступна'), findsOneWidget);
          await tester.tap(find.text('Переглянути подію'));
          expect(opened, isTrue);
          await tester.tap(find.byTooltip('Закрити картку'));
          expect(closed, isTrue);
        },
      );
    }
  }

  testWidgets('map filters apply selection, cancel changes, and reset to all', (
    tester,
  ) async {
    String? category = 'cleanup';
    Future<void> open(BuildContext context) async {
      final result = await showModalBottomSheet<MapFilterSelection>(
        context: context,
        isScrollControlled: true,
        builder: (_) => MapFiltersSheet(category: category),
      );
      if (result != null) category = result.category;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () => open(context),
                  child: const Text('Open'),
                ),
          ),
        ),
      ),
    );
    Future<void> show() async {
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    await show();
    await tester.tap(find.text('Освіта'));
    await tester.tap(find.byTooltip('Закрити фільтри'));
    await tester.pumpAndSettle();
    expect(category, 'cleanup');
    await show();
    await tester.tap(find.text('Прибирання'));
    await tester.tap(find.text('Освіта'));
    await tester.ensureVisible(find.text('Показати події'));
    await tester.tap(find.text('Показати події'));
    await tester.pumpAndSettle();
    expect(category, 'education');
    await show();
    await tester.tap(find.text('Усі категорії'));
    await tester.ensureVisible(find.text('Показати події'));
    await tester.tap(find.text('Показати події'));
    await tester.pumpAndSettle();
    expect(category, isNull);
  });
}
