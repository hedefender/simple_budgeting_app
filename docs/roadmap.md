# Roadmap

## Current position

| Step | Status |
| --- | --- |
| Toolchain: Flutter 3.47.7, Dart 3.13.5, Android SDK, RustRover plugins, smoke test on a device | Done (2026-10-17) |
| Rust bridge smoke test (throwaway `flutter_rust_bridge_codegen create` project) | **Next** |
| Phase 0a: Flutter-only foundation (delivered zip) analyzes, tests and runs | Done (2026-10-17) |
| Phase 0b: add the Rust crate with a trivial function behind a domain interface | Waiting |
| Phase 1 and later | Not started |

Each step starts only after the owner confirms the previous one compiles and passes.

## Division of work: Rust vs Dart/Flutter

Rust is a stateless compute engine. Dart owns persistence (drift) and the UI.

| Phase | Goal | Dart / Flutter | Rust |
| --- | --- | --- | --- |
| 0a | Foundation | Clean architecture, drift, get_it, Riverpod, l10n, tests | - |
| 0b | Rust bridge | Domain interface and bridge adapter | Crate skeleton, version/ping function, `cargo test` |
| 1 | Income | Tables (UUID keys), recurring income rules, basic cash flow, entry UI | - |
| 2 | Expenses | Manual entry, editing, history, CRUD tests | - |
| 3 | JSON import | File picker, import records, malformed-input messages | Parse and validate Scan JSON (single, multi, malformed). Reuse the owner's working parser |
| 4 | Rule engine | Test dataset runner | Amount, date, vendor, VAT detection; keyword rules; confidence score; datasets for ΔΕΗ, ΕΥΔΑΠ, Cosmote, supermarket, περίπτερο |
| 5 | Categories | Category CRUD, manual override UI | Auto-category matching from rule output |
| 6 | Dashboards | drift aggregate queries and streams, charts (fl_chart or syncfusion_flutter_charts) | - |
| 7 | Local LLM | Model management UI | `AiParser` providers (Rule, Phi, Gemma, Llama), confidence-based fallback. Reuse the owner's working LLM code |
| 8 | Scan integration | Installed-app detection, Intents, deep/App Links, shared storage | - |
| 9 | Budget intelligence | Alerts and UI | Monthly prediction, anomaly detection |
| Later | Sync | Export/import UI, cloud-storage picker | Merge of exported change sets (UUIDs, timestamps, tombstones) |
| Final | Desktop version | Flutter desktop build sharing the same Dart and Rust code; sync through user-owned files or cloud storage | Same crate |

## Open decisions

1. **PC version technology: decided.** Every version is Flutter and the desktop version is the final phase,
   so persistence stays in Dart/drift.
2. **Final Android `applicationId` (needed before Phase 8, and before any Play upload).**
3. **Chart library (Phase 6).** Compare `fl_chart` and `syncfusion_flutter_charts`, including licensing.
4. **Model delivery on Android (Phase 7).** Bundled, side-loaded or downloaded.
   Downloading requires network access, which is otherwise out of scope.
5. **Sync design (later).** Conflict rules and the format for cloud-storage and file import.

## Rules for every phase

Architecture, implementation plan, source code, unit tests, integration tests, manual validation steps,
then wait for a successful compile and test run. Each phase leaves a runnable app.
