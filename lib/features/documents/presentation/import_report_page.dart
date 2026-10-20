import 'package:flutter/material.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_report.dart';
import 'package:simple_budgeting_app/features/documents/presentation/document_detail_page.dart';
import 'package:simple_budgeting_app/features/documents/presentation/import_labels.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// The result of one import batch, one row per file in the order they were
/// picked: imported, already imported, skipped (not JSON) or the reason of the
/// error. Shown once; the stored documents are the lasting record.
class ImportReportPage extends StatelessWidget {
  const ImportReportPage({super.key, required this.report});

  final ImportReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = <String>[
      if (report.importedCount > 0)
        l10n.importSummaryImported(report.importedCount),
      if (report.duplicateCount > 0)
        l10n.importSummaryDuplicate(report.duplicateCount),
      if (report.failedCount > 0) l10n.importSummaryFailed(report.failedCount),
      if (report.skippedCount > 0)
        l10n.importSummarySkipped(report.skippedCount),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importReportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (summary.isNotEmpty)
            Text(
              summary.join(' · '),
              key: const Key('import-summary'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 8),
          for (var i = 0; i < report.results.length; i++)
            _ResultTile(index: i, result: report.results[i]),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('import-done'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.importDone),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.index, required this.result});

  final int index;
  final FileImportResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final outcome = result.outcome;

    final (
      IconData icon,
      Color color,
      String message,
      String? documentId,
    ) = switch (outcome) {
      Imported(:final document) => (
        Icons.check_circle_outline,
        scheme.primary,
        l10n.importResultImported,
        document.id,
      ),
      Duplicate(:final existing) => (
        Icons.content_copy_outlined,
        scheme.onSurfaceVariant,
        l10n.importResultDuplicate,
        existing.id,
      ),
      Skipped() => (
        Icons.remove_circle_outline,
        scheme.onSurfaceVariant,
        l10n.importResultSkipped,
        null,
      ),
      Failed(:final failure) => (
        Icons.error_outline,
        scheme.error,
        importFailureMessage(l10n, failure),
        null,
      ),
    };

    return ListTile(
      key: Key('import-result-$index'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(result.fileName),
      subtitle: Text(message),
      onTap: documentId == null
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DocumentDetailPage(documentId: documentId),
              ),
            ),
    );
  }
}
