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
  String get occurrenceChangeAmount => 'Change amount';

  @override
  String get occurrenceSkip => 'Mark as not received';

  @override
  String get occurrenceReset => 'Restore planned payment';

  @override
  String get amountDialogTitle => 'Change amount';

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
}
