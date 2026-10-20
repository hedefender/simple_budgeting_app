import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';

ScanDocument _doc(String text, {DateTime? createdAt}) => ScanDocument(
  id: 'd',
  documentId: 'scan',
  importId: 'b',
  sourceFileName: 'a.json',
  createdAt: createdAt ?? DateTime.utc(2026, 10, 18, 12),
  ocrText: text,
  schemaVersion: 1,
  wasLegacy: false,
);

void main() {
  group('firstLine', () {
    test('the first line that has something in it, trimmed', () {
      expect(_doc('ΔΕΗ Α.Ε.\nΣΥΝΟΛΟ 84,20').firstLine(), 'ΔΕΗ Α.Ε.');
      expect(_doc('\n \n\t  Kiosk  \nnext').firstLine(), 'Kiosk');
    });

    test('all line endings', () {
      expect(_doc('\r\nWindows\r\nsecond').firstLine(), 'Windows');
      expect(_doc('\rOld Mac\rsecond').firstLine(), 'Old Mac');
      expect(_doc('\n\nUnix').firstLine(), 'Unix');
    });

    test('no line with text: empty', () {
      expect(_doc('').firstLine(), '');
      expect(_doc(' \n\t\r\n ').firstLine(), '');
    });

    test('cut to 80 characters by default, to the given length otherwise', () {
      expect(_doc('x' * 200).firstLine(), 'x' * 80);
      expect(_doc('x' * 80).firstLine(), 'x' * 80);
      expect(_doc('abcdef').firstLine(maxLength: 3), 'abc');
    });

    test('a cut does not leave trailing white space', () {
      expect(_doc('abc def').firstLine(maxLength: 4), 'abc');
    });

    test('a cut never splits a character made of two code units', () {
      final emoji = '😀' * 100;
      final line = _doc(emoji).firstLine(maxLength: 5);
      expect(line, '😀' * 5);
      expect(line.runes.length, 5);
    });

    test('Greek text is counted in characters', () {
      expect(_doc('ά' * 100).firstLine(), 'ά' * 80);
    });
  });

  group('createdLocalDay', () {
    test('is the day of createdAt in the zone of the device', () {
      final doc = _doc('x', createdAt: DateTime.utc(2026, 10, 18, 12));
      final local = DateTime.utc(2026, 10, 18, 12).toLocal();
      expect(
        doc.createdLocalDay,
        CalendarDate(local.year, local.month, local.day),
      );
    });

    test('follows toLocal, which can cross midnight', () {
      final at = DateTime.utc(2026, 10, 18, 23, 30);
      final local = at.toLocal();
      expect(
        _doc('x', createdAt: at).createdLocalDay,
        CalendarDate(local.year, local.month, local.day),
      );
    });
  });
}
