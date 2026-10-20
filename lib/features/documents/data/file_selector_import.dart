import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_failure.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/import_file_picker.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/import_source.dart';

/// A picked file, read lazily through `XFile`.
class FileSelectorImportSource implements ImportSource {
  FileSelectorImportSource(this._file);

  final XFile _file;

  @override
  String get name => _file.name;

  @override
  Future<int> length() async {
    try {
      return await _file.length();
    } on Object {
      throw const ImportFailureException(
        ImportFailure(ImportFailureKind.readError),
      );
    }
  }

  @override
  Future<String> readText() async {
    final List<int> bytes;
    try {
      bytes = await _file.readAsBytes();
    } on Object {
      throw const ImportFailureException(
        ImportFailure(ImportFailureKind.readError),
      );
    }
    try {
      // Strict: invalid UTF-8 is an error, not replaced characters. A BOM is
      // kept; the parser removes it.
      return utf8.decode(bytes);
    } on FormatException {
      throw const ImportFailureException(
        ImportFailure(ImportFailureKind.notUtf8),
      );
    }
  }
}

/// Opens the system file chooser with multiple selection (Single Scan and
/// Multi Scan are the same gesture).
///
/// No type filter: Android file providers do not always label `.json` files
/// as JSON, and a filter would hide them. A file that is not `.json` is
/// reported as skipped by the import. To try the JSON filter set
/// [jsonOnly] (decision of 2026-10-20: try the filter on the emulator first;
/// see `docs/phase-3-plan.md`).
class FileSelectorImportFilePicker implements ImportFilePicker {
  const FileSelectorImportFilePicker({this.jsonOnly = false});

  final bool jsonOnly;

  @override
  Future<List<ImportSource>> pick() async {
    final files = await openFiles(
      acceptedTypeGroups: jsonOnly
          ? const <XTypeGroup>[
              XTypeGroup(
                label: 'JSON',
                extensions: <String>['json'],
                mimeTypes: <String>['application/json'],
              ),
            ]
          : const <XTypeGroup>[],
    );
    return files.map(FileSelectorImportSource.new).toList();
  }
}
