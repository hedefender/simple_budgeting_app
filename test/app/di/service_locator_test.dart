import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/app/di/service_locator.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/features/documents/data/document_repository_impl.dart';
import 'package:simple_budgeting_app/features/documents/data/file_selector_import.dart';
import 'package:simple_budgeting_app/features/documents/data/rust_scan_json_parser.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_report.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/document_repository.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/import_file_picker.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/scan_json_parser.dart';
import 'package:simple_budgeting_app/features/documents/domain/usecases/document_usecases.dart';
import 'package:simple_budgeting_app/features/documents/domain/usecases/import_scan_files.dart';
import 'package:simple_budgeting_app/features/foundation/data/rust_core_info_service.dart';
import 'package:simple_budgeting_app/features/foundation/domain/repositories/app_status_repository.dart';
import 'package:simple_budgeting_app/features/foundation/domain/services/core_info_service.dart';

import '../../support/document_fakes.dart';

void main() {
  test('the dependency graph resolves and runs end to end', () async {
    final locator = GetIt.asNewInstance();
    var nativeInits = 0;
    addTearDown(locator.reset);
    configureDependencies(
      locator,
      databaseExecutor: NativeDatabase.memory(),
      clock: () => DateTime.utc(2026, 10, 16),
      initNative: () async => nativeInits++,
    );

    expect(locator<AppDatabase>(), isA<AppDatabase>());
    expect(locator<AppStatusRepository>(), isA<AppStatusRepository>());

    final result = await locator<Bootstrapper>().run();
    expect(result.status.launchCount, 1);
    expect(nativeInits, 1);
    expect(locator<CoreInfoService>(), isA<RustCoreInfoService>());
  });

  test('database and bootstrapper are singletons', () {
    final locator = GetIt.asNewInstance();
    addTearDown(locator.reset);
    configureDependencies(
      locator,
      databaseExecutor: NativeDatabase.memory(),
      initNative: () async {},
    );

    expect(identical(locator<AppDatabase>(), locator<AppDatabase>()), isTrue);
    expect(identical(locator<Bootstrapper>(), locator<Bootstrapper>()), isTrue);
  });

  test('the documents graph: real repository and picker, Rust parser', () {
    final locator = GetIt.asNewInstance();
    addTearDown(locator.reset);
    configureDependencies(
      locator,
      databaseExecutor: NativeDatabase.memory(),
      initNative: () async {},
    );

    expect(locator<DocumentRepository>(), isA<DocumentRepositoryImpl>());
    expect(locator<ScanJsonParser>(), isA<RustScanJsonParser>());
    expect(locator<ImportFilePicker>(), isA<FileSelectorImportFilePicker>());
    expect(locator<ImportScanFiles>(), isA<ImportScanFiles>());
    expect(locator<ListDocuments>(), isA<ListDocuments>());
    expect(locator<GetDocument>(), isA<GetDocument>());
    expect(locator<DeleteDocument>(), isA<DeleteDocument>());
    expect(locator<ListDocumentExpenses>(), isA<ListDocumentExpenses>());
    expect(
      locator<ListDocumentIdsWithExpenses>(),
      isA<ListDocumentIdsWithExpenses>(),
    );
  });

  test('an import runs through the real database and use cases', () async {
    final locator = GetIt.asNewInstance();
    addTearDown(locator.reset);
    configureDependencies(
      locator,
      databaseExecutor: NativeDatabase.memory(),
      clock: () => DateTime.utc(2026, 10, 20, 12),
      initNative: () async {},
    );
    // Host tests never load the native library: the parser is a fake.
    final parser = FakeScanJsonParser()
      ..results['t'] = parsedScan('doc-1', ocrText: 'ΔΕΗ');
    locator
      ..unregister<ScanJsonParser>()
      ..registerSingleton<ScanJsonParser>(parser);

    final report = await locator<ImportScanFiles>()([
      FakeImportSource('a.json', text: 't'),
    ]);
    expect(report.results.single.outcome, isA<Imported>());

    final list = await locator<ListDocuments>()();
    expect(list.single.documentId, 'doc-1');
    expect(list.single.ocrText, 'ΔΕΗ');
    expect(await locator<DeleteDocument>()(list.single.id), 0);
    expect(await locator<ListDocuments>()(), isEmpty);
  });
}
