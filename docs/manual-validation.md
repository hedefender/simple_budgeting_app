# Manual validation: Phase 0

Prerequisite: `flutter pub get`, `build_runner`, `flutter analyze` and
`flutter test` all pass (see README).

## 1. First run (database creation)

1. Uninstall any previous build, then `flutter run` on the emulator/phone.
2. Expected: splash with title and progress bar, then the "Foundation check" screen.
3. Check on screen: `Launch #1`, a first-launch date, "This startup took N ms",
   "No previous startup recorded yet".

## 2. Persistence

1. Force-close the app (swipe from recents), open it again.
2. Expected: `Launch #2`, same first-launch date, and "Previous startup took N ms"
   equal to the startup time shown the first time.
3. Repeat; the number must keep increasing.
4. Hot restart during `flutter run` (`R`) also counts as a launch of the
   bootstrapper; that is fine.

## 3. Cold-start timing

In-app number (dart-side bootstrap only): "This startup took N ms".

Whole-process cold start on a release-like build:

```bash
flutter build apk --profile      # or: flutter run --profile
adb shell am force-stop com.example.simple_budgeting_app
adb shell am start -W -n com.example.simple_budgeting_app/.MainActivity
```

Read `TotalTime` (ms) in the output. Record a few runs on your phone and on the
emulator. Decision guide:

- Bootstrap number under ~200 ms and TotalTime comfortable: the splash can later
  be shortened or hidden for fast starts.
- Bootstrap number high or growing as migrations accumulate: keep the splash.

Debug builds are much slower than profile/release; judge only profile/release.

## 4. Locale and language

1. Android Settings -> System -> Languages: set **Greek (Greece)** first.
2. Reopen the app. Expected: Greek texts, `Εκκίνηση #N`, locale `el_GR`,
   currency `EUR`, sample amount like `1.234,56 €`.
3. Switch to **English (United States)**: English texts, `USD`, `$1,234.56`.
4. Switch to **English (Greece)** if your device offers it: English texts, currency `EUR`.
   (Region decides the currency; language only decides the text.)
5. Any other language falls back to English text.

## 5. Failure path (optional)

Temporarily make `openDatabase` throw (add `throw StateError('test');` in
`service_locator.dart`), run the app, and check: no crash, title text, a
"Something went wrong" message and a working "Try again" button. Remove the throw.

## 6. Airplane mode

Turn on airplane mode and repeat step 2. Everything must work identically (the
app never uses the network; note that the first Gradle build needs internet).

## 7. Phase 0b: Rust core

Prerequisite: `cargo test --manifest-path rust/Cargo.toml` passes.

1. `flutter run -d <emulator-id>` (x86_64 emulator). The first build is slow because cargo compiles the crate.
2. Splash shows "Starting the calculation engine…" (Greek: "Εκκίνηση της μηχανής υπολογισμών…") first, briefly.
3. Home shows `Rust core: v0.1.0 (x86_64-android)` (Greek: `Πυρήνας Rust: v0.1.0 (x86_64-android)`).
4. Hot restart (`R`) must not crash (the native library is not initialized twice).
5. "This startup took N ms" now includes loading the native library. Note the value before (Phase 0a) and after.
6. Run `flutter test integration_test/cold_start_test.dart -d <device-id>`: both tests pass.
7. Failure path (optional): make `_initRustLib` in `service_locator.dart` throw once, check the retry button
   works, then remove the throw.
8. On a physical ARM phone the app cannot run yet unless arm targets are built (see roadmap).

## 8. Phase 1a: income

Prerequisite: `flutter analyze`, `flutter test` and `cargo test` pass; on a device,
`flutter test integration_test/income_persistence_test.dart -d <device-id>` passes.

1. `flutter run -d <emulator-id>`. A bottom bar with **Home** and **Income** appears; Home is unchanged.
2. Income tab, empty state: "No income sources yet", the month label shows the current month, the cards show 0.
3. Add a source with **+**: name "Salary", type Salary, amount `1.234,56` (Greek) or `1,234.50` (English),
   Monthly, day 31, start today. Save.
   - Invalid input shows errors: empty name, `abc`, `0`, `1,234` with 2-decimal currency rules (see the
     message), an end date before the start date.
   - In a Greek locale `12.50` is accepted as 12,50.
4. The source appears in the list. Go to February (arrows): the payment is on the 28th (29th in a leap year).
5. Past months: payments dated today or earlier are "Received"; later ones are "Expected".
6. On a payment, open the menu:
   - **Change amount**: only that payment changes; other months stay the same.
   - **Mark as not received**: the amount is struck through and leaves the totals.
   - **Restore planned payment** brings it back.
7. Edit the source and change its amount: earlier months keep the old amount, later months use the new one.
8. **Set balance**: enter an amount and a date (balance at the END of that day). Income dated after that day is
   added on top; income on that day is not added again. A date inside the month changes that month's result.
9. Archive the source: it leaves the list, past payments stay, no new ones appear after today.
10. Force-close and reopen: sources, changed amounts and the balance are still there.
11. Switch the device to Greek and back: all texts translate; amounts follow the region's currency.

## 9. Phase 1b: schedule engine

Prerequisite: `flutter analyze`, `flutter test` and `cargo test` pass; on a device, both integration tests pass.
Use a fresh install or the existing data of step 8. Today's date matters for "received" vs "expected".

1. Add a source, **Monthly**, day 1, shift "Pay on the previous working day". Go to a month whose 1st is a
   Saturday or Sunday (for example November 2026): the payment shows on the Friday before, in the PREVIOUS month
   (October 30). The previous month's total includes it.
2. Same source with "Do not move": the payment stays on the 1st, even on a weekend.
3. Day 25 around 25 March (a holiday) with "previous working day": March shows the 24th (or the 23rd if the 24th is a
   weekend). With "next working day": the 26th.
4. **Last day of the month** with "next working day" when the month ends on a weekend: the payment moves to the next
   month (for example October 31, 2026 -> November 2).
5. **Working day of the month** (for example 3): the 3rd working day, skipping weekends and holidays (January 2026:
   Jan 7). The shift field disappears when the only rule is a working day; it comes back when you choose another type.
6. **Several a month**: two payment days appear. Add a third, remove it again (the remove button shows only when
   there are more than two). Make two days equal, save: "Two payment days are the same". Fix and save.
7. **Weekly**, Friday: a month with five Fridays (October 2026) shows five payments. A Friday holiday
   (1 May 2026) moves according to the shift rule, possibly into the neighbouring month.
8. The source list shows an understandable summary for every kind (for example "Every Friday", "Monthly on day 1,
   day 15", "Monthly, working day 3"), in Greek and English.
9. Open a payment menu -> "Change amount or date". Change only the amount: the date does not change. Change the date:
   the payment moves (also to another month) and keeps its tile. "Restore planned payment" brings it back.
10. Edit a source (change its amount): earlier months and the dates they were paid on do not change.
11. Skip a payment that was shifted into another month: it is shown as "Not received" in the month where it is paid.
12. Force-close and reopen: everything above is still there.
13. Upgrade check (only if you have an older install): install the Phase 1a build, create a source and change its
    amount once, then install this build over it. Sources and past payments are unchanged.
## Checklist

- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] First run shows Launch #1
- [ ] Counter increases after force-close
- [ ] Previous startup time appears from launch #2
- [ ] Greek and English both display correctly
- [ ] Currency follows device region
- [ ] `cargo test` green
- [ ] Home shows the Rust core line (en and el)
- [ ] Hot restart works with the Rust core
- [ ] Phase 1a steps 1-11 pass
- [ ] Phase 1b steps 1-13 pass
- [ ] Cold start time noted (profile build): ______ ms
