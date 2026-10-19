import 'dart:io';

import 'package:drift/drift.dart' show DriftWrappedException;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/expenses/data/category_repository_impl.dart';
import 'package:simple_budgeting_app/features/expenses/data/expense_repository_impl.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';

CalendarDate _d(int y, int m, int d) => CalendarDate(y, m, d);

Expense _expense(
  String id, {
  String category = 'food',
  CalendarDate? date,
  String currency = 'EUR',
  Money? amount = const Money(4500),
  OriginalAmount? original,
  Money? tax,
  String? description,
  DateTime? createdAt,
}) {
  final at = createdAt ?? DateTime.utc(2026, 10, 19, 9);
  return Expense(
    id: id,
    description: description,
    categoryId: category,
    date: date ?? _d(2026, 10, 19),
    currencyCode: currency,
    amount: amount,
    original: original,
    tax: tax,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  late AppDatabase db;
  late ExpenseRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ExpenseRepositoryImpl(db);
  });

  tearDown(() => db.close());

  group('CRUD', () {
    test('round trips every field', () async {
      final e = _expense(
        'a',
        description: 'ΔΕΗ',
        category: 'energy',
        amount: const Money(2890),
        original: const OriginalAmount(Money(2450), 'GBP'),
        tax: const Money(560),
      );
      await repository.add(e);

      final back = (await repository.get('a'))!;
      expect(back.description, 'ΔΕΗ');
      expect(back.categoryId, 'energy');
      expect(back.date, _d(2026, 10, 19));
      expect(back.currencyCode, 'EUR');
      expect(back.amount, const Money(2890));
      expect(back.original, const OriginalAmount(Money(2450), 'GBP'));
      expect(back.tax, const Money(560));
      expect(back.createdAt, DateTime.utc(2026, 10, 19, 9));
      expect(back.updatedAt, DateTime.utc(2026, 10, 19, 9));
      expect(back.isPending, isFalse);
    });

    test('a pending expense round trips with a null amount', () async {
      await repository.add(
        _expense(
          'p',
          amount: null,
          original: const OriginalAmount(Money(2450), 'GBP'),
        ),
      );
      final back = (await repository.get('p'))!;
      expect(back.isPending, isTrue);
      expect(back.amount, isNull);
      expect(back.original, const OriginalAmount(Money(2450), 'GBP'));
    });

    test('get returns null for an unknown id', () async {
      expect(await repository.get('none'), isNull);
    });

    test('update replaces the fields, delete removes the row', () async {
      await repository.add(_expense('a'));
      await repository.update(
        _expense('a', category: 'health', amount: const Money(100)),
      );
      final back = (await repository.get('a'))!;
      expect(back.categoryId, 'health');
      expect(back.amount, const Money(100));

      await repository.delete('a');
      expect(await repository.get('a'), isNull);
    });
  });

  group('list', () {
    test('newest date first, then newest created first', () async {
      await repository.add(_expense('old', date: _d(2026, 10, 1)));
      await repository.add(
        _expense(
          'new-early',
          date: _d(2026, 10, 5),
          createdAt: DateTime.utc(2026, 10, 5, 8),
        ),
      );
      await repository.add(
        _expense(
          'new-late',
          date: _d(2026, 10, 5),
          createdAt: DateTime.utc(2026, 10, 5, 9),
        ),
      );
      expect((await repository.list()).map((e) => e.id), [
        'new-late',
        'new-early',
        'old',
      ]);
    });

    test('from and to are inclusive', () async {
      await repository.add(_expense('a', date: _d(2026, 9, 30)));
      await repository.add(_expense('b', date: _d(2026, 10, 1)));
      await repository.add(_expense('c', date: _d(2026, 10, 31)));
      await repository.add(_expense('d', date: _d(2026, 11, 1)));
      final october = await repository.list(
        from: _d(2026, 10, 1),
        to: _d(2026, 10, 31),
      );
      expect(october.map((e) => e.id).toSet(), {'b', 'c'});
    });

    test('filters by category', () async {
      await repository.add(_expense('a', category: 'food'));
      await repository.add(_expense('b', category: 'health'));
      expect((await repository.list(categoryId: 'health')).map((e) => e.id), [
        'b',
      ]);
    });

    test('currency codes include pending expenses', () async {
      await repository.add(_expense('a', currency: 'EUR'));
      await repository.add(
        _expense(
          'b',
          currency: 'CHF',
          amount: null,
          original: const OriginalAmount(Money(1), 'GBP'),
        ),
      );
      await repository.add(_expense('c', currency: 'EUR'));
      expect(await repository.listCurrencyCodes(), {'EUR', 'CHF'});
    });
  });

  group('categories', () {
    test('the eight built-in categories, in display order', () async {
      final all = await CategoryRepositoryImpl(db).listCategories();
      expect(all.map((c) => c.key), [
        'energy',
        'water',
        'telecom',
        'food',
        'fuel_transport',
        'health',
        'insurance',
        'other',
      ]);
      expect(all.map((c) => c.id), all.map((c) => c.key));
    });

    test(
      'opening the same database file again does not duplicate them',
      () async {
        final dir = Directory.systemTemp.createTempSync('categories_seed');
        addTearDown(() => dir.deleteSync(recursive: true));
        final file = File('${dir.path}/test.sqlite');

        final first = AppDatabase(NativeDatabase(file));
        expect(
          await CategoryRepositoryImpl(first).listCategories(),
          hasLength(8),
        );
        await first.close();

        final second = AppDatabase(NativeDatabase(file));
        addTearDown(second.close);
        expect(
          await CategoryRepositoryImpl(second).listCategories(),
          hasLength(8),
        );
      },
    );

    test('an expense needs an existing category (foreign key)', () async {
      await expectLater(
        repository.add(_expense('a', category: 'no-such-category')),
        throwsA(anything),
      );
    });
  });

  // The CHECK constraints guard the database even when the domain is bypassed,
  // so these go in with raw SQL.
  group('CHECK constraints', () {
    Future<void> insert({
      String? amount,
      String? originalAmount,
      String? originalCurrency,
      String? tax,
    }) {
      String v(String? s) => s ?? 'NULL';
      String q(String? s) => s == null ? 'NULL' : "'$s'";
      return db.customStatement(
        'INSERT INTO expenses (id, category_id, expense_date, currency_code, '
        'amount_minor, original_amount_minor, original_currency_code, '
        'tax_amount_minor, created_at, updated_at) VALUES '
        "('x', 'food', '2026-10-19', 'EUR', ${v(amount)}, ${v(originalAmount)}, "
        '${q(originalCurrency)}, ${v(tax)}, 0, 0)',
      );
    }

    final rejected = throwsA(
      predicate(
        (Object e) =>
            e.toString().contains('CHECK constraint failed') ||
            (e is DriftWrappedException &&
                e.toString().contains('CHECK constraint failed')),
        'a failed CHECK constraint',
      ),
    );

    test('the valid shapes are accepted', () async {
      await insert(amount: '100');
      await db.customStatement("DELETE FROM expenses WHERE id = 'x'");
      await insert(originalAmount: '100', originalCurrency: 'GBP');
      await db.customStatement("DELETE FROM expenses WHERE id = 'x'");
      await insert(
        amount: '100',
        originalAmount: '90',
        originalCurrency: 'GBP',
        tax: '10',
      );
    });

    test('neither an amount nor an original amount fails', () async {
      await expectLater(insert(), rejected);
    });

    test('an original amount without a currency fails', () async {
      await expectLater(insert(amount: '100', originalAmount: '90'), rejected);
      await expectLater(insert(originalAmount: '90'), rejected);
    });

    test('an original currency without an amount fails', () async {
      await expectLater(
        insert(amount: '100', originalCurrency: 'GBP'),
        rejected,
      );
      await expectLater(insert(originalCurrency: 'GBP'), rejected);
    });

    test('a zero or negative amount fails', () async {
      await expectLater(insert(amount: '0'), rejected);
      await expectLater(insert(amount: '-5'), rejected);
    });

    test('a zero or negative original amount or tax fails', () async {
      await expectLater(
        insert(amount: '100', originalAmount: '0', originalCurrency: 'GBP'),
        rejected,
      );
      await expectLater(
        insert(amount: '100', originalAmount: '-1', originalCurrency: 'GBP'),
        rejected,
      );
      await expectLater(insert(amount: '100', tax: '0'), rejected);
      await expectLater(insert(amount: '100', tax: '-3'), rejected);
    });

    test('a pending expense with a bad original amount still fails', () async {
      await expectLater(
        insert(originalAmount: '0', originalCurrency: 'GBP'),
        rejected,
      );
    });
  });
}
