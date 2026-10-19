# Extra payments in Greece (research for Phase 1d)

Purpose: the facts behind the Greek preset pack of the first-run wizard (Phase 1d). No code depends on this file yet.

Read on **2026-10-19** (every source below was opened on that day). Only official sources are used for rules. A
rule that no official source I could read confirms is marked **UNCONFIRMED** and is not filled in from memory.
Greek quotes are copied from the page.

Status words: **CONFIRMED** = stated on an official page I read. **PARTIAL** = official page read, but a detail (usually
the legal text) was not read. **UNCONFIRMED** = no official source read, or only secondary sources (news, blogs).

## Sources

Official pages read (all on 2026-10-19):

| Id | Source | Notes |
| --- | --- | --- |
| S1 | Ministry of Labour, "Επιδόματα εορτών (δώρα) Πάσχα και Χριστουγέννων": https://ypergasias.gov.gr/ergasiakes-scheseis/syllogikes-ergasiakes-sxeseis/sychnes-erotiseis/epidomata-eorton-dora-pascha-kai-christougennon/ | Cites ΚΥΑ 19040/1981 (Β΄ 742/1981), art. 1 par. 1-3. No publication date on the page (copyright 2026). Does not state a payment deadline and does not mention the leave allowance |
| S2 | Ministry of Labour notice "Για την καταβολή του Δώρου Χριστουγέννων", 20 Dec 2018: https://ypergasias.gov.gr/gia-tin-katavoli-tou-dorou-christougennon/ | A notice for the year 2018; it says "σύμφωνα με την ισχύουσα νομοθεσία" and names no law for the bonus. Cites ν. 4554/2018 for 26 December |
| S3 | Ministry of Labour notice "Για το δώρο Πάσχα", 19 Apr 2019: https://ypergasias.gov.gr/gia-to-doro-pascha/ | A notice for Easter 2019; no law named |
| S4 | Labour Inspectorate (Επιθεώρηση Εργασίας), Christmas bonus, "Δικαιούχοι / Χρόνος Καταβολής": https://www.hli.gov.gr/ergasiakes-scheseis/nomothesia-ergasiakes-scheseis/amoivi/doro-christougennon/dikaiouchoi-chronos-katavolis-2/ | Permanent guidance page, no date, no law named |
| S5 | Labour Inspectorate, Easter bonus, same title: https://www.hli.gov.gr/ergasiakes-scheseis/nomothesia-ergasiakes-scheseis/amoivi/doro-pascha/dikaiouchoi-chronos-katavolis/ | Permanent guidance page, no date |
| S6 | Labour Inspectorate, "Αποδοχές Άδειας και Επίδομα Άδειας": https://www.hli.gov.gr/ergasiakes-scheseis/nomothesia-ergasiakes-scheseis/adeies-ergasiakes-scheseis/etisia-kanoniki-adeia/apodoches-adeias-kai-epidoma-adeias/ | Cites α.ν. 539/1945 art. 3, ν. 4504/1966 art. 3, ν.δ. 4547/1966 art. 1 par. 3. No date |
| S7 | Labour Inspectorate, part-time and intermittent work, Christmas and Easter bonus: https://www.hli.gov.gr/ergasiakes-scheseis/nomothesia-ergasiakes-scheseis/amoivi/doro-christougennon/meriki-dialeipousa-apascholisi-2/ and https://www.hli.gov.gr/ergasiakes-scheseis/nomothesia-ergasiakes-scheseis/amoivi/doro-pascha/meriki-dialeipousa-apascholisi/ | Cites ν. 4635/2019 art. 59 par. 9 and 17 |
| S8 | Ministry of Labour, English page "Holiday Allowances": https://ypergasias.gov.gr/en/labour-relations/collective-employment-relations/holiday-allowances/ | Same content as S1; also cites ΚΥΑ 2006743/538/0022/1991 (Β΄ 170) |
| S9 | Government, "Εξειδίκευση των οικονομικών μέτρων που ανακοίνωσε ο Πρωθυπουργός στην 90ή ΔΕΘ": https://www.government.gov.gr/exidikefsi-ton-ikonomikon-metron-pou-anakinose-prothipourgos-stin-90i-deth/ | Page dated 18 Oct 2026. Announced measures, not a law |
| S10 | Ministry of Labour press release, 6 Apr 2024: https://ypergasias.gov.gr/domna-michailidou-afximeno-sta-415-evro-to-doro-tou-pascha-paranomoi-osoi-den-to-katavaloun/ | Minister's interview points; used only as an example of the formula |
| S11 | OPEKA, 10 Dec 2025: https://opeka.gov.gr/domna-michailidoy-noritera-tha-katavlithoyn-ta-epidomata-fetos-ta-christoygenna-monimi-i-dynatotita-propliromis-to-pascha-kai-ta-christoygenna-apo-to-2026/ | Earlier payment of OPEKA benefits at Christmas and Easter |
| S12 | Ministry of Labour, "Άδειες Εργαζομένων": https://ypergasias.gov.gr/ergasiakes-scheseis/atomikes-ergasiakes-sxeseis/adeies-ergazomenon/ | Only a mention of leave allowance paid by ΔΥΠΑ with parental leave benefits |

Not read, or unreadable (so nothing below relies on them): the text of ΚΥΑ 19040/1981, α.ν. 539/1945, ν. 4504/1966
and ν. 4093/2012 (the PDFs of the Government Gazette copies I fetched could not be decoded), the pages of
taxheaven.gr, news sites and blogs that search returned. News sites are named only as leads in the UNCONFIRMED parts.

Technical note: the fetch tool failed the TLS certificate check on hli.gov.gr, so those pages were downloaded with
`curl` (normal certificate verification) and the visible text was extracted.

## Private sector employees (μισθωτοί)

Who is covered: "Όλοι οι μισθωτοί που απασχολούνται με σχέση εξαρτημένης εργασίας" (S4, S5), paid by monthly salary or
daily wage. Everything in this section is about employees. The pages say nothing about self-employed people (see the
freelancer section).

### Christmas bonus (δώρο Χριστουγέννων) - CONFIRMED (S1, S2, S4, S8)

| Item | Rule |
| --- | --- |
| Amount | One monthly salary, or 25 daily wages |
| Full amount | Employment for the whole period 1 May - 31 December |
| Partial | 2/25 of the monthly salary (or 2 daily wages) for each 19 days of employment; a fraction for fewer than 19 days |
| Time that does not count | Unjustified absences, strike days, unpaid leave. Sickness: only days for which the fund paid sickness benefit are removed. Compulsory maternity leave before and after birth counts (S4) |
| Calculation basis | Pay actually paid on **10 December**; on the termination date if employment ended earlier. "Pay" is the total of regular pay: salary and every other benefit paid regularly, monthly or periodically (S4). For hourly or variable pay: the average over 1 May - 31 December (S4) |
| Deadline | "το αργότερο την 21η Δεκεμβρίου κάθε έτους". The employer may hold back the part that corresponds to 21-31 December and pay it by 31 December (S4) |
| How the date is defined | A fixed calendar date (21 December) |
| Form | Money only, not in kind (S2) |
| Part-time | Calculated like full time, on the reduced pay and the time worked (ν. 4635/2019 art. 59, S7). Intermittent work (fewer than 5 or 6 days a week): 1 daily wage for every 8 daily wages worked between 1 May and 31 December (S7) |

Sources and dates: S1 (no date), S2 (20 Dec 2018, for 2018), S4 (no date), S7 (no date). Read 2026-10-19.

### Easter bonus (δώρο Πάσχα) - CONFIRMED (S1, S3, S5, S8)

| Item | Rule |
| --- | --- |
| Amount | Half a monthly salary, or 15 daily wages |
| Full amount | Employment for the whole period 1 January - 30 April |
| Partial | 1/15 of half a monthly salary (or 1 daily wage) for each 8 days of employment; a fraction for fewer than 8 days |
| Time that does not count | Same as Christmas (S5) |
| Calculation basis | Pay actually paid on the **15th day before Easter**; on the termination date if employment ended earlier. Variable pay: average over 1 January - 30 April (S5) |
| Deadline | "το αργότερο την Μ. Τετάρτη κάθε έτους" (Holy Wednesday). The employer may hold back the part that corresponds to Holy Wednesday - 30 April and pay it by 30 April (S5) |
| How the date is defined | **Relative to Easter**, not a fixed date |
| Which Easter | The sources say only "Πάσχα". The 2019 notice (S3) gives Holy Wednesday as 24 April 2019. Orthodox Easter 2019 was 28 April (the table behind `docs/holidays.md`), and 28 - 4 = 24. So Holy Wednesday = **Orthodox Easter - 4 days**, and the basis date = Orthodox Easter - 15 days. This is my check of one example, not a statement of the law |
| Form | Money only (S3) |
| Part-time | Same as Christmas. Intermittent work: 2 daily wages for every 13 daily wages worked between 1 January and 30 April (S7) |

Example of the formula from an official source: S10 (6 Apr 2024): the Easter bonus on the minimum wage of 830 euro is
415 euro. That is the 2024 figure, not a current one.

### Holiday (leave) allowance (επίδομα αδείας) - PARTIAL (S6)

| Item | Rule |
| --- | --- |
| Who | Employees who are entitled to regular annual leave. "Το δικαίωμα λήψης επιδόματος αδείας αποτελεί συνακόλουθο του δικαιώματος λήψης κανονικής αδείας" |
| Amount | Equal to the total leave pay (αποδοχές αδείας), but not more than **half a monthly salary** (monthly paid) or **13 daily wages** (daily, hourly or commission paid) |
| Deadline | Paid in advance, **at the start of the leave** ("προκαταβάλλονται στον μισθωτό κατά την έναρξη της αδείας του") |
| How the date is defined | **Not fixed.** It follows the start date of the leave, which employer and employee agree. No official source read gives a calendar date |
| Legal basis (as quoted by S6) | α.ν. 539/1945 art. 3 (leave pay), ν. 4504/1966 art. 3 (allowance), ν.δ. 4547/1966 art. 1 par. 3 (advance payment). I did not read these texts |

My own inference, not a statement of a source: leave pay for a normal leave of two or more weeks is larger than half a
month's pay, so the cap would usually apply. A short leave would give a smaller allowance.
S1 and S8 do not mention the leave allowance at all.

### What counts as pay for these bonuses

The Labour Inspectorate pages (S4, S5) include the legal or contractual salary and every other benefit paid regularly.
The leave pay of S6 does not include the share of the holiday bonuses. This matters only when the app computes amounts,
and the Phase 1d decision is that the user types fixed net amounts.

## Public sector - mostly UNCONFIRMED

| Topic | Status | What I found |
| --- | --- | --- |
| Christmas, Easter and leave allowance of civil servants today | **UNCONFIRMED** | No official page I read states the current rule. Search leads (secondary sources only, not verified): the allowances were abolished from 1 January 2013 by ν. 4093/2012, civil servants are paid 12 salaries a year, and the Council of State rejected claims for their restoration. I could not read the law |
| New Christmas holiday allowance for civil servants | **CONFIRMED as an announcement** (S9, page dated 18 Oct 2026) | "Επίδομα εορτών Χριστουγέννων 500 ευρώ (μικτά) στους δημοσίους υπαλλήλους από τον Δεκέμβριο του 2027." The page names no payment day. It is an announced measure; I did not find the law or the Government Gazette. The partial-year and net-amount details I saw were on news sites, not on S9, so they are UNCONFIRMED |
| Extra leave days at Christmas and Easter for civil servants | not an extra payment | A mitos.gov.gr page mentions 5 extra leave days. It does not belong here |

So there is nothing to put in a public-sector preset today. When the law for the 2027 allowance is published, check
the payment day and the partial-year rule in the Government Gazette first.

## Self-employed, freelancers, side-hustle - no extra payments found

The pages above state the rules for "μισθωτοί" only. No official page I read describes a Christmas, Easter or leave
allowance for self-employed people. I did not search for one beyond these pages. A preset for freelancers and
side-hustle should therefore contain no extra payment lines. (Inference from silence, not a statement of a source.)

## Other payments that came up (outside the three bonuses)

| Item | Status | Note |
| --- | --- | --- |
| Pensioners' November support (announced increase from 300 to 400 euro) | CONFIRMED as an announcement (S9) | Concerns pensioners, who are not a Phase 1d profile |
| OPEKA benefits can be paid up to ten days earlier at Christmas and Easter (from 2026 permanently) | CONFIRMED (S11, 10 Dec 2025) | Changes the date of benefits, not an extra amount. Only for OPEKA benefits |
| ΔΥΠΑ pays a share of holiday bonuses and leave allowance together with parental leave and special maternity benefits | PARTIAL (S12) | Edge case; not read in detail |
| Christmas or Easter bonus of ΔΥΠΑ for people who receive unemployment benefit | **UNCONFIRMED** | Only news snippets with no official date |
| 13th or 14th salary and other extras from sector collective agreements | **UNCONFIRMED** | Not researched. The user can add a Yearly source by hand |
| Employers who spread the bonuses over the 12 monthly salaries | **UNCONFIRMED** | Not researched |

## What changed in recent years (as far as official sources show)

- Christmas bonus: the deadline and basis dates are the same in the 2018 notice (S2) and in the permanent page (S4). I
  found no change in the official pages read. I did not search the Government Gazette for amendments.
- Easter bonus: same (2019 notice S3 and page S5).
- 26 December became a mandatory holiday by ν. 4554/2018 (S2). It is already in `docs/holidays.md`.
- Part-time rules are tied to ν. 4635/2019 art. 59 (S7).
- Amounts follow the minimum wage and the salary at the basis date. The 2024 example (S10) used 830 euro.
- Public sector: the abolition in 2013 (UNCONFIRMED) and the announced allowance for December 2027 (S9).
- OPEKA payments: earlier payment at Christmas and Easter, permanent from 2026 (S11).

## Proposed preset pack lines

Format idea: a data file, each line with `key`, schedule, suggested amount rule, `lastVerified` (date), `sources`.
All lines are shown as "Προτεινόμενο" until the user confirms them. Amounts are fixed, net, typed or confirmed by the
user (Phase 1d decision); the wizard may prefill once.

| Key | Profile | Schedule | Notes |
| --- | --- | --- | --- |
| `gr.private.christmas_bonus` | Employee | Yearly, fixed date 21 December, shift "previous working day" | The legal deadline. The sources give no "usual" payment date, so the deadline is used, with the shift moving it earlier. Suggested amount: not computable (see questions) |
| `gr.private.easter_bonus` | Employee | Yearly, **Holy Wednesday** (Orthodox Easter - 4), shift "previous working day" | Needs an Easter-relative date; a fixed month and day cannot express it. Holy Wednesday is a working day unless it is a holiday |
| `gr.private.leave_allowance` | Employee | Yearly, month and day chosen by the user (the start of the leave) | No default date. The wizard asks, or leaves it for the user to set. Amount cap: half a monthly salary |

No lines for freelancer and side-hustle. No public-sector lines now.

## Questions that stay open for the owner

1. **Net amounts.** The legal amount is based on gross pay on 10 December (or 15 days before Easter). The net bonus is
   not the net salary (taxes and contributions differ). Prefill from the entered net salary as an upper bound labelled
   "Προτεινόμενο", or ask the user to type the expected net amount, or no prefill?
2. **Date to use.** Deadline (21 December, Holy Wednesday) with "previous working day", or an earlier typical date?
   No official source gives a typical date.
3. **Easter-relative dates.** The decided `Yearly` (month, day, shift) cannot express Holy Wednesday (see the plan).
4. **Leave allowance.** Ask for the leave month in the wizard, or create it without a date for the user to complete?
5. **Part-time and intermittent employees.** Different amounts (S7). Accept manual amounts only?
6. **Public sector.** Leave the preset empty until the 2027 allowance is a law?
7. **Bonuses spread over 12 months, sector agreements, 13th and 14th salary** (UNCONFIRMED): does the wizard ask
   whether the employee gets the bonuses as separate payments?
8. **Show `lastVerified`** in the UI next to "Προτεινόμενο"?
