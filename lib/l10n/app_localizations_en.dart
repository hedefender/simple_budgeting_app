// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Simple Budgeting';

  @override
  String get bootstrapStartingCore => 'Starting the calculation engine…';

  @override
  String get bootstrapOpeningDatabase => 'Opening your local database…';

  @override
  String get bootstrapRecordingLaunch => 'Preparing your data…';

  @override
  String get bootstrapFinishing => 'Almost ready…';

  @override
  String get bootstrapFailedTitle =>
      'Something went wrong while starting the app';

  @override
  String get bootstrapRetry => 'Try again';

  @override
  String get homeTitle => 'Foundation check';

  @override
  String get homeIntro =>
      'Phase 0 is running. Everything below is read from your local database.';

  @override
  String homeLaunchCount(int count) {
    return 'Launch #$count';
  }

  @override
  String homeFirstLaunch(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'First launch: $dateString';
  }

  @override
  String homeStartupThisLaunch(int milliseconds) {
    return 'This startup took $milliseconds ms';
  }

  @override
  String homeStartupPreviousLaunch(int milliseconds) {
    return 'Previous startup took $milliseconds ms';
  }

  @override
  String get homeStartupNoPrevious => 'No previous startup recorded yet';

  @override
  String homeRustCore(String version, String target) {
    return 'Rust core: v$version ($target)';
  }

  @override
  String homeLocaleInfo(String locale, String currency) {
    return 'Device locale: $locale · Currency: $currency';
  }

  @override
  String homeMoneySample(String amount) {
    return 'Sample amount: $amount';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navIncome => 'Income';

  @override
  String get incomeTitle => 'Income';

  @override
  String get incomeSourcesHeader => 'Income sources';

  @override
  String get incomeNoSources =>
      'No income sources yet. Add one with the + button.';

  @override
  String get incomeAddSource => 'Add income source';

  @override
  String get incomeEditSource => 'Edit income source';

  @override
  String get incomePreviousMonth => 'Previous month';

  @override
  String get incomeNextMonth => 'Next month';

  @override
  String incomeMonthLabel(DateTime month) {
    final intl.DateFormat monthDateFormat = intl.DateFormat.yMMMM(localeName);
    final String monthString = monthDateFormat.format(month);

    return '$monthString';
  }

  @override
  String get incomeLoadError => 'Could not read your income data';

  @override
  String get incomeRetry => 'Try again';

  @override
  String get cashFlowOpening => 'Opening balance';

  @override
  String get cashFlowReceived => 'Received';

  @override
  String get cashFlowExpected => 'Expected';

  @override
  String get cashFlowExpenses => 'Expenses';

  @override
  String cashFlowPendingExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses await an amount (not counted)',
      one: '1 expense awaits an amount (not counted)',
    );
    return '$_temp0';
  }

  @override
  String cashFlowBalanceStarts(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'The balance starts on $dateString';
  }

  @override
  String get cashFlowClosing => 'Projected closing balance';

  @override
  String get cashFlowSetBalance => 'Set balance';

  @override
  String get incomePaymentsHeader => 'Payments this month';

  @override
  String get incomeNoPayments => 'No payments this month';

  @override
  String get occurrenceReceived => 'Received';

  @override
  String get occurrenceExpected => 'Expected';

  @override
  String get occurrenceSkipped => 'Not received';

  @override
  String occurrenceSubtitle(DateTime date, String state) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString · $state';
  }

  @override
  String get occurrenceChangeAmount => 'Change amount or date';

  @override
  String get occurrenceSkip => 'Mark as not received';

  @override
  String get occurrenceReset => 'Restore planned payment';

  @override
  String get amountDialogTitle => 'Change payment';

  @override
  String get amountDialogField => 'Amount';

  @override
  String get typeSalary => 'Salary';

  @override
  String get typeFreelance => 'Freelance';

  @override
  String get typeSideHustle => 'Side hustle';

  @override
  String get typeOther => 'Other';

  @override
  String get typeExtraPayment => 'Extra payment';

  @override
  String sourceSubtitle(String type, String schedule) {
    return '$type · $schedule';
  }

  @override
  String scheduleSummaryOneOff(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Once on $dateString';
  }

  @override
  String scheduleSummaryMonthlyDay(int day) {
    return 'Monthly on day $day';
  }

  @override
  String get scheduleSummaryMonthlyLast => 'Monthly on the last day';

  @override
  String get formName => 'Name';

  @override
  String get formType => 'Type';

  @override
  String get formAmount => 'Amount (net)';

  @override
  String get formSchedule => 'Schedule';

  @override
  String get scheduleOneOff => 'Once';

  @override
  String get scheduleMonthly => 'Monthly';

  @override
  String get formDate => 'Date';

  @override
  String get formDayOfMonth => 'Day of the month';

  @override
  String get formLastDay => 'Last day of the month';

  @override
  String get formStartDate => 'Starts';

  @override
  String get formEndDate => 'Ends';

  @override
  String get formNoEndDate => 'No end date';

  @override
  String get formClearEndDate => 'Clear end date';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionArchive => 'Archive';

  @override
  String get archiveConfirmTitle => 'Archive this source?';

  @override
  String get archiveConfirmBody =>
      'Payments already received stay in your history. No new payments are expected after today.';

  @override
  String get errorNameRequired => 'Enter a name';

  @override
  String get errorAmountInvalid => 'Enter a valid amount';

  @override
  String get errorAmountPositive => 'The amount must be greater than zero';

  @override
  String errorAmountDecimals(int digits) {
    return 'At most $digits decimal places';
  }

  @override
  String get errorEndBeforeStart => 'The end date is before the start date';

  @override
  String get errorSourceNotFound => 'This income source no longer exists';

  @override
  String get errorSourceArchived =>
      'This income source is archived and can no longer be changed';

  @override
  String get balanceDialogTitle => 'Set balance';

  @override
  String get balanceDialogHelp =>
      'Your balance at the end of the chosen day. Income after that day is added on top.';

  @override
  String get balanceDialogAmount => 'Balance';

  @override
  String get balanceDialogDate => 'Date';

  @override
  String get scheduleSeveral => 'Several a month';

  @override
  String get scheduleWeekly => 'Weekly';

  @override
  String formPaymentDay(int number) {
    return 'Payment day $number';
  }

  @override
  String get ruleTypeDay => 'Day of the month';

  @override
  String get ruleTypeLast => 'Last day of the month';

  @override
  String get ruleTypeNth => 'Working day of the month';

  @override
  String get formWorkingDayNumber => 'Working day number';

  @override
  String get formAddRule => 'Add payment day';

  @override
  String get formRemoveRule => 'Remove payment day';

  @override
  String get formWeekday => 'Weekday';

  @override
  String get formShift => 'If the day is not a working day';

  @override
  String get shiftPrevious => 'Pay on the previous working day';

  @override
  String get shiftNext => 'Pay on the next working day';

  @override
  String get shiftNone => 'Do not move';

  @override
  String get errorDuplicateRules => 'Two payment days are the same';

  @override
  String ruleShortDay(int day) {
    return 'day $day';
  }

  @override
  String get ruleShortLast => 'last day';

  @override
  String ruleShortNth(int n) {
    return 'working day $n';
  }

  @override
  String scheduleSummaryMonthlyNth(int n) {
    return 'Monthly, working day $n';
  }

  @override
  String scheduleSummarySeveral(String rules) {
    return 'Monthly on $rules';
  }

  @override
  String scheduleSummaryWeekly(DateTime weekday) {
    final intl.DateFormat weekdayDateFormat = intl.DateFormat.EEEE(localeName);
    final String weekdayString = weekdayDateFormat.format(weekday);

    return 'Every $weekdayString';
  }

  @override
  String get occurrenceDateLabel => 'Paid on';

  @override
  String get scheduleYearly => 'Yearly';

  @override
  String get formYearlyAnchor => 'Date';

  @override
  String get yearlyAnchorFixed => 'Fixed date';

  @override
  String get yearlyAnchorHolyWednesday => 'Holy Wednesday (Orthodox Easter)';

  @override
  String yearlyAnchorEasterOffset(String offset) {
    return 'Orthodox Easter $offset days';
  }

  @override
  String get formMonth => 'Month';

  @override
  String scheduleSummaryYearlyFixed(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Every year on $dateString';
  }

  @override
  String get scheduleSummaryYearlyHolyWednesday =>
      'Every year on Holy Wednesday';

  @override
  String scheduleSummaryYearlyEaster(String offset) {
    return 'Every year, Orthodox Easter $offset days';
  }

  @override
  String get formCurrency => 'Currency';

  @override
  String get formCurrencyLocked =>
      'The currency cannot be changed. Create a new source to use another currency.';

  @override
  String get currencyOther => 'Other…';

  @override
  String get currencyOtherTitle => 'Other currency';

  @override
  String get currencyOtherField => 'Currency code (3 letters, for example CHF)';

  @override
  String get currencyInvalid => 'Enter a 3-letter currency code';

  @override
  String get shiftShortPrevious => 'previous working day';

  @override
  String get shiftShortNext => 'next working day';

  @override
  String scheduleSummaryWithShift(String summary, String shift) {
    return '$summary · shift: $shift';
  }

  @override
  String get setupTitle => 'Set up your income';

  @override
  String get setupIntro =>
      'Tick what applies to you and enter the amounts. Nothing is saved for a line that is not ticked or has no amount. Amounts are net, as you receive them.';

  @override
  String get setupProfileLabel => 'I am';

  @override
  String get profileEmployee => 'Employee';

  @override
  String get profileFreelancer => 'Freelancer';

  @override
  String get profileSideHustle => 'Side hustle';

  @override
  String get setupMainSection => 'Regular income';

  @override
  String get setupExtraSection => 'Extra payments';

  @override
  String get setupPrivateSectorNote =>
      'These suggestions are for private-sector employees. Public-sector rules are not included.';

  @override
  String get setupSuggested => 'Suggested';

  @override
  String get presetChristmasBonus => 'Christmas bonus';

  @override
  String get presetEasterBonus => 'Easter bonus';

  @override
  String get presetLeaveAllowance => 'Leave allowance';

  @override
  String get amountHintChristmas => 'Roughly up to your net monthly salary';

  @override
  String get amountHintEaster =>
      'Roughly up to half of your net monthly salary';

  @override
  String get amountHintLeave =>
      'Optional. Paid when your leave starts; enter that date';

  @override
  String get setupLeaveDate => 'Date of payment';

  @override
  String get setupAddYearly => 'Add another yearly payment';

  @override
  String get setupCustomName => 'Yearly payment';

  @override
  String get setupRemoveLine => 'Remove this line';

  @override
  String setupLastVerified(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Suggestions last checked on $dateString';
  }

  @override
  String setupDuplicateWarning(String name) {
    return 'A source named \"$name\" already exists. Saving creates another one.';
  }

  @override
  String get setupFinish => 'Create sources';

  @override
  String get setupSkip => 'Skip for now';

  @override
  String get settingsSetupWizard => 'Set up income sources';

  @override
  String get settingsSetupWizardHelp =>
      'Open the setup wizard again to add the regular and extra payments of a profile.';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get expensesAllCategories => 'All categories';

  @override
  String get expensesCategoryLabel => 'Category';

  @override
  String get expensesNone => 'No expenses this month';

  @override
  String get expensesNoneInCategory =>
      'No expenses in this category this month';

  @override
  String get expensesTotal => 'Total';

  @override
  String get expenseAwaitingAmount => 'Awaiting amount';

  @override
  String get categoryEnergy => 'Energy';

  @override
  String get categoryWater => 'Water';

  @override
  String get categoryTelecom => 'Telecommunications';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryFuelTransport => 'Fuel / Transport';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryInsurance => 'Insurance';

  @override
  String get categoryOther => 'Other';

  @override
  String get errorExpenseAmountRequired =>
      'Enter the amount that was charged, or the original amount and its currency';

  @override
  String get errorExpenseOriginalIncomplete =>
      'Enter both the original amount and its currency';

  @override
  String get errorExpenseOriginalSameCurrency =>
      'The original currency must differ from the account currency';

  @override
  String get errorExpenseTaxNoAmount =>
      'VAT/taxes need the amount that was charged';

  @override
  String get errorExpenseTaxTooLarge =>
      'VAT/taxes cannot be more than the total';

  @override
  String get errorExpenseCategory => 'Choose a category';

  @override
  String get errorExpenseNotFound => 'This expense no longer exists';

  @override
  String get expenseAdd => 'Add expense';

  @override
  String get expenseEditTitle => 'Edit expense';

  @override
  String get expenseDescription => 'Description (optional)';

  @override
  String get expenseAccountCurrency => 'Account currency';

  @override
  String get expenseAmountCharged => 'Amount charged';

  @override
  String get expenseAmountChargedHelp =>
      'What left your pocket, as in your bank\'s message or movement.';

  @override
  String get expenseOriginalSection =>
      'Original amount and currency (optional)';

  @override
  String get expenseOriginalAmount => 'Original amount';

  @override
  String get expenseOriginalCurrency => 'Original currency';

  @override
  String get expenseOriginalHelp =>
      'Informational, for example the amount in pounds on a receipt. Nothing is converted.';

  @override
  String get expenseTaxSection => 'Of which VAT / taxes (optional)';

  @override
  String get expenseTaxAmount => 'VAT / taxes';

  @override
  String get expenseTaxHelp =>
      'Informational: part of the total, added to no sum.';

  @override
  String get expensePendingNotice =>
      'No amount has been charged yet. The expense is saved as \"awaiting amount\": it is always listed, but it counts in no total and no balance until you enter the amount that was charged, as in your bank\'s message or movement.';

  @override
  String expenseBeforeBalanceWarning(DateTime start, DateTime suggested) {
    final intl.DateFormat startDateFormat = intl.DateFormat.yMMMd(localeName);
    final String startString = startDateFormat.format(start);
    final intl.DateFormat suggestedDateFormat = intl.DateFormat.yMMMd(
      localeName,
    );
    final String suggestedString = suggestedDateFormat.format(suggested);

    return 'The balance starts on $startString. An expense dated before that is kept in the history and the totals, but it does not change the balance. Choose a date from $suggestedString on.';
  }

  @override
  String expenseUseBalanceStart(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Use $dateString';
  }

  @override
  String get expenseDeleteTitle => 'Delete this expense?';

  @override
  String get expenseDeleteBody => 'It is removed for good.';

  @override
  String get actionDelete => 'Delete';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsOpen => 'Settings';

  @override
  String get settingsPrimaryCurrency => 'Primary currency';

  @override
  String get settingsPrimaryCurrencyHelp =>
      'The default currency of new income sources. Existing sources keep their currency. Amounts in different currencies are never added together.';
}
