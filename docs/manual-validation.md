# Manual validation: Phase 0

Prerequisite: `flutter pub get`, `build_runner`, `flutter analyze` and
`flutter test` all pass (see README).

WARNING: `flutter test integration_test/... -d <device>` (and the same command without `-d` when only one device is
connected) installs the app again, which DELETES the app's data on that device (the next start shows `Launch #1`).
Run the on-device tests before the manual checks, or on a device whose data you do not need.

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
   (Region decides the language texts and the number format; the currency of the data is chosen in the app, see
   section 10.)
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
11. Switch the device to Greek and back: all texts translate and the number format follows the region (the currency
    of each amount stays the currency of its source, see section 10).

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
## 10. Phase 1c: currency handling

Prerequisite: `flutter analyze`, `flutter test` and `cargo test` pass. Start from a fresh install (`Launch #1`) or the
data of step 9. Remember the warning at the top about on-device tests.

1. Fresh install, device in Greek (el_GR): open the settings icon (top right of Home and Income). "Primary currency"
   shows `EUR`.
2. Add a source "Salary" `1.000,00`: the currency field shows `EUR` (the primary). Save. The Income page shows one
   `EUR` card.
3. Change the device region to English (United States) (USD) and reopen the app. The `EUR` payment and the `EUR`
   card are still there (before Phase 1c the page showed 0 and "No payments this month"). The primary is still
   `EUR`.
4. Add a source "Bonus" `500.00` and choose `USD` in the currency field. Two cards appear: `EUR` first (the primary),
   then `USD`. The payment list holds both payments, each in its own currency. Nothing is added across currencies.
5. Edit "Salary": the currency is shown but cannot be changed.
6. **Set balance** in the `USD` card: the dialog starts in `USD` and lets you switch to `EUR`. After saving, only that
   currency's closing balance changes.
7. Settings: change the primary currency to `USD`. Back on Income, the `USD` card is now first. Existing sources keep
   their currency. A new source defaults to `USD`.
8. Settings -> Other...: type `chf` -> saved as `CHF`. Type `ab` -> "Enter a 3-letter currency code". An unused
   primary currency still shows an (empty) card.
9. Source list summaries: Greek "Κάθε μήνα, 5η εργάσιμη" (not "εργάσιμη 5"); a source with a shift rule shows
   "· μετατόπιση: προηγούμενη εργάσιμη" (English "· shift: previous working day"); a source on the Nth working day or
   "Do not move" shows no shift text.
10. Force-close and reopen: sources, both currencies and the primary currency are still there.
11. Upgrade check (only with data from the Phase 1b build): install this build over it. Sources keep their currency,
    and the primary is the currency of the oldest source.

## 11. Phase 1d: setup wizard and extra payments

Prerequisite: `flutter analyze`, `flutter test` and `cargo test` pass. Note: from this phase on, a FRESH install opens
the setup wizard before Home. In the earlier sections (1-10), press "Skip for now" first (or finish the wizard).

1. Fresh install (device in Greek): the wizard opens by itself. The profile is "Μισθωτός". Three lines are marked
   "Προτεινόμενο" (Δώρο Χριστουγέννων, Δώρο Πάσχα, Επίδομα αδείας), all unticked, all with an EMPTY amount. The
   helper texts read "Ενδεικτικά έως ο καθαρός μισθός" and "Ενδεικτικά έως ο μισός καθαρός μισθός". A note says the
   suggestions are for the private sector. At the bottom: "Οι προτάσεις ελέγχθηκαν τελευταία φορά στις 19 Οκτ 2026".
2. Choose "Ελεύθερος επαγγελματίας": the three suggestions and the note disappear; the first line is renamed
   "Ελεύθερος επαγγελματίας". Go back to "Μισθωτός": the suggestions return.
3. Fill the salary `1.500,00` (the line ticks itself), the Christmas bonus `1.200,00` and the Easter bonus `600,00`.
   Leave the leave allowance unticked. Press "Δημιουργία πηγών".
4. Income page: the salary and the two extra payments are in the source list. The Christmas bonus reads "Κάθε χρόνο
   στις 21 Δεκεμβρίου · μετατόπιση: προηγούμενη εργάσιμη", the Easter bonus "Κάθε χρόνο τη Μεγάλη Τετάρτη ·
   μετατόπιση: προηγούμενη εργάσιμη", type "Έκτακτη πληρωμή". There is no "leave allowance" source.
5. Go to December 2026 in the month navigator: the Christmas bonus is on Monday 21 December. Go to April 2027: the Easter
   bonus is on Wednesday 28 April (Orthodox Easter 2027 is 2 May). Sources made by the wizard start today, so earlier months show nothing.
6. Force-close and reopen: the wizard does not open again.
7. Settings -> "Ρύθμιση πηγών εισοδήματος": the wizard opens again, with empty amounts. Tick "Δώρο Χριστουγέννων": a
   warning says that a source with this name already exists. It does not block saving. Press "Παράλειψη".
8. In the wizard, tick "Επίδομα αδείας", enter `500,00`, choose a month and a day. After saving, the source repeats
   every year on that date.
9. "Προσθήκη άλλης ετήσιας πληρωμής": a new line appears (ticked); name it "13ος μισθός", amount `1.400,00`, month
   and day. The remove (x) button removes the line. After saving, the source is a yearly "Έκτακτη πληρωμή".
10. Edit the Christmas bonus: the source form shows "Ετήσιο", the date `Δεκέμβριος` / `21` and the shift rule. In the
    schedule choices you can switch between a fixed date and "Μεγάλη Τετάρτη (Ορθόδοξο Πάσχα)".
11. Ticking a line and leaving the amount empty shows "Εισαγάγετε έγκυρο ποσό" and saves nothing.
12. Upgrade check (only with data from the Phase 1c build): install this build over it. Your sources are there and
    the wizard does NOT open by itself. It is still available in Settings.

## 12. Phase 2: expenses

Prerequisite: `flutter analyze`, `flutter test` and `cargo test` pass. Remember the warning at the top about on-device
tests. Start from the data of section 11 (or press "Skip for now" in the wizard on a fresh install).

1. Bottom bar: a third tab "Έξοδα" (Expenses). It is empty: "Δεν υπάρχουν έξοδα αυτόν τον μήνα".
2. Press "+". The form has: description, category (preselected "Άλλο"), date (today), account currency (your primary
   currency), "Ποσό που χρεώθηκε", and two collapsed sections (original amount, VAT/taxes). Choose "Τρόφιμα", enter
   `45,00`, save. The expense is in the list and the total for the currency is `45,00`.
3. Income tab: the cash flow card has a new line "Έξοδα" (`45,00`) and the projected closing balance is lower by `45,00`.
4. Anchor rule (Income tab -> Set balance): set a balance of `500,00` dated TODAY. Then add expenses on three dates:
   one the day before, one ON the anchor day, one the day after (use the date button in the form). Only the one
   AFTER the anchor lowers the closing balance. The two others are inside the anchor.
5. With an anchor inside the month, the "Έξοδα" line does NOT equal the difference of the opening and closing
   balances: the line shows all the month's expenses, the balance applies the anchor rule. The same is already true
   for the received income line. This is intended.
6. Pending expense: add an expense, leave "Ποσό που χρεώθηκε" empty, open "Αρχικό ποσό και νόμισμα", choose `GBP` and
   enter `24,50`. A notice says that the expense is saved as "awaiting amount" and counts nowhere. Save. In the list
   it has the marker "Αναμένει ποσό", it is not in the total (the total says "1 έξοδο αναμένει ποσό (δεν μετρά)") and
   the Income card shows the same indicator. The balance did not change.
7. Open the pending expense, enter `28,90` in "Ποσό που χρεώθηκε", save. The marker is gone, the total grows by
   `28,90`, the balance drops. The original amount `24,50 GBP` is still shown (informational).
8. Press Save with both amounts empty: an error asks for the amount charged or the original amount. Nothing is saved.
9. VAT/taxes: open the section, enter an amount smaller than the total: saved, no total changes. A larger amount shows
   "ο ΦΠΑ/οι φόροι δεν μπορούν να είναι περισσότεροι από το σύνολο".
10. Original currency equal to the account currency is rejected.
11. Currencies: the account currency list holds the currencies already in the app, and "Άλλο…". Type `sek` -> `SEK`;
    `ab` -> "Εισάγετε κωδικό νομίσματος με 3 γράμματα". An expense in a new currency creates its own card on the Income
    page; totals of different currencies are never added.
12. Month selector: previous/next month. The Expenses month is independent of the Income month.
13. Category filter: choose "Υγεία": only that category is listed and the totals follow. "Όλες οι κατηγορίες" resets
    it. An empty filtered month says so.
14. Edit an expense: change the amount and the category, save. Delete: the confirmation dialog appears; "Ακύρωση" keeps
    it, "Διαγραφή" removes it and the totals and the Income card update.
15. Force-close and reopen: expenses, the pending one and the categories are still there.
16. Upgrade check (only with data from the Phase 1d build): install this build over it. Income, the setup flag and the
    balance are unchanged; the Expenses tab opens with the eight categories.

17. Balance start (found on the emulator): set a balance of `780,00` dated 12 October, then add an expense of `98,00`
    dated 24 September. Before saving, the form shows a warning under the date: "Το υπόλοιπο ξεκινά στις 12 Οκτ 2026 ...",
    with a button "Χρήση 13 Οκτ 2026" (the day AFTER the anchor, because the anchor day is already inside the balance).
    The warning does not block: save the expense with the September date.
18. Go to September on the Income tab: "Αρχικό υπόλοιπο" and "Προβλεπόμενο τελικό υπόλοιπο" show "—" (not `-98,00`) and the
    note "Το υπόλοιπο ξεκινά στις 12 Οκτ 2026". "Έξοδα" still shows `98,00`. October shows numbers (closing `780,00`, the
    September expense is history and changes no balance), November starts from `780,00`.
19. Edit the September expense: the warning is there. Press "Χρήση 13 Οκτ 2026": the date changes and the warning goes. Change the
    date back, then change the account currency to one that has no anchor and no income source: the warning goes
    (the start is per currency). Without any anchor, the start is the start date of the oldest income source of that
    currency; then the warning is for dates BEFORE that day and the button proposes that day itself.
20. Long lists: add enough expenses (or sources) to fill the screen and scroll to the end on the Expenses and Income
    tabs: the last row can be scrolled completely above the "+" button.

## Checklist

- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] First run shows Launch #1
- [ ] Counter increases after force-close
- [ ] Previous startup time appears from launch #2
- [ ] Greek and English both display correctly
- [ ] Language and number format follow the device region
- [ ] `cargo test` green
- [ ] Home shows the Rust core line (en and el)
- [ ] Hot restart works with the Rust core
- [ ] Phase 1a steps 1-11 pass
- [ ] Phase 1b steps 1-13 pass
- [ ] Phase 1c steps 1-11 pass
- [ ] Phase 1d steps 1-12 pass
- [ ] Phase 2 steps 1-20 pass
- [ ] Cold start time noted (profile build): ______ ms
