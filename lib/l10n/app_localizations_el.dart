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
  String get cashFlowExpenses => 'Έξοδα';

  @override
  String cashFlowPendingExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count έξοδα αναμένουν ποσό (δεν μετρούν)',
      one: '1 έξοδο αναμένει ποσό (δεν μετρά)',
    );
    return '$_temp0';
  }

  @override
  String cashFlowBalanceStarts(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Το υπόλοιπο ξεκινά στις $dateString';
  }

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
  String get typeExtraPayment => 'Έκτακτη πληρωμή';

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
  String get scheduleYearly => 'Ετήσιο';

  @override
  String get formYearlyAnchor => 'Ημερομηνία';

  @override
  String get yearlyAnchorFixed => 'Σταθερή ημερομηνία';

  @override
  String get yearlyAnchorHolyWednesday => 'Μεγάλη Τετάρτη (Ορθόδοξο Πάσχα)';

  @override
  String yearlyAnchorEasterOffset(String offset) {
    return 'Ορθόδοξο Πάσχα $offset ημέρες';
  }

  @override
  String get formMonth => 'Μήνας';

  @override
  String scheduleSummaryYearlyFixed(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Κάθε χρόνο στις $dateString';
  }

  @override
  String get scheduleSummaryYearlyHolyWednesday =>
      'Κάθε χρόνο τη Μεγάλη Τετάρτη';

  @override
  String scheduleSummaryYearlyEaster(String offset) {
    return 'Κάθε χρόνο, Ορθόδοξο Πάσχα $offset ημέρες';
  }

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
  String get setupTitle => 'Ρύθμιση εισοδήματος';

  @override
  String get setupIntro =>
      'Τσεκάρετε ό,τι ισχύει για εσάς και συμπληρώστε τα ποσά. Δεν αποθηκεύεται τίποτα για γραμμή που δεν είναι τσεκαρισμένη ή δεν έχει ποσό. Τα ποσά είναι καθαρά, όπως τα εισπράττετε.';

  @override
  String get setupProfileLabel => 'Είμαι';

  @override
  String get profileEmployee => 'Μισθωτός';

  @override
  String get profileFreelancer => 'Ελεύθερος επαγγελματίας';

  @override
  String get profileSideHustle => 'Δευτερεύουσα απασχόληση';

  @override
  String get setupMainSection => 'Τακτικό εισόδημα';

  @override
  String get setupExtraSection => 'Έκτακτες πληρωμές';

  @override
  String get setupPrivateSectorNote =>
      'Οι προτάσεις αφορούν μισθωτούς του ιδιωτικού τομέα. Οι κανόνες του Δημοσίου δεν περιλαμβάνονται.';

  @override
  String get setupSuggested => 'Προτεινόμενο';

  @override
  String get presetChristmasBonus => 'Δώρο Χριστουγέννων';

  @override
  String get presetEasterBonus => 'Δώρο Πάσχα';

  @override
  String get presetLeaveAllowance => 'Επίδομα αδείας';

  @override
  String get amountHintChristmas => 'Ενδεικτικά έως ο καθαρός μισθός';

  @override
  String get amountHintEaster => 'Ενδεικτικά έως ο μισός καθαρός μισθός';

  @override
  String get amountHintLeave =>
      'Προαιρετικό. Πληρώνεται με την έναρξη της άδειας· δώστε αυτή την ημερομηνία';

  @override
  String get setupLeaveDate => 'Ημερομηνία πληρωμής';

  @override
  String get setupAddYearly => 'Προσθήκη άλλης ετήσιας πληρωμής';

  @override
  String get setupCustomName => 'Ετήσια πληρωμή';

  @override
  String get setupRemoveLine => 'Αφαίρεση αυτής της γραμμής';

  @override
  String setupLastVerified(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Οι προτάσεις ελέγχθηκαν τελευταία φορά στις $dateString';
  }

  @override
  String setupDuplicateWarning(String name) {
    return 'Υπάρχει ήδη πηγή με όνομα «$name». Με την αποθήκευση θα δημιουργηθεί και δεύτερη.';
  }

  @override
  String get setupFinish => 'Δημιουργία πηγών';

  @override
  String get setupSkip => 'Παράλειψη προς το παρόν';

  @override
  String get settingsSetupWizard => 'Ρύθμιση πηγών εισοδήματος';

  @override
  String get settingsSetupWizardHelp =>
      'Ανοίξτε ξανά τον οδηγό για να προσθέσετε τακτικές και έκτακτες πληρωμές ενός προφίλ.';

  @override
  String get navExpenses => 'Έξοδα';

  @override
  String get expensesTitle => 'Έξοδα';

  @override
  String get expensesAllCategories => 'Όλες οι κατηγορίες';

  @override
  String get expensesCategoryLabel => 'Κατηγορία';

  @override
  String get expensesNone => 'Δεν υπάρχουν έξοδα αυτόν τον μήνα';

  @override
  String get expensesNoneInCategory =>
      'Δεν υπάρχουν έξοδα σε αυτή την κατηγορία αυτόν τον μήνα';

  @override
  String get expensesTotal => 'Σύνολο';

  @override
  String get expenseAwaitingAmount => 'Αναμένει ποσό';

  @override
  String get categoryEnergy => 'Ενέργεια';

  @override
  String get categoryWater => 'Νερό';

  @override
  String get categoryTelecom => 'Τηλεπικοινωνίες';

  @override
  String get categoryFood => 'Τρόφιμα';

  @override
  String get categoryFuelTransport => 'Καύσιμα / Μεταφορές';

  @override
  String get categoryHealth => 'Υγεία';

  @override
  String get categoryInsurance => 'Ασφάλειες';

  @override
  String get categoryOther => 'Άλλο';

  @override
  String get errorExpenseAmountRequired =>
      'Εισαγάγετε το ποσό που χρεώθηκε ή το αρχικό ποσό και το νόμισμά του';

  @override
  String get errorExpenseOriginalIncomplete =>
      'Εισαγάγετε και το αρχικό ποσό και το νόμισμά του';

  @override
  String get errorExpenseOriginalSameCurrency =>
      'Το αρχικό νόμισμα πρέπει να διαφέρει από το νόμισμα του λογαριασμού';

  @override
  String get errorExpenseTaxNoAmount =>
      'Ο ΦΠΑ/οι φόροι χρειάζονται το ποσό που χρεώθηκε';

  @override
  String get errorExpenseTaxTooLarge =>
      'Ο ΦΠΑ/οι φόροι δεν μπορούν να είναι περισσότεροι από το σύνολο';

  @override
  String get errorExpenseCategory => 'Επιλέξτε κατηγορία';

  @override
  String get errorExpenseNotFound => 'Αυτό το έξοδο δεν υπάρχει πια';

  @override
  String get errorExpenseDocumentNotFound =>
      'Το έγγραφο αυτού του εξόδου δεν υπάρχει πια';

  @override
  String get expenseAdd => 'Προσθήκη εξόδου';

  @override
  String get expenseEditTitle => 'Επεξεργασία εξόδου';

  @override
  String get expenseDescription => 'Περιγραφή (προαιρετική)';

  @override
  String get expenseAccountCurrency => 'Νόμισμα λογαριασμού';

  @override
  String get expenseAmountCharged => 'Ποσό που χρεώθηκε';

  @override
  String get expenseAmountChargedHelp =>
      'Ό,τι έφυγε από την τσέπη σας, όπως στο μήνυμα ή την κίνηση της τράπεζας.';

  @override
  String get expenseOriginalSection => 'Αρχικό ποσό και νόμισμα (προαιρετικό)';

  @override
  String get expenseOriginalAmount => 'Αρχικό ποσό';

  @override
  String get expenseOriginalCurrency => 'Αρχικό νόμισμα';

  @override
  String get expenseOriginalHelp =>
      'Ενημερωτικό, π.χ. το ποσό σε λίρες στην απόδειξη. Δεν γίνεται καμία μετατροπή.';

  @override
  String get expenseTaxSection => 'Εκ των οποίων ΦΠΑ / φόροι (προαιρετικό)';

  @override
  String get expenseTaxAmount => 'ΦΠΑ / φόροι';

  @override
  String get expenseTaxHelp =>
      'Ενημερωτικό: μέρος του συνόλου, δεν προστίθεται σε κανένα άθροισμα.';

  @override
  String get expensePendingNotice =>
      'Δεν έχει δοθεί ακόμα ποσό που χρεώθηκε. Το έξοδο αποθηκεύεται ως «αναμένει ποσό»: φαίνεται πάντα στη λίστα, αλλά δεν μετρά σε κανένα σύνολο ή υπόλοιπο μέχρι να εισαγάγετε το ποσό που χρεώθηκε, όπως στο μήνυμα ή την κίνηση της τράπεζας.';

  @override
  String expenseBeforeBalanceWarning(DateTime start, DateTime suggested) {
    final intl.DateFormat startDateFormat = intl.DateFormat.yMMMd(localeName);
    final String startString = startDateFormat.format(start);
    final intl.DateFormat suggestedDateFormat = intl.DateFormat.yMMMd(
      localeName,
    );
    final String suggestedString = suggestedDateFormat.format(suggested);

    return 'Το υπόλοιπο ξεκινά στις $startString. Ένα έξοδο με προηγούμενη ημερομηνία καταγράφεται στο ιστορικό και στα σύνολα, αλλά δεν επηρεάζει το υπόλοιπο. Επιλέξτε ημερομηνία από $suggestedString και μετά.';
  }

  @override
  String expenseUseBalanceStart(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Χρήση $dateString';
  }

  @override
  String get expenseDeleteTitle => 'Διαγραφή αυτού του εξόδου;';

  @override
  String get expenseDeleteBody => 'Θα αφαιρεθεί οριστικά.';

  @override
  String get actionDelete => 'Διαγραφή';

  @override
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String get settingsOpen => 'Ρυθμίσεις';

  @override
  String get settingsPrimaryCurrency => 'Κύριο νόμισμα';

  @override
  String get settingsPrimaryCurrencyHelp =>
      'Το προεπιλεγμένο νόμισμα των νέων πηγών εισοδήματος. Οι υπάρχουσες πηγές κρατούν το νόμισμά τους. Ποσά σε διαφορετικά νομίσματα δεν αθροίζονται ποτέ.';

  @override
  String get navDocuments => 'Έγγραφα';

  @override
  String get documentsTitle => 'Έγγραφα';

  @override
  String get documentsImport => 'Εισαγωγή';

  @override
  String get documentsImportTooltip => 'Εισαγωγή αρχείων JSON του Scan';

  @override
  String get documentsEmptyTitle => 'Δεν υπάρχουν έγγραφα ακόμα';

  @override
  String get documentsEmptyBody =>
      'Εισάγετε τα αρχεία JSON που εξάγει το Scan. Τα έγγραφά σας μένουν σε αυτή τη συσκευή.';

  @override
  String get documentLinkedChip => 'Συνδεδεμένο έξοδο';

  @override
  String get documentLegacyChip => 'Παλιά μορφή';

  @override
  String get documentNoTitle => '(χωρίς κείμενο)';

  @override
  String get importInProgress => 'Εισαγωγή…';

  @override
  String get importReportTitle => 'Αναφορά εισαγωγής';

  @override
  String importSummaryImported(int count) {
    return 'Εισήχθησαν: $count';
  }

  @override
  String importSummaryDuplicate(int count) {
    return 'Ήδη εισαγμένα: $count';
  }

  @override
  String importSummaryFailed(int count) {
    return 'Με σφάλμα: $count';
  }

  @override
  String importSummarySkipped(int count) {
    return 'Παραλείφθηκαν: $count';
  }

  @override
  String get importResultImported => 'Εισήχθη';

  @override
  String get importResultDuplicate => 'Ήδη εισαγμένο';

  @override
  String get importResultSkipped => 'Παραλείφθηκε: δεν είναι αρχείο JSON';

  @override
  String importTooManyFiles(int limit) {
    return 'Πάρα πολλά αρχεία: επιλέξτε το πολύ $limit τη φορά.';
  }

  @override
  String get importPickError => 'Δεν ήταν δυνατό να ανοίξει η επιλογή αρχείων.';

  @override
  String get importDone => 'Τέλος';

  @override
  String get importErrorEmptyFile => 'Το αρχείο είναι κενό.';

  @override
  String importErrorTooLarge(String size, String limit) {
    return 'Το αρχείο είναι πολύ μεγάλο ($size, όριο $limit).';
  }

  @override
  String get importErrorNotUtf8 => 'Το αρχείο δεν είναι έγκυρο κείμενο UTF-8.';

  @override
  String get importErrorInvalidJson => 'Μη έγκυρο JSON.';

  @override
  String importErrorInvalidJsonAt(int line, int column) {
    return 'Μη έγκυρο JSON (γραμμή $line, στήλη $column).';
  }

  @override
  String get importErrorNotAnObject =>
      'Το αρχείο πρέπει να περιέχει αντικείμενο JSON.';

  @override
  String importErrorMissingField(String field) {
    return 'Λείπει το πεδίο $field.';
  }

  @override
  String importErrorWrongType(String field) {
    return 'Το πεδίο $field έχει λάθος τύπο.';
  }

  @override
  String get importErrorEmptyOcrText => 'Το κείμενο OCR είναι κενό.';

  @override
  String get importErrorInvalidDocumentId =>
      'Το documentId είναι κενό ή μεγαλύτερο από 128 χαρακτήρες.';

  @override
  String get importErrorInvalidDate =>
      'Το createdAt δεν είναι έγκυρη ημερομηνία και ώρα ISO 8601.';

  @override
  String importErrorEmptyFileName(String field) {
    return 'Το όνομα αρχείου στο $field είναι κενό.';
  }

  @override
  String importErrorUnsupportedVersion(int found, int known) {
    return 'Το αρχείο έχει έκδοση σχήματος $found· αυτή η εφαρμογή υποστηρίζει έως την έκδοση $known. Ενημερώστε την εφαρμογή. Δεν έγινε εισαγωγή.';
  }

  @override
  String get importErrorReadError => 'Το αρχείο δεν μπόρεσε να διαβαστεί.';

  @override
  String get importErrorStorageError =>
      'Το έγγραφο δεν μπόρεσε να αποθηκευτεί.';

  @override
  String get importErrorUnexpected => 'Μη αναμενόμενο σφάλμα.';

  @override
  String get documentDetailTitle => 'Έγγραφο';

  @override
  String get documentNotFound => 'Αυτό το έγγραφο δεν υπάρχει πια.';

  @override
  String get documentCreatedLabel => 'Δημιουργήθηκε';

  @override
  String get documentIdLabel => 'Αναγνωριστικό εγγράφου';

  @override
  String documentSourceLine(String file, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Εισήχθη από $file στις $dateString';
  }

  @override
  String get documentLegacyNote => 'Διαβάστηκε από την παλιά μορφή του Scan.';

  @override
  String documentLanguageLine(String code) {
    return 'Γλώσσα: $code';
  }

  @override
  String documentPdfLine(String name) {
    return 'PDF: $name';
  }

  @override
  String documentImagesLine(int count, String names) {
    return 'Εικόνες ($count): $names';
  }

  @override
  String get documentFilesNotStored =>
      'Αυτά τα αρχεία δεν αποθηκεύονται στην εφαρμογή.';

  @override
  String get documentOcrHeader => 'Κείμενο (OCR)';

  @override
  String documentTextTruncated(int shown, int total) {
    return 'Εμφανίζονται οι πρώτοι $shown από $total χαρακτήρες.';
  }

  @override
  String get documentShowAll => 'Εμφάνιση όλου';

  @override
  String get documentCreateExpense => 'Δημιουργία εξόδου';

  @override
  String get documentExpensesHeader => 'Έξοδα από αυτό το έγγραφο';

  @override
  String get documentDelete => 'Διαγραφή εγγράφου';

  @override
  String get documentDeleteTitle => 'Διαγραφή αυτού του εγγράφου;';

  @override
  String get documentDeleteBodyPlain =>
      'Το έγγραφο και το κείμενό του αφαιρούνται από αυτή τη συσκευή. Μπορείτε να το εισαγάγετε ξανά αργότερα.';

  @override
  String documentDeleteBodyExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Παραμένουν $count συνδεδεμένα έξοδα, χωρίς τον σύνδεσμο με το έγγραφο.',
      one: 'Παραμένει 1 συνδεδεμένο έξοδο, χωρίς τον σύνδεσμο με το έγγραφο.',
    );
    return '$_temp0';
  }

  @override
  String get documentDeleted => 'Το έγγραφο διαγράφηκε';

  @override
  String expenseFromDocument(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Από το έγγραφο της $dateString';
  }

  @override
  String get expenseOpenDocument => 'Προβολή εγγράφου';
}
