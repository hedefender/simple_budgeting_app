import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/documents/presentation/documents_page.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expenses_page.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

import '../support/income_fakes.dart';

/// The last row of a long list can be scrolled clear of the floating button.
void main() {
  late GetIt locator;
  late dynamic fakes;

  setUp(() {
    locator = GetIt.asNewInstance();
    fakes = registerIncomeFakes(
      locator,
      clock: () => DateTime.utc(2026, 10, 16, 9),
    );
    fakes.settings.primaryCurrency = 'EUR';
  });

  tearDown(() => locator.reset());

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const locale = Locale('en', 'US');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serviceLocatorProvider.overrideWithValue(locator),
          deviceLocaleProvider.overrideWithValue(locale),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: page,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollToEnd(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
    }
  }

  void expectClear(WidgetTester tester, Finder last, Key fab) {
    final lastBottom = tester.getBottomLeft(last).dy;
    final fabTop = tester.getTopLeft(find.byKey(fab)).dy;
    expect(lastBottom, lessThanOrEqualTo(fabTop));
  }

  testWidgets('Expenses: the last expense is not under the button', (
    tester,
  ) async {
    final at = DateTime.utc(2026, 10, 1);
    for (var i = 1; i <= 25; i++) {
      await fakes.expenses.add(
        Expense(
          id: 'e$i',
          categoryId: 'food',
          date: CalendarDate(2026, 10, 1 + i % 20),
          currencyCode: 'EUR',
          amount: Money(100 * i),
          createdAt: at.add(Duration(minutes: i)),
          updatedAt: at,
        ),
      );
    }
    await pump(tester, const ExpensesPage());
    await scrollToEnd(tester);

    // Oldest date, then oldest created: the last row of the list.
    final all = (await fakes.expenses.list()).cast<Expense>();
    final last = all.last;
    expectClear(
      tester,
      find.byKey(Key('expense-tile-${last.id}')),
      const Key('expense-add'),
    );
  });

  testWidgets('Income: the last source is not under the button', (
    tester,
  ) async {
    for (var i = 1; i <= 20; i++) {
      await fakes.income.addSource(
        IncomeSource(
          id: 's$i',
          name: 'Source ${i.toString().padLeft(2, '0')}',
          type: IncomeType.salary,
          amount: Money(1000 * i),
          currencyCode: 'EUR',
          schedule: const Monthly.onDay(5),
          startDate: CalendarDate(2026, 10, 1),
          createdAt: DateTime.utc(2026, 10, 1, 0, i),
        ),
      );
    }
    await pump(tester, const IncomePage());
    await scrollToEnd(tester);

    expectClear(
      tester,
      find.byKey(const Key('source-s20')),
      const Key('income-add'),
    );
  });

  testWidgets('Documents: the last document is not under the button', (
    tester,
  ) async {
    for (var i = 1; i <= 25; i++) {
      await fakes.documents.add(
        ScanDocument(
          id: 'doc$i',
          documentId: 'scan$i',
          importId: 'b1',
          sourceFileName: 'f$i.json',
          createdAt: DateTime.utc(2026, 10, 1, 12).add(Duration(hours: i)),
          ocrText: 'Document ${i.toString().padLeft(2, '0')}',
          schemaVersion: 1,
          wasLegacy: false,
        ),
      );
    }
    await pump(tester, const DocumentsPage());
    await scrollToEnd(tester);

    // The oldest document is the last row.
    expectClear(
      tester,
      find.byKey(const Key('document-tile-doc1')),
      const Key('document-import'),
    );
  });
}
