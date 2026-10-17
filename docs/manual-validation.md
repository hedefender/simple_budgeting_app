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

## Checklist

- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] First run shows Launch #1
- [ ] Counter increases after force-close
- [ ] Previous startup time appears from launch #2
- [ ] Greek and English both display correctly
- [ ] Currency follows device region
- [ ] Cold start time noted (profile build): ______ ms
