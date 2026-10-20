import 'package:simple_budgeting_app/features/documents/domain/entities/import_failure.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// The message of one failed file. No OCR text, amount or vendor is ever put
/// in a message.
String importFailureMessage(AppLocalizations l10n, ImportFailure failure) {
  final field = failure.field ?? '';
  return switch (failure.kind) {
    ImportFailureKind.emptyFile => l10n.importErrorEmptyFile,
    ImportFailureKind.tooLarge => l10n.importErrorTooLarge(
      _megabytes(failure.size),
      _megabytes(failure.limit),
    ),
    ImportFailureKind.notUtf8 => l10n.importErrorNotUtf8,
    ImportFailureKind.invalidJson =>
      failure.line == null || failure.column == null
          ? l10n.importErrorInvalidJson
          : l10n.importErrorInvalidJsonAt(failure.line!, failure.column!),
    ImportFailureKind.notAnObject => l10n.importErrorNotAnObject,
    ImportFailureKind.missingField => l10n.importErrorMissingField(field),
    ImportFailureKind.wrongType => l10n.importErrorWrongType(field),
    ImportFailureKind.emptyOcrText => l10n.importErrorEmptyOcrText,
    ImportFailureKind.invalidDocumentId => l10n.importErrorInvalidDocumentId,
    ImportFailureKind.invalidDate => l10n.importErrorInvalidDate,
    ImportFailureKind.emptyFileName => l10n.importErrorEmptyFileName(field),
    ImportFailureKind.unsupportedSchemaVersion =>
      l10n.importErrorUnsupportedVersion(
        failure.foundVersion ?? 0,
        failure.knownVersion ?? 0,
      ),
    ImportFailureKind.readError => l10n.importErrorReadError,
    ImportFailureKind.storageError => l10n.importErrorStorageError,
    ImportFailureKind.unexpected => l10n.importErrorUnexpected,
  };
}

/// `6.0 MB`: sizes are shown in mebibytes with one decimal.
String _megabytes(int? bytes) {
  if (bytes == null) return '';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
