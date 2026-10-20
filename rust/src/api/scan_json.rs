//! Parser and validator of the Scan JSON files (`docs/scan-json-schema.md`).
//!
//! Stateless: text in, a plain struct or a typed error out. It never opens the
//! database and never touches the file system. This module processes external
//! data, so `unwrap`, `expect` and panicking indexing are forbidden here.
#![deny(clippy::unwrap_used, clippy::expect_used, clippy::indexing_slicing)]

use serde_json::{Map, Value};
use sha2::{Digest, Sha256};

/// The newest `schemaVersion` this parser understands.
pub const SUPPORTED_SCHEMA_VERSION: u32 = 1;

/// Hard limit of one JSON file. Dart checks the size before reading the file;
/// this is the second guard.
pub const MAX_JSON_BYTES: u64 = 5 * 1024 * 1024;

const MAX_DOCUMENT_ID_CHARS: usize = 128;

/// When the document was created.
enum Created {
    /// The file had an offset or `Z`: an exact instant, milliseconds since
    /// the Unix epoch, UTC.
    Instant { utc_ms: i64 },
    /// The file had no offset: the wall-clock time as written
    /// (`yyyy-MM-ddTHH:mm:ss`). Dart applies the device time zone.
    Local { text: String },
}

/// A Scan document in the canonical shape (a legacy file is converted).
pub struct ParsedScan {
    /// The `schemaVersion` of the file; 1 for a legacy file.
    pub schema_version: u32,
    pub document_id: String,
    /// Set when the file had an offset or `Z`: milliseconds since the Unix
    /// epoch, UTC. Exactly one of the two `created_at` fields is set.
    pub created_at_utc_ms: Option<i64>,
    /// Set when the file had no offset: the wall-clock time as written,
    /// `yyyy-MM-ddTHH:mm:ss`. Dart applies the device time zone.
    pub created_at_local: Option<String>,
    pub ocr_text: String,
    /// BCP-47 tag, or `None` when absent or empty.
    pub language: Option<String>,
    /// A file name, cut to its last segment. A label, never a path.
    pub pdf_name: Option<String>,
    pub image_names: Vec<String>,
    pub was_legacy: bool,
}

/// Why a file was refused. Each case maps to one user message in the app.
#[derive(Debug, PartialEq, Eq)]
enum Problem {
    EmptyFile,
    TooLarge { size: u64, limit: u64 },
    InvalidJson { line: u32, column: u32 },
    NotAnObject,
    MissingField { field: String },
    WrongType { field: String },
    EmptyOcrText,
    InvalidDocumentId,
    InvalidDate,
    EmptyFileName { field: String },
    UnsupportedSchemaVersion { found: i64, known: u32 },
}

/// The reason a file was refused, without details. See [`ScanJsonError`].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScanJsonErrorKind {
    EmptyFile,
    TooLarge,
    InvalidJson,
    NotAnObject,
    MissingField,
    WrongType,
    EmptyOcrText,
    InvalidDocumentId,
    InvalidDate,
    EmptyFileName,
    UnsupportedSchemaVersion,
}

/// Why a file was refused: the kind, plus the details that belong to it (the
/// others stay `None`). Flat on purpose: it crosses the bridge without
/// needing a code generator for data-carrying enums.
///
/// - `field`: `MissingField`, `WrongType`, `EmptyFileName`.
/// - `line`, `column`: `InvalidJson` (1-based).
/// - `size`, `limit`: `TooLarge`, in bytes.
/// - `found_version`, `known_version`: `UnsupportedSchemaVersion`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ScanJsonError {
    pub kind: ScanJsonErrorKind,
    pub field: Option<String>,
    pub line: Option<u32>,
    pub column: Option<u32>,
    pub size: Option<i64>,
    pub limit: Option<i64>,
    pub found_version: Option<i64>,
    pub known_version: Option<u32>,
}

impl ScanJsonError {
    fn of(kind: ScanJsonErrorKind) -> Self {
        Self {
            kind,
            field: None,
            line: None,
            column: None,
            size: None,
            limit: None,
            found_version: None,
            known_version: None,
        }
    }
}

impl From<Problem> for ScanJsonError {
    fn from(problem: Problem) -> Self {
        use ScanJsonErrorKind as K;
        match problem {
            Problem::EmptyFile => Self::of(K::EmptyFile),
            Problem::TooLarge { size, limit } => Self {
                size: Some(i64::try_from(size).unwrap_or(i64::MAX)),
                limit: Some(i64::try_from(limit).unwrap_or(i64::MAX)),
                ..Self::of(K::TooLarge)
            },
            Problem::InvalidJson { line, column } => Self {
                line: Some(line),
                column: Some(column),
                ..Self::of(K::InvalidJson)
            },
            Problem::NotAnObject => Self::of(K::NotAnObject),
            Problem::MissingField { field } => Self {
                field: Some(field),
                ..Self::of(K::MissingField)
            },
            Problem::WrongType { field } => Self {
                field: Some(field),
                ..Self::of(K::WrongType)
            },
            Problem::EmptyOcrText => Self::of(K::EmptyOcrText),
            Problem::InvalidDocumentId => Self::of(K::InvalidDocumentId),
            Problem::InvalidDate => Self::of(K::InvalidDate),
            Problem::EmptyFileName { field } => Self {
                field: Some(field),
                ..Self::of(K::EmptyFileName)
            },
            Problem::UnsupportedSchemaVersion { found, known } => Self {
                found_version: Some(found),
                known_version: Some(known),
                ..Self::of(K::UnsupportedSchemaVersion)
            },
        }
    }
}

/// Parses one Scan JSON file given as text. A leading UTF-8 BOM is removed.
pub fn parse_scan_json(text: String) -> Result<ParsedScan, ScanJsonError> {
    parse_inner(text).map_err(ScanJsonError::from)
}

fn parse_inner(text: String) -> Result<ParsedScan, Problem> {
    let size = text.len() as u64;
    if size > MAX_JSON_BYTES {
        return Err(Problem::TooLarge {
            size,
            limit: MAX_JSON_BYTES,
        });
    }
    let body = text.strip_prefix('\u{feff}').unwrap_or(&text);
    if body.trim().is_empty() {
        return Err(Problem::EmptyFile);
    }
    let value: Value = serde_json::from_str(body).map_err(|e| Problem::InvalidJson {
        line: u32::try_from(e.line()).unwrap_or(u32::MAX),
        column: u32::try_from(e.column()).unwrap_or(u32::MAX),
    })?;
    let Value::Object(map) = value else {
        return Err(Problem::NotAnObject);
    };
    if has_value(&map, "schemaVersion") {
        parse_canonical(&map)
    } else if has_value(&map, "ocr_text") {
        parse_legacy(&map)
    } else {
        Err(missing("schemaVersion"))
    }
}

fn has_value(map: &Map<String, Value>, key: &str) -> bool {
    matches!(map.get(key), Some(v) if !v.is_null())
}

fn missing(field: &str) -> Problem {
    Problem::MissingField {
        field: field.to_string(),
    }
}

fn wrong_type(field: &str) -> Problem {
    Problem::WrongType {
        field: field.to_string(),
    }
}

fn required_string(map: &Map<String, Value>, field: &str) -> Result<String, Problem> {
    match map.get(field) {
        None | Some(Value::Null) => Err(missing(field)),
        Some(Value::String(s)) => Ok(s.clone()),
        Some(_) => Err(wrong_type(field)),
    }
}

fn optional_string(map: &Map<String, Value>, field: &str) -> Result<Option<String>, Problem> {
    match map.get(field) {
        None | Some(Value::Null) => Ok(None),
        Some(Value::String(s)) => Ok(Some(s.clone())),
        Some(_) => Err(wrong_type(field)),
    }
}

fn parse_canonical(map: &Map<String, Value>) -> Result<ParsedScan, Problem> {
    let version = match map.get("schemaVersion") {
        Some(Value::Number(n)) => {
            if let Some(v) = n.as_i64() {
                v
            } else if n.is_u64() {
                i64::MAX
            } else {
                // A whole number too big for i64 is parsed as f64: still an
                // integer, and certainly a version this parser does not know.
                match n.as_f64() {
                    Some(f) if f.is_finite() && f.fract() == 0.0 && f.abs() >= 9.0e18 => {
                        if f > 0.0 {
                            i64::MAX
                        } else {
                            i64::MIN
                        }
                    }
                    _ => return Err(wrong_type("schemaVersion")),
                }
            }
        }
        _ => return Err(wrong_type("schemaVersion")),
    };
    if version < 1 || version > i64::from(SUPPORTED_SCHEMA_VERSION) {
        return Err(Problem::UnsupportedSchemaVersion {
            found: version,
            known: SUPPORTED_SCHEMA_VERSION,
        });
    }
    let document_id = required_string(map, "documentId")?;
    let created = required_string(map, "createdAt")?;
    let ocr_text = required_string(map, "ocrText")?;
    let language = optional_string(map, "language")?;
    let pdf = optional_string(map, "pdfPath")?;
    let images = optional_string_list(map, "imagePaths")?;
    build(
        SUPPORTED_SCHEMA_VERSION,
        document_id,
        &created,
        ocr_text,
        language,
        pdf.as_deref().map(|p| ("pdfPath", p)),
        images,
        false,
    )
}

fn parse_legacy(map: &Map<String, Value>) -> Result<ParsedScan, Problem> {
    let created = required_string(map, "created")?;
    let ocr_text = required_string(map, "ocr_text")?;
    let pdf = optional_string(map, "pdf_path")?;
    let images = optional_string_list(map, "image_paths")?;
    let document_id = legacy_document_id(&created, &ocr_text);
    build(
        SUPPORTED_SCHEMA_VERSION,
        document_id,
        &created,
        ocr_text,
        None,
        pdf.as_deref().map(|p| ("pdf_path", p)),
        images,
        true,
    )
}

/// `legacy-` plus the first 32 hex characters of SHA-256 over `created`, a
/// newline and `ocr_text`: stable for the same content.
fn legacy_document_id(created: &str, ocr_text: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(created.as_bytes());
    hasher.update(b"\n");
    hasher.update(ocr_text.as_bytes());
    let digest = hasher.finalize();
    let mut hex = String::with_capacity(32);
    for byte in digest.iter().take(16) {
        hex.push(hex_digit(byte >> 4));
        hex.push(hex_digit(byte & 0x0f));
    }
    format!("legacy-{hex}")
}

fn hex_digit(n: u8) -> char {
    char::from_digit(u32::from(n), 16).unwrap_or('0')
}

fn optional_string_list(
    map: &Map<String, Value>,
    field: &str,
) -> Result<Vec<(String, String)>, Problem> {
    match map.get(field) {
        None | Some(Value::Null) => Ok(Vec::new()),
        Some(Value::Array(items)) => items
            .iter()
            .map(|item| match item {
                Value::String(s) => Ok((field.to_string(), s.clone())),
                _ => Err(wrong_type(field)),
            })
            .collect(),
        Some(_) => Err(wrong_type(field)),
    }
}

#[allow(clippy::too_many_arguments)]
fn build(
    schema_version: u32,
    document_id: String,
    created: &str,
    ocr_text: String,
    language: Option<String>,
    pdf: Option<(&str, &str)>,
    images: Vec<(String, String)>,
    was_legacy: bool,
) -> Result<ParsedScan, Problem> {
    let document_id = document_id.trim().to_string();
    let id_chars = document_id.chars().count();
    if id_chars == 0 || id_chars > MAX_DOCUMENT_ID_CHARS {
        return Err(Problem::InvalidDocumentId);
    }
    if ocr_text.trim().is_empty() {
        return Err(Problem::EmptyOcrText);
    }
    let (created_at_utc_ms, created_at_local) = match parse_created_at(created)? {
        Created::Instant { utc_ms } => (Some(utc_ms), None),
        Created::Local { text } => (None, Some(text)),
    };
    let language = language
        .map(|l| l.trim().to_string())
        .filter(|l| !l.is_empty());
    let pdf_name = match pdf {
        Some((field, value)) => Some(file_name(field, value)?),
        None => None,
    };
    let mut image_names = Vec::with_capacity(images.len());
    for (field, value) in &images {
        image_names.push(file_name(field, value)?);
    }
    Ok(ParsedScan {
        schema_version,
        document_id,
        created_at_utc_ms,
        created_at_local,
        ocr_text,
        language,
        pdf_name,
        image_names,
        was_legacy,
    })
}

/// The last segment after `/` or `\`, trimmed. Only a label, never a path.
fn file_name(field: &str, value: &str) -> Result<String, Problem> {
    let name = value
        .rsplit(['/', '\\'])
        .next()
        .unwrap_or_default()
        .trim()
        .to_string();
    if name.is_empty() {
        return Err(Problem::EmptyFileName {
            field: field.to_string(),
        });
    }
    Ok(name)
}

/// ISO 8601 date and time: `yyyy-MM-dd`, `T` or a space, `HH:mm`, optional
/// `:ss` and fraction, optional `Z` or `+HH[:mm]` / `-HH[:mm]` / `+HHmm`.
fn parse_created_at(input: &str) -> Result<Created, Problem> {
    let s = input.trim();
    if !s.is_ascii() {
        return Err(Problem::InvalidDate);
    }
    let mut cur = Cursor {
        bytes: s.as_bytes(),
        pos: 0,
    };
    let year = cur.digits(4)?;
    cur.expect(b'-')?;
    let month = cur.digits(2)?;
    cur.expect(b'-')?;
    let day = cur.digits(2)?;
    if !(1..=12).contains(&month) || day < 1 || day > days_in_month(year, month) {
        return Err(Problem::InvalidDate);
    }
    match cur.next() {
        Some(b'T') | Some(b't') | Some(b' ') => {}
        _ => return Err(Problem::InvalidDate),
    }
    let hour = cur.digits(2)?;
    cur.expect(b':')?;
    let minute = cur.digits(2)?;
    let mut second = 0;
    let mut millis = 0;
    if cur.peek() == Some(b':') {
        cur.pos += 1;
        second = cur.digits(2)?;
        if matches!(cur.peek(), Some(b'.') | Some(b',')) {
            cur.pos += 1;
            millis = cur.fraction_millis()?;
        }
    }
    if hour > 23 || minute > 59 || second > 59 {
        return Err(Problem::InvalidDate);
    }
    let offset_seconds = match cur.next() {
        None => {
            return Ok(Created::Local {
                text: format!("{year:04}-{month:02}-{day:02}T{hour:02}:{minute:02}:{second:02}"),
            });
        }
        Some(b'Z') | Some(b'z') => 0,
        Some(sign @ (b'+' | b'-')) => {
            let oh = cur.digits(2)?;
            let colon = cur.peek() == Some(b':');
            if colon {
                cur.pos += 1;
            }
            // `+03` has no minutes; after a colon or any further character
            // two digits are required.
            let om = if colon || cur.peek().is_some() {
                cur.digits(2)?
            } else {
                0
            };
            if oh > 23 || om > 59 {
                return Err(Problem::InvalidDate);
            }
            let total = oh * 3600 + om * 60;
            if sign == b'+' {
                total
            } else {
                -total
            }
        }
        _ => return Err(Problem::InvalidDate),
    };
    if cur.peek().is_some() {
        return Err(Problem::InvalidDate);
    }
    let days = days_from_civil(year, month, day);
    let seconds = days * 86_400 + hour * 3600 + minute * 60 + second - offset_seconds;
    Ok(Created::Instant {
        utc_ms: seconds * 1000 + millis,
    })
}

struct Cursor<'a> {
    bytes: &'a [u8],
    pos: usize,
}

impl Cursor<'_> {
    fn peek(&self) -> Option<u8> {
        self.bytes.get(self.pos).copied()
    }

    fn next(&mut self) -> Option<u8> {
        let b = self.peek();
        if b.is_some() {
            self.pos += 1;
        }
        b
    }

    fn expect(&mut self, wanted: u8) -> Result<(), Problem> {
        if self.next() == Some(wanted) {
            Ok(())
        } else {
            Err(Problem::InvalidDate)
        }
    }

    /// Exactly `count` ASCII digits.
    fn digits(&mut self, count: usize) -> Result<i64, Problem> {
        let mut value: i64 = 0;
        for _ in 0..count {
            match self.next() {
                Some(b) if b.is_ascii_digit() => value = value * 10 + i64::from(b - b'0'),
                _ => return Err(Problem::InvalidDate),
            }
        }
        Ok(value)
    }

    /// One or more digits after the decimal point, as milliseconds
    /// (truncated).
    fn fraction_millis(&mut self) -> Result<i64, Problem> {
        let mut digits = 0;
        let mut millis = 0;
        while let Some(b) = self.peek() {
            if !b.is_ascii_digit() {
                break;
            }
            if digits < 3 {
                millis = millis * 10 + i64::from(b - b'0');
            }
            digits += 1;
            self.pos += 1;
        }
        if digits == 0 {
            return Err(Problem::InvalidDate);
        }
        for _ in digits..3 {
            millis *= 10;
        }
        Ok(millis)
    }
}

fn is_leap_year(year: i64) -> bool {
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

fn days_in_month(year: i64, month: i64) -> i64 {
    match month {
        2 if is_leap_year(year) => 29,
        2 => 28,
        4 | 6 | 9 | 11 => 30,
        _ => 31,
    }
}

/// Days since 1970-01-01 of a proleptic Gregorian date.
fn days_from_civil(year: i64, month: i64, day: i64) -> i64 {
    let y = if month <= 2 { year - 1 } else { year };
    let era = (if y >= 0 { y } else { y - 399 }) / 400;
    let yoe = y - era * 400;
    let mp = if month > 2 { month - 3 } else { month + 9 };
    let doy = (153 * mp + 2) / 5 + day - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    era * 146_097 + doe - 719_468
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used, clippy::indexing_slicing)]
mod tests {
    use super::*;

    fn fixture(name: &str) -> String {
        let path = format!(
            "{}/../test/fixtures/scan_json/{name}",
            env!("CARGO_MANIFEST_DIR")
        );
        std::fs::read_to_string(&path).unwrap_or_else(|e| panic!("{path}: {e}"))
    }

    fn parse(name: &str) -> Result<ParsedScan, Problem> {
        parse_inner(fixture(name))
    }

    fn json(extra: &str) -> String {
        // A valid document with the given extra members appended.
        format!(
            r#"{{"schemaVersion":1,"documentId":"d1","createdAt":"2026-10-18T09:41:07+03:00","ocrText":"Hello"{extra}}}"#
        )
    }

    fn err(text: String) -> Problem {
        match parse_inner(text) {
            Ok(_) => panic!("expected an error"),
            Err(e) => e,
        }
    }

    fn instant(p: &ParsedScan) -> i64 {
        assert_eq!(p.created_at_local, None);
        p.created_at_utc_ms.expect("expected an instant")
    }

    fn local(p: &ParsedScan) -> &str {
        assert_eq!(p.created_at_utc_ms, None);
        p.created_at_local.as_deref().expect("expected local time")
    }

    // ----- canonical format

    #[test]
    fn full_canonical_document() {
        let p = parse("valid_v1_full.json").unwrap();
        assert_eq!(p.schema_version, 1);
        assert_eq!(p.document_id, "3f2b6c1e-8a5d-4a43-9d1e-6f0c2a7b9e10");
        assert!(p.ocr_text.starts_with("ΔΕΗ Α.Ε."));
        assert_eq!(p.language.as_deref(), Some("el"));
        assert_eq!(p.pdf_name.as_deref(), Some("scan-2026-10-18-0941.pdf"));
        assert_eq!(
            p.image_names,
            vec!["scan-2026-10-18-0941-1.jpg", "scan-2026-10-18-0941-2.jpg"]
        );
        assert!(!p.was_legacy);
        // 2026-10-18T09:41:07+03:00 = 06:41:07 UTC.
        assert_eq!(instant(&p), 1_792_305_667_000);
    }

    #[test]
    fn minimal_canonical_document() {
        let p = parse("valid_v1_minimal.json").unwrap();
        assert_eq!(p.document_id, "min-1");
        assert_eq!(p.language, None);
        assert_eq!(p.pdf_name, None);
        assert!(p.image_names.is_empty());
    }

    #[test]
    fn unknown_fields_are_ignored() {
        let p = parse("valid_v1_unknown_fields.json").unwrap();
        assert_eq!(p.document_id, "extra-1");
    }

    #[test]
    fn optional_fields_may_be_null_or_empty() {
        let p = parse_inner(json(r#","language":null,"pdfPath":null,"imagePaths":null"#)).unwrap();
        assert_eq!((p.language, p.pdf_name), (None, None));
        assert!(p.image_names.is_empty());
        let p = parse_inner(json(r#","imagePaths":[]"#)).unwrap();
        assert!(p.image_names.is_empty());
    }

    #[test]
    fn language_is_trimmed_and_empty_means_absent() {
        let p = parse_inner(json(r#","language":"  en-GB ""#)).unwrap();
        assert_eq!(p.language.as_deref(), Some("en-GB"));
        let p = parse_inner(json(r#","language":"  ""#)).unwrap();
        assert_eq!(p.language, None);
        assert_eq!(err(json(r#","language":5"#)), wrong("language"));
    }

    #[test]
    fn file_names_are_cut_to_the_last_segment() {
        let p = parse_inner(json(
            r#","pdfPath":"/storage/emulated/0/Scan/a.pdf","imagePaths":["C:\\scans\\1.jpg","x/y/2.jpg","3.jpg"]"#
        ))
        .unwrap();
        assert_eq!(p.pdf_name.as_deref(), Some("a.pdf"));
        assert_eq!(p.image_names, vec!["1.jpg", "2.jpg", "3.jpg"]);
    }

    #[test]
    fn a_file_name_that_is_empty_after_cutting_is_refused() {
        assert_eq!(
            err(json(r#","pdfPath":"folder/""#)),
            Problem::EmptyFileName {
                field: "pdfPath".into()
            }
        );
        assert_eq!(
            err(json(r#","imagePaths":["ok.jpg","  "]"#)),
            Problem::EmptyFileName {
                field: "imagePaths".into()
            }
        );
    }

    #[test]
    fn document_id_is_trimmed() {
        let p = parse_inner(json("").replace(r#""d1""#, r#""  d1  ""#)).unwrap();
        assert_eq!(p.document_id, "d1");
    }

    // ----- created_at

    #[test]
    fn created_at_with_z_and_with_offset_is_the_same_instant() {
        let z = parse_inner(
            json("")
                .replace("+03:00", "Z")
                .replace("09:41:07", "06:41:07"),
        )
        .unwrap();
        let plus = parse_inner(json("")).unwrap();
        assert_eq!(instant(&z), instant(&plus));
        let compact = parse_inner(json("").replace("+03:00", "+0300")).unwrap();
        assert_eq!(instant(&compact), instant(&plus));
        let short = parse_inner(json("").replace("+03:00", "+03")).unwrap();
        assert_eq!(instant(&short), instant(&plus));
        let minus = parse_inner(json("").replace("09:41:07+03:00", "01:41:07-05:00")).unwrap();
        assert_eq!(instant(&minus), instant(&plus));
    }

    #[test]
    fn created_at_without_offset_stays_local_text() {
        let p = parse_inner(json("").replace("+03:00", "")).unwrap();
        assert_eq!(local(&p), "2026-10-18T09:41:07");
        // No seconds, a space as separator and a fraction.
        let p =
            parse_inner(json("").replace("2026-10-18T09:41:07+03:00", "2026-10-18 09:41")).unwrap();
        assert_eq!(local(&p), "2026-10-18T09:41:00");
    }

    #[test]
    fn fraction_gives_milliseconds() {
        let base = parse_inner(json("")).unwrap();
        let frac = parse_inner(json("").replace("09:41:07+", "09:41:07.123456+")).unwrap();
        assert_eq!(instant(&frac), instant(&base) + 123);
        let short = parse_inner(json("").replace("09:41:07+", "09:41:07.5+")).unwrap();
        assert_eq!(instant(&short), instant(&base) + 500);
    }

    #[test]
    fn epoch_and_leap_day() {
        let p = parse_inner(json("").replace("2026-10-18T09:41:07+03:00", "1970-01-01T00:00:00Z"))
            .unwrap();
        assert_eq!(instant(&p), 0);
        let p = parse_inner(json("").replace("2026-10-18T09:41:07+03:00", "2024-02-29T00:00:00Z"))
            .unwrap();
        assert_eq!(instant(&p), 1_709_164_800_000);
    }

    #[test]
    fn bad_dates_are_refused() {
        for bad in [
            "",
            "yesterday",
            "2026-10-18",
            "2026-13-01T00:00:00Z",
            "2026-02-29T00:00:00Z",
            "2026-04-31T00:00:00Z",
            "2026-10-18T24:00:00Z",
            "2026-10-18T09:60:00Z",
            "2026-10-18T09:41:60Z",
            "2026-10-18T09:41:07+24:00",
            "2026-10-18T09:41:07+03:",
            "2026-10-18T09:41:07.Z",
            "2026-10-18T09:41:07Zjunk",
            "2026-10-18T09:41:07 PM",
            "26-10-18T09:41:07Z",
            "2026-10-18Τ09:41:07Z",
        ] {
            let text = json("").replace("2026-10-18T09:41:07+03:00", bad);
            assert_eq!(err(text), Problem::InvalidDate, "date {bad:?}");
        }
    }

    // ----- legacy reader

    #[test]
    fn legacy_document_is_converted() {
        let p = parse("legacy_full.json").unwrap();
        assert!(p.was_legacy);
        assert_eq!(p.schema_version, 1);
        assert!(p.document_id.starts_with("legacy-"));
        assert_eq!(p.document_id.len(), "legacy-".len() + 32);
        assert!(p.document_id["legacy-".len()..]
            .chars()
            .all(|c| c.is_ascii_hexdigit()));
        assert_eq!(p.language, None);
        assert_eq!(p.pdf_name.as_deref(), Some("old-scan.pdf"));
        assert_eq!(p.image_names, vec!["old-1.jpg", "old-2.jpg"]);
        assert_eq!(local(&p), "2026-10-18T09:41:07");
    }

    // ----- the public (flat) error

    #[test]
    fn the_public_function_returns_the_flat_error() {
        let wrong = parse_scan_json(json("").replace(r#""Hello""#, "5"))
            .err()
            .unwrap();
        assert_eq!(wrong.kind, ScanJsonErrorKind::WrongType);
        assert_eq!(wrong.field.as_deref(), Some("ocrText"));

        let version =
            parse_scan_json(json("").replace(r#""schemaVersion":1"#, r#""schemaVersion":2"#))
                .err()
                .unwrap();
        assert_eq!(version.kind, ScanJsonErrorKind::UnsupportedSchemaVersion);
        assert_eq!(
            (version.found_version, version.known_version),
            (Some(2), Some(1))
        );

        let bad = parse_scan_json("{\n oops".into()).err().unwrap();
        assert_eq!(bad.kind, ScanJsonErrorKind::InvalidJson);
        assert_eq!(bad.line, Some(2));

        let big = parse_scan_json("a".repeat(MAX_JSON_BYTES as usize + 1))
            .err()
            .unwrap();
        assert_eq!(big.kind, ScanJsonErrorKind::TooLarge);
        assert_eq!(big.size, Some(MAX_JSON_BYTES as i64 + 1));
        assert_eq!(big.limit, Some(MAX_JSON_BYTES as i64));

        let empty = parse_scan_json(String::new()).err().unwrap();
        assert_eq!(empty, ScanJsonError::of(ScanJsonErrorKind::EmptyFile));

        let ok = parse_scan_json(json("")).unwrap();
        assert_eq!(ok.document_id, "d1");
    }

    #[test]
    fn every_problem_has_a_kind() {
        use ScanJsonErrorKind as K;
        let cases = [
            (Problem::EmptyFile, K::EmptyFile),
            (Problem::TooLarge { size: 2, limit: 1 }, K::TooLarge),
            (Problem::InvalidJson { line: 1, column: 1 }, K::InvalidJson),
            (Problem::NotAnObject, K::NotAnObject),
            (Problem::MissingField { field: "f".into() }, K::MissingField),
            (Problem::WrongType { field: "f".into() }, K::WrongType),
            (Problem::EmptyOcrText, K::EmptyOcrText),
            (Problem::InvalidDocumentId, K::InvalidDocumentId),
            (Problem::InvalidDate, K::InvalidDate),
            (
                Problem::EmptyFileName { field: "f".into() },
                K::EmptyFileName,
            ),
            (
                Problem::UnsupportedSchemaVersion { found: 2, known: 1 },
                K::UnsupportedSchemaVersion,
            ),
        ];
        for (problem, kind) in cases {
            assert_eq!(ScanJsonError::from(problem).kind, kind);
        }
    }

    #[test]
    fn legacy_without_paths() {
        let p = parse("legacy_no_paths.json").unwrap();
        assert_eq!(p.pdf_name, None);
        assert!(p.image_names.is_empty());
    }

    #[test]
    fn legacy_absolute_paths_are_cut() {
        let p = parse("legacy_absolute_paths.json").unwrap();
        assert_eq!(p.pdf_name.as_deref(), Some("receipt.pdf"));
        assert_eq!(p.image_names, vec!["page1.jpg", "page2.jpg"]);
    }

    #[test]
    fn legacy_id_is_stable_and_follows_the_content() {
        let a = parse("legacy_full.json").unwrap().document_id;
        assert_eq!(a, parse("legacy_full.json").unwrap().document_id);
        let text = fixture("legacy_full.json");
        let other_created = text.replace("2026-10-18T09:41:07", "2026-10-18T09:41:08");
        assert_ne!(a, parse_inner(other_created).unwrap().document_id);
        let other_text = text.replace("ΣΥΝΟΛΟ", "ΣΥΝΟΛΟΝ");
        assert_ne!(a, parse_inner(other_text).unwrap().document_id);
        // Different paths, same content: the same document.
        let other_paths = text.replace("old-scan.pdf", "other.pdf");
        assert_eq!(a, parse_inner(other_paths).unwrap().document_id);
    }

    #[test]
    fn legacy_id_has_a_known_value() {
        let text = r#"{"version":1,"created":"c","ocr_text":"t"}"#.to_string();
        let sha = {
            let mut h = Sha256::new();
            h.update(b"c\nt");
            h.finalize()
        };
        let expected: String = sha.iter().take(16).map(|b| format!("{b:02x}")).collect();
        // "c" is not a date, so check the id through the helper.
        assert_eq!(legacy_document_id("c", "t"), format!("legacy-{expected}"));
        assert_eq!(err(text), Problem::InvalidDate);
    }

    #[test]
    fn legacy_is_validated_like_canonical() {
        let base = r#"{"version":1,"created":"2026-10-18T09:41:07","ocr_text":"x"}"#;
        assert!(parse_inner(base.to_string()).is_ok());
        assert_eq!(
            err(base.replace(r#""x""#, r#""  ""#)),
            Problem::EmptyOcrText
        );
        assert_eq!(err(base.replace(r#""x""#, "5")), wrong("ocr_text"));
        assert_eq!(
            err(base.replace(r#""created":"2026-10-18T09:41:07","#, "")),
            missing_field("created")
        );
        assert_eq!(
            err(base.replace("}", r#","image_paths":"a.jpg"}"#)),
            wrong("image_paths")
        );
    }

    #[test]
    fn a_file_with_schema_version_is_not_read_as_legacy() {
        let text = r#"{"schemaVersion":1,"ocr_text":"x","created":"2026-10-18T09:41:07"}"#;
        assert_eq!(err(text.to_string()), missing_field("documentId"));
    }

    // ----- malformed input

    fn wrong(field: &str) -> Problem {
        Problem::WrongType {
            field: field.into(),
        }
    }

    fn missing_field(field: &str) -> Problem {
        Problem::MissingField {
            field: field.into(),
        }
    }

    #[test]
    fn empty_and_blank_files() {
        assert_eq!(err(String::new()), Problem::EmptyFile);
        assert_eq!(err("  \n\t ".into()), Problem::EmptyFile);
        assert_eq!(err("\u{feff}".into()), Problem::EmptyFile);
        assert_eq!(
            err(fixture("malformed_empty_file.json")),
            Problem::EmptyFile
        );
    }

    #[test]
    fn invalid_json_reports_the_position() {
        match err("{\n  \"schemaVersion\": 1,\n  oops\n}".into()) {
            Problem::InvalidJson { line, column } => {
                assert_eq!(line, 3);
                assert!(column >= 3);
            }
            other => panic!("{other:?}"),
        }
        assert!(matches!(
            err(fixture("malformed_invalid_json.json")),
            Problem::InvalidJson { .. }
        ));
        assert!(matches!(
            err("not json".into()),
            Problem::InvalidJson { .. }
        ));
        assert!(matches!(err("{\"a\":".into()), Problem::InvalidJson { .. }));
    }

    #[test]
    fn deeply_nested_json_is_an_error_not_a_crash() {
        let deep = format!("{}1{}", "[".repeat(5000), "]".repeat(5000));
        assert!(matches!(err(deep), Problem::InvalidJson { .. }));
    }

    #[test]
    fn the_top_level_must_be_an_object() {
        assert_eq!(err("[1,2]".into()), Problem::NotAnObject);
        assert_eq!(err("\"text\"".into()), Problem::NotAnObject);
        assert_eq!(err("42".into()), Problem::NotAnObject);
        assert_eq!(err("null".into()), Problem::NotAnObject);
        assert_eq!(
            err(fixture("malformed_not_object.json")),
            Problem::NotAnObject
        );
    }

    #[test]
    fn an_object_with_neither_format_misses_the_schema_version() {
        assert_eq!(err("{}".into()), missing_field("schemaVersion"));
        assert_eq!(
            err(r#"{"schemaVersion":null}"#.into()),
            missing_field("schemaVersion")
        );
    }

    #[test]
    fn missing_required_fields() {
        for (drop, field) in [
            (r#""documentId":"d1","#, "documentId"),
            (r#""createdAt":"2026-10-18T09:41:07+03:00","#, "createdAt"),
            (r#","ocrText":"Hello""#, "ocrText"),
        ] {
            assert_eq!(
                err(json("").replace(drop, "")),
                missing_field(field),
                "{field}"
            );
        }
        assert_eq!(
            err(json("").replace(r#""documentId":"d1""#, r#""documentId":null"#)),
            missing_field("documentId")
        );
    }

    #[test]
    fn wrong_types() {
        assert_eq!(err(json("").replace(r#""Hello""#, "5")), wrong("ocrText"));
        assert_eq!(err(json("").replace(r#""d1""#, "7")), wrong("documentId"));
        assert_eq!(
            err(json("").replace(r#""2026-10-18T09:41:07+03:00""#, "20261018")),
            wrong("createdAt")
        );
        assert_eq!(err(json(r#","imagePaths":"a.jpg""#)), wrong("imagePaths"));
        assert_eq!(
            err(json(r#","imagePaths":["a.jpg",3]"#)),
            wrong("imagePaths")
        );
        assert_eq!(err(json(r#","pdfPath":12"#)), wrong("pdfPath"));
        assert_eq!(
            err(json("").replace(r#""schemaVersion":1"#, r#""schemaVersion":"1""#)),
            wrong("schemaVersion")
        );
        assert_eq!(
            err(json("").replace(r#""schemaVersion":1"#, r#""schemaVersion":1.5"#)),
            wrong("schemaVersion")
        );
        assert_eq!(
            err(json("").replace(r#""schemaVersion":1"#, r#""schemaVersion":true"#)),
            wrong("schemaVersion")
        );
        assert_eq!(err(fixture("malformed_wrong_type.json")), wrong("ocrText"));
    }

    #[test]
    fn empty_ocr_text() {
        assert_eq!(err(json("").replace("Hello", "")), Problem::EmptyOcrText);
        assert_eq!(
            err(json("").replace("Hello", "  \\n\\t ")),
            Problem::EmptyOcrText
        );
        assert_eq!(
            err(fixture("malformed_empty_ocr.json")),
            Problem::EmptyOcrText
        );
    }

    #[test]
    fn document_id_limits() {
        assert_eq!(
            err(json("").replace(r#""d1""#, r#""""#)),
            Problem::InvalidDocumentId
        );
        assert_eq!(
            err(json("").replace(r#""d1""#, r#""   ""#)),
            Problem::InvalidDocumentId
        );
        let long = format!("\"{}\"", "x".repeat(129));
        assert_eq!(
            err(json("").replace(r#""d1""#, &long)),
            Problem::InvalidDocumentId
        );
        let ok = format!("\"{}\"", "x".repeat(128));
        assert!(parse_inner(json("").replace(r#""d1""#, &ok)).is_ok());
        // 128 characters, more than 128 bytes.
        let greek = format!("\"{}\"", "ά".repeat(128));
        assert!(parse_inner(json("").replace(r#""d1""#, &greek)).is_ok());
    }

    #[test]
    fn unsupported_schema_versions() {
        for (version, found) in [
            ("2", 2),
            ("0", 0),
            ("-1", -1),
            ("99999999999999999999", i64::MAX),
        ] {
            let text = json("").replace(
                r#""schemaVersion":1"#,
                &format!(r#""schemaVersion":{version}"#),
            );
            assert_eq!(
                err(text),
                Problem::UnsupportedSchemaVersion { found, known: 1 },
                "version {version}"
            );
        }
        assert_eq!(
            err(fixture("malformed_schema_v2.json")),
            Problem::UnsupportedSchemaVersion { found: 2, known: 1 }
        );
    }

    #[test]
    fn a_newer_version_is_refused_before_the_other_fields_are_looked_at() {
        // A future format may have changed other fields, so only the version is reported.
        let text = r#"{"schemaVersion":2,"somethingNew":true}"#;
        assert_eq!(
            err(text.into()),
            Problem::UnsupportedSchemaVersion { found: 2, known: 1 }
        );
    }

    // ----- size, BOM

    #[test]
    fn the_size_limit() {
        let doc = |filler: usize| {
            format!(
                r#"{{"schemaVersion":1,"documentId":"d","createdAt":"2026-10-18T09:41:07Z","ocrText":"{}"}}"#,
                "a".repeat(filler)
            )
        };
        let at_limit = doc(MAX_JSON_BYTES as usize - doc(0).len());
        assert_eq!(at_limit.len() as u64, MAX_JSON_BYTES);
        assert!(parse_inner(at_limit.clone()).is_ok());

        let over = format!("{at_limit} ");
        assert_eq!(
            err(over),
            Problem::TooLarge {
                size: MAX_JSON_BYTES + 1,
                limit: MAX_JSON_BYTES
            }
        );
    }

    #[test]
    fn a_utf8_bom_is_removed() {
        let with_bom = format!("\u{feff}{}", json(""));
        assert!(parse_inner(with_bom).is_ok());
        let legacy = format!(
            "\u{feff}{}",
            r#"{"version":1,"created":"2026-10-18T09:41:07","ocr_text":"x"}"#
        );
        assert!(parse_inner(legacy).is_ok());
    }

    #[test]
    fn greek_text_round_trips() {
        let p = parse("valid_v1_full.json").unwrap();
        assert!(p.ocr_text.contains("ΠΛΗΡΩΤΕΟ 84,20 EUR"));
    }
}
