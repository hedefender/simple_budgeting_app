# Scan JSON schema (shared by Scan and Budget)

Status: decided by the owner on 2026-10-20 (roadmap, "Phase 3 decisions"). Scan writes this format; Budget reads it. Budget also reads the legacy format, and never
writes either.

## Canonical format, `schemaVersion` 1

JSON object, UTF-8, field names in camelCase.

```json
{
  "schemaVersion": 1,
  "documentId": "3f2b6c1e-8a5d-4a43-9d1e-6f0c2a7b9e10",
  "createdAt": "2026-10-18T09:41:07+03:00",
  "language": "el",
  "ocrText": "ΔΕΗ Α.Ε.\nΣΥΝΟΛΟ ΠΛΗΡΩΤΕΟ 84,20 EUR\n...",
  "pdfPath": "scan-2026-10-18-0941.pdf",
  "imagePaths": ["scan-2026-10-18-0941-1.jpg", "scan-2026-10-18-0941-2.jpg"]
}
```

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `schemaVersion` | int | yes | `1` today. Greater than the version Budget knows: the file is rejected with a clear message (nothing is imported). Less than 1, or not an integer: error. |
| `documentId` | string | yes | Unique per scanned document, stable (the same document always has the same id). After trimming: 1 to 128 characters. Scan should use a UUID. The id is the duplicate key. |
| `createdAt` | string | yes | ISO 8601 date and time. With an offset or `Z`: it is an exact instant. Without one: read as the device's local time (approved assumption A3 in `docs/phase-3-plan.md`). Scan will write the offset. Not parseable: error. |
| `ocrText` | string | yes | The recognised text. After trimming it must not be empty. |
| `language` | string | no | BCP-47 tag of the document text, for example `"el"` or `"en-GB"`. Null or absent: unknown. Not validated beyond being a non-empty string after trimming (an empty string is read as absent). Added to v1 without changing `schemaVersion`, because it is optional. |
| `pdfPath` | string | no | A file NAME, see "File references". Null or absent: no PDF. |
| `imagePaths` | list of strings | no | File names, same. Null or absent: no images. Every item must be a non-empty string. |

Scan will export `createdAt` WITH an offset (decided by the owner, 2026-10-20). Budget still accepts a `createdAt`
without an offset (old files): it is then read as the device's local time, with the zone applied by Dart, not by the parser.

Rules for reading:

- A leading UTF-8 byte order mark (BOM) is removed before parsing.
- File names (`pdfPath`, `imagePaths`): if a value contains `/` or `\`, only the last segment is kept, in the canonical
  format too (not only in the legacy one). Names are used only as labels, never to build a path. A value that is empty
  after cutting (for example `"folder/"`) is an error for `pdfPath` and for an item of `imagePaths`.
- Unknown extra fields are ignored (so a later 1.x Scan can add fields without breaking Budget). They are not stored.
- A field with the wrong type (`ocrText` a number, `imagePaths` a string, ...) is an error that names the field.
- The top level must be an object. An array or a scalar is an error.
- `schemaVersion` changes only for changes that an older Budget cannot ignore (a renamed or removed field, a changed
  meaning). Adding an optional field does not change it.
- File size limit: 5 MiB per JSON file (proposal; see the plan). Larger: rejected before it is parsed.
- An empty file (0 bytes, or only whitespace) is its own error, not "invalid JSON".
- A file whose name does not end in `.json` (any case) is not read at all. Budget reports it as "skipped: not a JSON
  file", which is neutral, not an error (for example the PDF picked together with the JSON).
- Limits of one import in Budget: 5 MiB per file, 50 files per batch. Files are read one at a time.

## Legacy format (read only)

The first Scan versions wrote:

```json
{
  "version": 1,
  "created": "2026-10-18T09:41:07",
  "ocr_text": "...",
  "image_paths": ["..."],
  "pdf_path": "..."
}
```

A file is treated as legacy when it has no `schemaVersion` and has `ocr_text`. A small converter (the legacy reader)
turns it into the canonical shape in memory; it is never written back.

| Legacy | Canonical |
| --- | --- |
| `version` | ignored (it only says "old Scan") |
| `created` | `createdAt` (same rules as above) |
| `ocr_text` | `ocrText` |
| `pdf_path` | `pdfPath` |
| `image_paths` | `imagePaths` |
| (none) | `language`: always null |
| (none) | `documentId` = `"legacy-"` + the first 32 hex characters of SHA-256 over `created`, a newline, and `ocr_text` |

The id is built from the content, so importing the same legacy file twice gives the same id and is caught as a
duplicate. Two different legacy files with the same `created` and the same text are the same document by definition.
The same validation applies afterwards (empty text, wrong types, ...). Legacy paths are cut to the file name like
canonical ones (everything after the last `/` or `\`).

## Duplicates

The same `documentId` imported a second time creates no second document. The user sees "already imported" for that
file. The stored document is not overwritten (the first import wins). Editing a document is not in Phase 3. The user
can delete a document (decision 9); after that, the same `documentId` can be imported again.

## Privacy

Parsing happens on the device. Nothing in this format or in its import is sent over a network.

## File references

Decided by the owner on 2026-10-20: **option A, file names only.** In Phase 3 the names are stored and shown as
labels; Budget does not copy, read or display the PDF or the images. The analysis below stays as the reason and as the
list of consequences for Phase 8.

### Options that were considered

`pdfPath` and `imagePaths` were paths inside the Scan app. On Android an app cannot read the private files of another
app (its `files/` or `cache/` folder), and a path that is valid in Scan is meaningless in Budget. Even a path on shared
storage cannot be opened by Budget without the user's permission (Android scoped storage). So a path in the JSON
cannot simply be opened.

Options:

- **A. File names only (proposed for the schema, and for Phase 3).** The fields hold plain file names, no folders
  (`scan-2026-10-18-0941.pdf`). Scan exports the JSON, the PDF and the images together, and the user picks them
  together, or picks the folder, in Budget. Budget matches by name. The schema stays the same under every transport
  (picker now, folder or intent later). Budget never depends on a path of another app. Legacy absolute paths are cut
  to the name.
- **B. Scan exports everything into one shared folder that the user chose (Storage Access Framework).** Budget gets
  access to the same folder once (a persistent permission) and resolves the names against it. This is the natural
  transport for option A and could be the way Single/Multi Scan hands over batches.
- **C. Embed the files in the JSON (base64).** Self-contained, so no reference problem, but the JSON grows by about a
  third of the size of every PDF and image; it would conflict with a small size limit and with the readability of the
  JSON. Not proposed.
- **D. Keep absolute paths.** Works only on the same device if both apps happened to share the storage location, and
  not at all on iOS. Not proposed.

Decision: the schema says "a file name relative to the place where the JSON was delivered" (A). In Phase 3 Budget
stores the names and shows them in the document detail, but does not open, copy or display the PDF or images (it may
not have them). Opening them is a later step.

Consequences for Phase 8 (Scan integration):

- Intents / deep links hand over content URIs with a temporary read grant, not paths. Budget must read the bytes at
  once and keep its own copy in its private storage if it wants to keep the PDF or images. So Phase 8 needs a "copy
  attachments on import" step and a storage place for them (a decision about disk use and about export/backup,
  open decision #15).
- Scan needs a `FileProvider` (or a shared folder) to expose the PDF and images. This is a change in the Scan app.
- Android 11+ package visibility: detecting that Scan is installed needs a `<queries>` entry in Budget's manifest.
- iOS: no shared file system between apps. Transfer goes through the share sheet or a shared App Group container. The
  names-only schema works there too; a path-based schema would not.
- The `documentId` is what links the pieces, so it must be created once by Scan and never change.
- Do not ask for "all files access" (`MANAGE_EXTERNAL_STORAGE`): it is against the privacy principle and is rejected by
  stores for this use.
