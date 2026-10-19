// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Απλός Προϋπολογισμός';

  @override
  String get bootstrapStartingCore => 'Εκκίνηση της μηχανής υπολογισμών…';

  @override
  String get bootstrapOpeningDatabase => 'Άνοιγμα της τοπικής βάσης δεδομένων…';

  @override
  String get bootstrapRecordingLaunch => 'Προετοιμασία των δεδομένων σας…';

  @override
  String get bootstrapFinishing => 'Σχεδόν έτοιμο…';

  @override
  String get bootstrapFailedTitle => 'Κάτι πήγε στραβά κατά την εκκίνηση';

  @override
  String get bootstrapRetry => 'Δοκιμάστε ξανά';

  @override
  String get homeTitle => 'Έλεγχος θεμελίων';

  @override
  String get homeIntro =>
      'Η Φάση 0 λειτουργεί. Όλα όσα βλέπετε διαβάζονται από την τοπική βάση δεδομένων σας.';

  @override
  String homeLaunchCount(int count) {
    return 'Εκκίνηση #$count';
  }

  @override
  String homeFirstLaunch(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Πρώτη εκκίνηση: $dateString';
  }

  @override
  String homeStartupThisLaunch(int milliseconds) {
    return 'Αυτή η εκκίνηση χρειάστηκε $milliseconds ms';
  }

  @override
  String homeStartupPreviousLaunch(int milliseconds) {
    return 'Η προηγούμενη εκκίνηση χρειάστηκε $milliseconds ms';
  }

  @override
  String get homeStartupNoPrevious =>
      'Δεν έχει καταγραφεί προηγούμενη εκκίνηση';

  @override
  String homeRustCore(String version, String target) {
    return 'Πυρήνας Rust: v$version ($target)';
  }

  @override
  String homeLocaleInfo(String locale, String currency) {
    return 'Γλώσσα συσκευής: $locale · Νόμισμα: $currency';
  }

  @override
  String homeMoneySample(String amount) {
    return 'Δείγμα ποσού: $amount';
  }

  @override
  String get navHome => 'Αρχική';

  @override
  String get navIncome => 'Έσοδα';

  @override
  String get incomeTitle => 'Έσοδα';

  @override
  String get incomeSourcesHeader => 'Πηγές εισοδήματος';

  @override
  String get incomeNoSources =>
      'Δεν υπάρχουν ακόμη πηγές εισοδήματος. Προσθέστε μία με το κουμπί +.';

  @override
  String get incomeAddSource => 'Προσθήκη πηγής εισοδήματος';

  @override
  String get incomeEditSource => 'Επεξεργασία πηγής εισοδήματος';

  @override
  String get incomePreviousMonth => 'Προηγούμενος μήνας';

  @override
  String get incomeNextMonth => 'Επόμενος μήνας';

  @override
  String incomeMonthLabel(DateTime month) {
    final intl.DateFormat monthDateFormat = intl.DateFormat.yMMMM(localeName);
    final String monthString = monthDateFormat.format(month);

    return '$monthString';
  }

  @override
  String get incomeLoadError => 'Δεν ήταν δυνατή η ανάγνωση των εσόδων σας';

  @override
  String get incomeRetry => 'Δοκιμάστε ξανά';

  @override
  String get cashFlowOpening => 'Αρχικό υπόλοιπο';

  @override
  String get cashFlowReceived => 'Ελήφθησαν';

  @override
  String get cashFlowExpected => 'Αναμενόμενα';

  @override
  String get cashFlowClosing => 'Προβλεπόμενο τελικό υπόλοιπο';

  @override
  String get cashFlowSetBalance => 'Ορισμός υπολοίπου';

  @override
  String get incomePaymentsHeader => 'Πληρωμές του μήνα';

  @override
  String get incomeNoPayments => 'Καμία πληρωμή αυτόν τον μήνα';

  @override
  String get occurrenceReceived => 'Ελήφθη';

  @override
  String get occurrenceExpected => 'Αναμένεται';

  @override
  String get occurrenceSkipped => 'Δεν ελήφθη';

  @override
  String occurrenceSubtitle(DateTime date, String state) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString · $state';
  }

  @override
  String get occurrenceChangeAmount => 'Αλλαγή ποσού ή ημερομηνίας';

  @override
  String get occurrenceSkip => 'Σήμανση ως μη ληφθείσα';

  @override
  String get occurrenceReset => 'Επαναφορά προγραμματισμένης πληρωμής';

  @override
  String get amountDialogTitle => 'Αλλαγή πληρωμής';

  @override
  String get amountDialogField => 'Ποσό';

  @override
  String get typeSalary => 'Μισθός';

  @override
  String get typeFreelance => 'Ελεύθερος επαγγελματίας';

  @override
  String get typeSideHustle => 'Δευτερεύουσα απασχόληση';

  @override
  String get typeOther => 'Άλλο';

  @override
  String sourceSubtitle(String type, String schedule) {
    return '$type · $schedule';
  }

  @override
  String scheduleSummaryOneOff(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Μία φορά στις $dateString';
  }

  @override
  String scheduleSummaryMonthlyDay(int day) {
    return 'Κάθε μήνα, ημέρα $day';
  }

  @override
  String get scheduleSummaryMonthlyLast => 'Κάθε μήνα, την τελευταία ημέρα';

  @override
  String get formName => 'Όνομα';

  @override
  String get formType => 'Τύπος';

  @override
  String get formAmount => 'Ποσό (καθαρό)';

  @override
  String get formSchedule => 'Χρονοδιάγραμμα';

  @override
  String get scheduleOneOff => 'Εφάπαξ';

  @override
  String get scheduleMonthly => 'Μηνιαίο';

  @override
  String get formDate => 'Ημερομηνία';

  @override
  String get formDayOfMonth => 'Ημέρα του μήνα';

  @override
  String get formLastDay => 'Τελευταία ημέρα του μήνα';

  @override
  String get formStartDate => 'Έναρξη';

  @override
  String get formEndDate => 'Λήξη';

  @override
  String get formNoEndDate => 'Χωρίς λήξη';

  @override
  String get formClearEndDate => 'Καθαρισμός λήξης';

  @override
  String get actionSave => 'Αποθήκευση';

  @override
  String get actionCancel => 'Ακύρωση';

  @override
  String get actionArchive => 'Αρχειοθέτηση';

  @override
  String get archiveConfirmTitle => 'Αρχειοθέτηση αυτής της πηγής;';

  @override
  String get archiveConfirmBody =>
      'Οι πληρωμές που έχετε ήδη λάβει μένουν στο ιστορικό σας. Δεν αναμένονται νέες πληρωμές μετά τη σημερινή ημέρα.';

  @override
  String get errorNameRequired => 'Εισαγάγετε όνομα';

  @override
  String get errorAmountInvalid => 'Εισαγάγετε έγκυρο ποσό';

  @override
  String get errorAmountPositive =>
      'Το ποσό πρέπει να είναι μεγαλύτερο από το μηδέν';

  @override
  String errorAmountDecimals(int digits) {
    return 'Το πολύ $digits δεκαδικά ψηφία';
  }

  @override
  String get errorEndBeforeStart => 'Η λήξη είναι πριν από την έναρξη';

  @override
  String get errorSourceNotFound => 'Αυτή η πηγή εισοδήματος δεν υπάρχει πια';

  @override
  String get errorSourceArchived =>
      'Αυτή η πηγή εισοδήματος είναι αρχειοθετημένη και δεν μπορεί πλέον να αλλάξει';

  @override
  String get balanceDialogTitle => 'Ορισμός υπολοίπου';

  @override
  String get balanceDialogHelp =>
      'Το υπόλοιπό σας στο τέλος της επιλεγμένης ημέρας. Τα έσοδα μετά από αυτήν προστίθενται από πάνω.';

  @override
  String get balanceDialogAmount => 'Υπόλοιπο';

  @override
  String get balanceDialogDate => 'Ημερομηνία';

  @override
  String get scheduleSeveral => 'Πολλές φορές τον μήνα';

  @override
  String get scheduleWeekly => 'Εβδομαδιαία';

  @override
  String formPaymentDay(int number) {
    return 'Ημέρα πληρωμής $number';
  }

  @override
  String get ruleTypeDay => 'Ημέρα του μήνα';

  @override
  String get ruleTypeLast => 'Τελευταία ημέρα του μήνα';

  @override
  String get ruleTypeNth => 'Εργάσιμη του μήνα';

  @override
  String get formWorkingDayNumber => 'Αριθμός εργάσιμης';

  @override
  String get formAddRule => 'Προσθήκη ημέρας πληρωμής';

  @override
  String get formRemoveRule => 'Αφαίρεση ημέρας πληρωμής';

  @override
  String get formWeekday => 'Ημέρα της εβδομάδας';

  @override
  String get formShift => 'Αν η ημέρα δεν είναι εργάσιμη';

  @override
  String get shiftPrevious => 'Πληρωμή την προηγούμενη εργάσιμη';

  @override
  String get shiftNext => 'Πληρωμή την επόμενη εργάσιμη';

  @override
  String get shiftNone => 'Χωρίς μετακίνηση';

  @override
  String get errorDuplicateRules => 'Δύο ημέρες πληρωμής είναι ίδιες';

  @override
  String ruleShortDay(int day) {
    return 'ημέρα $day';
  }

  @override
  String get ruleShortLast => 'τελευταία ημέρα';

  @override
  String ruleShortNth(int n) {
    return '$nη εργάσιμη';
  }

  @override
  String scheduleSummaryMonthlyNth(int n) {
    return 'Κάθε μήνα, $nη εργάσιμη';
  }

  @override
  String scheduleSummarySeveral(String rules) {
    return 'Κάθε μήνα: $rules';
  }

  @override
  String scheduleSummaryWeekly(DateTime weekday) {
    final intl.DateFormat weekdayDateFormat = intl.DateFormat.EEEE(localeName);
    final String weekdayString = weekdayDateFormat.format(weekday);

    return 'Κάθε $weekdayString';
  }

  @override
  String get occurrenceDateLabel => 'Ημερομηνία πληρωμής';

  @override
  String get formCurrency => 'Νόμισμα';

  @override
  String get formCurrencyLocked =>
      'Το νόμισμα δεν αλλάζει. Δημιουργήστε νέα πηγή για να χρησιμοποιήσετε άλλο νόμισμα.';

  @override
  String get currencyOther => 'Άλλο…';

  @override
  String get currencyOtherTitle => 'Άλλο νόμισμα';

  @override
  String get currencyOtherField => 'Κωδικός νομίσματος (3 γράμματα, π.χ. CHF)';

  @override
  String get currencyInvalid => 'Εισάγετε κωδικό νομίσματος με 3 γράμματα';

  @override
  String get shiftShortPrevious => 'προηγούμενη εργάσιμη';

  @override
  String get shiftShortNext => 'επόμενη εργάσιμη';

  @override
  String scheduleSummaryWithShift(String summary, String shift) {
    return '$summary · μετατόπιση: $shift';
  }

  @override
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String get settingsOpen => 'Ρυθμίσεις';

  @override
  String get settingsPrimaryCurrency => 'Κύριο νόμισμα';

  @override
  String get settingsPrimaryCurrencyHelp =>
      'Το προεπιλεγμένο νόμισμα των νέων πηγών εισοδήματος. Οι υπάρχουσες πηγές κρατούν το νόμισμά τους. Ποσά σε διαφορετικά νομίσματα δεν αθροίζονται ποτέ.';
}
