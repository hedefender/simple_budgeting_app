# Greek holidays used by the schedule engine

Implemented in `lib/features/income/data/greek_holiday_calendar.dart` (pure Dart, offline). The domain only knows
the `HolidayCalendar` interface. A working day is Monday to Friday and not a holiday.

Checked on 2026-10-19 against the sources below. Nothing here comes from memory alone.

## What is implemented

| Holiday | Rule | Status |
| --- | --- | --- |
| New Year, Epiphany | 1 Jan, 6 Jan | Confirmed (Wikipedia list; GSEE/KEPEA list as quoted there) |
| Independence Day | 25 Mar | Confirmed |
| Labour Day | 1 May, always on 1 May | Confirmed as a holiday. No move is implemented (see below) |
| Dormition | 15 Aug | Confirmed |
| Ohi Day | 28 Oct | Confirmed |
| Christmas, Synaxis of the Theotokos | 25 Dec, 26 Dec | Confirmed |
| Clean Monday | Orthodox Easter - 48 days | Listed as a movable national holiday; offset is the standard Orthodox calendar order. Spot-checked: 2026-02-23, 2025-03-03, 2024-03-18 |
| Good Friday | Orthodox Easter - 2 days | Listed as a movable national holiday. See the note on its legal status |
| Easter Monday | Orthodox Easter + 1 day | Confirmed |
| Whit Monday (Holy Spirit Monday) | Orthodox Easter + 50 days | Listed as a movable national holiday. Spot-checked: 2026-06-01 (news article), 2025-06-09, 2024-06-24 |

Easter Sunday itself and Holy Saturday need no entry: they are weekends. Years in which two holidays coincide
(2000: Easter Monday is 1 May) simply have one holiday fewer.

## Orthodox Easter

Meeus' Julian algorithm gives the date in the Julian calendar. It is moved to the Gregorian calendar by the
difference of the two calendars for that year: `century - century/4 - 2` days. That is 13 days for 1900-2099 and
14 days from 2100 (15 from 2200). The 13-day shortcut is NOT used, so 2100 and later work too.

Tests check:
- the dates of 2016-2035 against the table in Wikipedia "List of dates for Easter";
- the extremes between 1875 and 2099 listed there (earliest 4 April: 1915, 2010; latest 8 May: 1983, 2078);
- that Easter is a Sunday for every year 1900-2199 (this fails if the offset is wrong at the 2099/2100 boundary);
- the offsets 12 (1899), 13 (1900, 2000, 2099), 14 (2100, 2199) and 15 (2200).

The 2100 boundary is not checked against an external table, only against the Sunday invariant.

## Not implemented, not confirmed

- **1 May moved when it falls in Holy Week or on Easter Sunday.** The sources found do not state a rule. The
  Wikipedia article only says a holiday that falls on a Sunday is not moved "with the exception of 1 May"; it names no
  rule. This is decided by a ministerial decision per year, so it is NOT implemented. If a year needs it, a source
  must be added first.
- **Legal status differs by sector.** GSEE/KEPEA state that Holy Spirit Monday is not a statutory holiday for the
  private sector (it is for the public sector, local government, schools and banks), and that Good Friday is only a
  half-day by law for shops (until 13:00). The engine treats the public/bank calendar as the calendar of payment days,
  because salaries and invoices are paid through banks. Private-sector employers may therefore differ.
- Regional or local holidays (patron saints, decisions of regional governors) and sector-only holidays (30 Jan for
  education, 17 Nov Polytechnic) are not included.
- Holidays announced ad hoc (for example an extra bridge day) are not included.

## Known limit

Past payments that were never frozen are computed from this calendar. If the calendar is corrected later, the actual
date of such a payment can change. Stored decisions (skipped or changed payments) are keyed on the NOMINAL date, so
they never become orphans. Closing a month (Phase 2b) will freeze the payments of that month.

## Sources

- Wikipedia, "Public holidays in Greece": https://en.wikipedia.org/wiki/Public_holidays_in_Greece (fixed and movable
  national holidays; cites the GSEE/KEPEA list "Ποιες είναι οι ημέρες υποχρεωτικής αργίας").
- Wikipedia, "List of dates for Easter": https://en.wikipedia.org/wiki/List_of_dates_for_Easter (Orthodox Easter
  2016-2035, extremes 1875-2099, 13-day difference).
- GSEE / KEPEA via taxheaven.gr and kepea.gr (Holy Spirit Monday and Good Friday status for the private sector):
  https://www.taxheaven.gr/news/73683/gsee-pws-ameibetai-h-hmera-toy-agioy-pneymatos and
  https://www.kepea.gr/pos-ameivetai-i-imera-tou-agiou-pneymatos-2024
- newmoney.gr, Holy Spirit Monday 2026 (1 June 2026; public sector and banks closed):
  https://www.newmoney.gr/roh/palmos-oikonomias/ellada/agiou-pnevmatos-2026-gia-pious-ine-argia-i-deftera-1i-iouniou-ti-ischii-gia-katastimata-souper-market-ke-trapezes/
- Meeus, "Astronomical Algorithms" (Julian Easter algorithm); the `easter` package documentation on CTAN describes
  the same algorithms: https://www.ctan.org/pkg/easter

The official legal texts (laws and ministerial decisions) were not read directly. Everything above is from the
secondary sources listed. Before relying on this for a year that matters, check the Ministry of Labour announcement.
