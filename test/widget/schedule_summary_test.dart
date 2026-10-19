import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_labels.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

void main() {
  Future<AppLocalizations> l10nFor(WidgetTester tester, Locale locale) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return l10n;
  }

  final oneOff = OneOff(CalendarDate(2026, 3, 5));
  const monthlyDay = Monthly.onDay(5);
  const monthlyLast = Monthly.onLastDay();
  const monthlyNth = Monthly(NthWorkingDay(3));
  final severalDays = SeveralPerMonth(const [DayOfMonth(1), DayOfMonth(15)]);
  final severalMixed = SeveralPerMonth(const [NthWorkingDay(2), LastDay()]);
  const weekly = Weekly(DateTime.friday);

  testWidgets('every schedule summary in English', (tester) async {
    final l10n = await l10nFor(tester, const Locale('en'));

    expect(
      scheduleSummary(l10n, oneOff),
      allOf(startsWith('Once on'), contains('2026')),
    );
    expect(scheduleSummary(l10n, monthlyDay), 'Monthly on day 5');
    expect(scheduleSummary(l10n, monthlyLast), 'Monthly on the last day');
    expect(scheduleSummary(l10n, monthlyNth), 'Monthly, working day 3');
    expect(scheduleSummary(l10n, severalDays), 'Monthly on day 1, day 15');
    expect(
      scheduleSummary(l10n, severalMixed),
      'Monthly on working day 2, last day',
    );
    expect(scheduleSummary(l10n, weekly), 'Every Friday');
  });

  testWidgets('every schedule summary in Greek', (tester) async {
    final l10n = await l10nFor(tester, const Locale('el'));

    expect(
      scheduleSummary(l10n, oneOff),
      allOf(startsWith('Μία φορά στις'), contains('2026')),
    );
    expect(scheduleSummary(l10n, monthlyDay), 'Κάθε μήνα, ημέρα 5');
    expect(
      scheduleSummary(l10n, monthlyLast),
      'Κάθε μήνα, την τελευταία ημέρα',
    );
    expect(scheduleSummary(l10n, monthlyNth), 'Κάθε μήνα, εργάσιμη 3');
    expect(scheduleSummary(l10n, severalDays), 'Κάθε μήνα: ημέρα 1, ημέρα 15');
    expect(
      scheduleSummary(l10n, severalMixed),
      'Κάθε μήνα: εργάσιμη 2, τελευταία ημέρα',
    );
    expect(scheduleSummary(l10n, weekly), 'Κάθε Παρασκευή');
  });

  testWidgets('a Monthly Nth working day is not shown as the last day', (
    tester,
  ) async {
    final l10n = await l10nFor(tester, const Locale('en'));

    expect(
      scheduleSummary(l10n, monthlyNth),
      isNot(scheduleSummary(l10n, monthlyLast)),
    );
  });

  testWidgets('weekday names, short rules and shift labels in both languages', (
    tester,
  ) async {
    final en = await l10nFor(tester, const Locale('en'));
    expect(dayRuleShort(en, const DayOfMonth(7)), 'day 7');
    expect(dayRuleShort(en, const LastDay()), 'last day');
    expect(dayRuleShort(en, const NthWorkingDay(4)), 'working day 4');
    expect(
      shiftRuleLabel(en, ShiftRule.previousWorkingDay),
      'Pay on the previous working day',
    );
    expect(
      shiftRuleLabel(en, ShiftRule.nextWorkingDay),
      'Pay on the next working day',
    );
    expect(shiftRuleLabel(en, ShiftRule.none), 'Do not move');

    final el = await l10nFor(tester, const Locale('el'));
    expect(dayRuleShort(el, const DayOfMonth(7)), 'ημέρα 7');
    expect(dayRuleShort(el, const LastDay()), 'τελευταία ημέρα');
    expect(dayRuleShort(el, const NthWorkingDay(4)), 'εργάσιμη 4');
    expect(
      shiftRuleLabel(el, ShiftRule.previousWorkingDay),
      'Πληρωμή την προηγούμενη εργάσιμη',
    );
    expect(
      shiftRuleLabel(el, ShiftRule.nextWorkingDay),
      'Πληρωμή την επόμενη εργάσιμη',
    );
    expect(shiftRuleLabel(el, ShiftRule.none), 'Χωρίς μετακίνηση');
  });

  test('weekdayDate gives the right weekday', () {
    for (var weekday = 1; weekday <= 7; weekday++) {
      expect(weekdayDate(weekday).weekday, weekday);
    }
  });
}
