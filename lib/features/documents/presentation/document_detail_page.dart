import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money_formatter.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/documents/presentation/document_providers.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expense_form_page.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expense_labels.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expense_providers.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// How many characters of the OCR text are shown before "Show all". A very
/// long text in one widget makes the page slow.
const int ocrPreviewChars = 20000;

/// One document: when it was created, where it came from, the file names (only
/// labels), the OCR text, the expenses made from it, "Create expense" and
/// delete.
class DocumentDetailPage extends ConsumerStatefulWidget {
  const DocumentDetailPage({super.key, required this.documentId});

  /// The local id of the document.
  final String documentId;

  @override
  ConsumerState<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends ConsumerState<DocumentDetailPage> {
  bool _showAll = false;

  Future<void> _delete(ScanDocument document) async {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(documentActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final linked = await actions.linkedExpenseCount(document.id);
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.documentDeleteTitle),
        content: Text(
          key: const Key('document-delete-body'),
          linked == 0
              ? l10n.documentDeleteBodyPlain
              : '${l10n.documentDeleteBodyPlain}\n\n'
                    '${l10n.documentDeleteBodyExpenses(linked)}',
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('document-delete-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('document-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await actions.delete(document.id);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        key: const Key('document-deleted'),
        content: Text(l10n.documentDeleted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(documentProvider(widget.documentId));
    final document = async.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.documentDetailTitle),
        actions: <Widget>[
          if (document != null)
            IconButton(
              key: const Key('document-delete'),
              tooltip: l10n.documentDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(document),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => Center(
          child: Text(l10n.incomeLoadError, key: const Key('document-error')),
        ),
        data: (ScanDocument? doc) => doc == null
            ? Center(
                child: Text(
                  l10n.documentNotFound,
                  key: const Key('document-missing'),
                ),
              )
            : _Body(
                document: doc,
                showAll: _showAll,
                onShowAll: () => setState(() => _showAll = true),
              ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.document,
    required this.showAll,
    required this.onShowAll,
  });

  final ScanDocument document;
  final bool showAll;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tag = Localizations.localeOf(context).toString();
    final created = DateFormat.yMMMd(
      tag,
    ).add_Hm().format(document.createdAt.toLocal());
    final imported = ref
        .watch(importBatchProvider(document.importId))
        .value
        ?.importedAt
        .toLocal();

    final text = document.ocrText;
    final truncated = !showAll && text.length > ocrPreviewChars;
    final shown = truncated ? text.substring(0, ocrPreviewChars) : text;
    final expenses = ref.watch(documentExpensesProvider(document.id)).value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          '${l10n.documentCreatedLabel}: $created',
          key: const Key('document-created'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          imported == null
              ? document.sourceFileName
              : l10n.documentSourceLine(document.sourceFileName, imported),
          key: const Key('document-source'),
        ),
        if (document.wasLegacy)
          Text(l10n.documentLegacyNote, key: const Key('document-legacy')),
        if (document.language != null)
          Text(
            l10n.documentLanguageLine(document.language!),
            key: const Key('document-language'),
          ),
        const SizedBox(height: 4),
        SelectableText(
          '${l10n.documentIdLabel}: ${document.documentId}',
          key: const Key('document-id'),
          style: theme.textTheme.bodySmall,
        ),
        if (document.pdfName != null ||
            document.imageNames.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          if (document.pdfName != null)
            Text(
              l10n.documentPdfLine(document.pdfName!),
              key: const Key('document-pdf'),
            ),
          if (document.imageNames.isNotEmpty)
            Text(
              l10n.documentImagesLine(
                document.imageNames.length,
                document.imageNames.join(', '),
              ),
              key: const Key('document-images'),
            ),
          Text(l10n.documentFilesNotStored, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('document-create-expense'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ExpenseFormPage(fromDocument: document),
            ),
          ),
          icon: const Icon(Icons.add),
          label: Text(l10n.documentCreateExpense),
        ),
        if (expenses != null && expenses.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text(l10n.documentExpensesHeader, style: theme.textTheme.titleSmall),
          for (final expense in expenses) _LinkedExpenseTile(expense: expense),
        ],
        const SizedBox(height: 16),
        Text(l10n.documentOcrHeader, style: theme.textTheme.titleSmall),
        // The note and the button come BEFORE the text: after 20,000
        // characters nobody would find them.
        if (truncated) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            l10n.documentTextTruncated(ocrPreviewChars, text.length),
            key: const Key('document-truncated'),
            style: theme.textTheme.bodySmall,
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              key: const Key('document-show-all'),
              onPressed: onShowAll,
              child: Text(l10n.documentShowAll),
            ),
          ),
        ],
        const SizedBox(height: 4),
        SelectableText(shown, key: const Key('document-text')),
      ],
    );
  }
}

class _LinkedExpenseTile extends ConsumerWidget {
  const _LinkedExpenseTile({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(expenseCategoriesProvider).value ?? [];
    final category = categoryById(categories, expense.categoryId);
    final categoryName = category == null
        ? expense.categoryId
        : categoryLabel(l10n, category);
    final localeTag = ref.watch(deviceLocaleProvider).toString();
    final amount = expense.amount;
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(expense.date.toUtcDateTime());
    return ListTile(
      key: Key('document-expense-${expense.id}'),
      contentPadding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ExpenseFormPage(expense: expense),
        ),
      ),
      title: Text(expense.description ?? categoryName),
      subtitle: Text(date),
      trailing: amount == null
          ? Chip(
              label: Text(l10n.expenseAwaitingAmount),
              visualDensity: VisualDensity.compact,
            )
          : Text(
              MoneyFormatter(
                localeTag: localeTag,
                currencyCode: expense.currencyCode,
              ).format(amount),
            ),
    );
  }
}
