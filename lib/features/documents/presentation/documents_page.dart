import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_budgeting_app/core/presentation/fab_clearance.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_report.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/import_source.dart';
import 'package:simple_budgeting_app/features/documents/presentation/document_detail_page.dart';
import 'package:simple_budgeting_app/features/documents/presentation/document_providers.dart';
import 'package:simple_budgeting_app/features/documents/presentation/import_report_page.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expense_providers.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_button.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// The imported documents, newest first, and the button that imports Scan
/// JSON files (one or many at once).
class DocumentsPage extends ConsumerStatefulWidget {
  const DocumentsPage({super.key});

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage> {
  bool _importing = false;

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(documentActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final files = await _pick(actions, messenger, l10n);
    if (files == null || files.isEmpty || !mounted) return; // cancelled

    setState(() => _importing = true);
    ImportReport? report;
    try {
      report = await actions.import(files);
    } on TooManyFilesException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          key: const Key('import-too-many'),
          content: Text(l10n.importTooManyFiles(e.limit)),
        ),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
    if (report == null || !mounted) return;
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => ImportReportPage(report: report!),
      ),
    );
  }

  Future<List<ImportSource>?> _pick(
    DocumentActions actions,
    ScaffoldMessengerState messenger,
    AppLocalizations l10n,
  ) async {
    try {
      return await actions.pick();
    } on Object {
      messenger.showSnackBar(
        SnackBar(
          key: const Key('import-pick-error'),
          content: Text(l10n.importPickError),
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final documents = ref.watch(documentListProvider);
    final linked =
        ref.watch(documentIdsWithExpensesProvider).value ?? const <String>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.documentsTitle),
        actions: const <Widget>[SettingsButton()],
        bottom: _importing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(key: Key('import-progress')),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('document-import'),
        heroTag: 'document-import-fab',
        tooltip: l10n.documentsImportTooltip,
        onPressed: _importing ? null : _import,
        child: const Icon(Icons.file_open_outlined),
      ),
      body: documents.when(
        data: (List<ScanDocument> list) => list.isEmpty
            ? _Empty(onImport: _importing ? null : _import)
            : ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  fabListBottomPadding(context),
                ),
                children: <Widget>[
                  for (final document in list)
                    _DocumentTile(
                      document: document,
                      linked: linked.contains(document.id),
                    ),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.incomeLoadError,
                key: const Key('documents-load-error'),
              ),
              TextButton(
                onPressed: () => ref.invalidate(documentListProvider),
                child: Text(l10n.incomeRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onImport});

  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      key: const Key('documents-empty'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.description_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.documentsEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.documentsEmptyBody, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('documents-empty-import'),
              onPressed: onImport,
              icon: const Icon(Icons.file_open_outlined),
              label: Text(l10n.documentsImport),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document, required this.linked});

  final ScanDocument document;
  final bool linked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = document.firstLine();
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(document.createdLocalDay.toUtcDateTime());
    return ListTile(
      key: Key('document-tile-${document.id}'),
      contentPadding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DocumentDetailPage(documentId: document.id),
        ),
      ),
      title: Text(
        title.isEmpty ? l10n.documentNoTitle : title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        <String>[
          date,
          document.sourceFileName,
          if (document.wasLegacy) l10n.documentLegacyChip,
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: linked
          ? Chip(
              key: Key('document-linked-${document.id}'),
              label: Text(l10n.documentLinkedChip),
              visualDensity: VisualDensity.compact,
            )
          : null,
    );
  }
}
