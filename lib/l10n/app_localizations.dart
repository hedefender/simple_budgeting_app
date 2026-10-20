import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_el.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('el'),
    Locale('en'),
  ];

  /// Application title (task switcher, splash screen).
  ///
  /// In en, this message translates to:
  /// **'Simple Budgeting'**
  String get appTitle;

  /// No description provided for @bootstrapStartingCore.
  ///
  /// In en, this message translates to:
  /// **'Starting the calculation engine…'**
  String get bootstrapStartingCore;

  /// No description provided for @bootstrapOpeningDatabase.
  ///
  /// In en, this message translates to:
  /// **'Opening your local database…'**
  String get bootstrapOpeningDatabase;

  /// No description provided for @bootstrapRecordingLaunch.
  ///
  /// In en, this message translates to:
  /// **'Preparing your data…'**
  String get bootstrapRecordingLaunch;

  /// No description provided for @bootstrapFinishing.
  ///
  /// In en, this message translates to:
  /// **'Almost ready…'**
  String get bootstrapFinishing;

  /// No description provided for @bootstrapFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while starting the app'**
  String get bootstrapFailedTitle;

  /// No description provided for @bootstrapRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get bootstrapRetry;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation check'**
  String get homeTitle;

  /// No description provided for @homeIntro.
  ///
  /// In en, this message translates to:
  /// **'Phase 0 is running. Everything below is read from your local database.'**
  String get homeIntro;

  /// No description provided for @homeLaunchCount.
  ///
  /// In en, this message translates to:
  /// **'Launch #{count}'**
  String homeLaunchCount(int count);

  /// No description provided for @homeFirstLaunch.
  ///
  /// In en, this message translates to:
  /// **'First launch: {date}'**
  String homeFirstLaunch(DateTime date);

  /// No description provided for @homeStartupThisLaunch.
  ///
  /// In en, this message translates to:
  /// **'This startup took {milliseconds} ms'**
  String homeStartupThisLaunch(int milliseconds);

  /// No description provided for @homeStartupPreviousLaunch.
  ///
  /// In en, this message translates to:
  /// **'Previous startup took {milliseconds} ms'**
  String homeStartupPreviousLaunch(int milliseconds);

  /// No description provided for @homeStartupNoPrevious.
  ///
  /// In en, this message translates to:
  /// **'No previous startup recorded yet'**
  String get homeStartupNoPrevious;

  /// No description provided for @homeRustCore.
  ///
  /// In en, this message translates to:
  /// **'Rust core: v{version} ({target})'**
  String homeRustCore(String version, String target);

  /// No description provided for @homeLocaleInfo.
  ///
  /// In en, this message translates to:
  /// **'Device locale: {locale} · Currency: {currency}'**
  String homeLocaleInfo(String locale, String currency);

  /// No description provided for @homeMoneySample.
  ///
  /// In en, this message translates to:
  /// **'Sample amount: {amount}'**
  String homeMoneySample(String amount);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get navIncome;

  /// No description provided for @incomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeTitle;

  /// No description provided for @incomeSourcesHeader.
  ///
  /// In en, this message translates to:
  /// **'Income sources'**
  String get incomeSourcesHeader;

  /// No description provided for @incomeNoSources.
  ///
  /// In en, this message translates to:
  /// **'No income sources yet. Add one with the + button.'**
  String get incomeNoSources;

  /// No description provided for @incomeAddSource.
  ///
  /// In en, this message translates to:
  /// **'Add income source'**
  String get incomeAddSource;

  /// No description provided for @incomeEditSource.
  ///
  /// In en, this message translates to:
  /// **'Edit income source'**
  String get incomeEditSource;

  /// No description provided for @incomePreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get incomePreviousMonth;

  /// No description provided for @incomeNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get incomeNextMonth;

  /// No description provided for @incomeMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'{month}'**
  String incomeMonthLabel(DateTime month);

  /// No description provided for @incomeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read your income data'**
  String get incomeLoadError;

  /// No description provided for @incomeRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get incomeRetry;

  /// No description provided for @cashFlowOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get cashFlowOpening;

  /// No description provided for @cashFlowReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get cashFlowReceived;

  /// No description provided for @cashFlowExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get cashFlowExpected;

  /// No description provided for @cashFlowExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get cashFlowExpenses;

  /// No description provided for @cashFlowPendingExpenses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense awaits an amount (not counted)} other{{count} expenses await an amount (not counted)}}'**
  String cashFlowPendingExpenses(int count);

  /// No description provided for @cashFlowBalanceStarts.
  ///
  /// In en, this message translates to:
  /// **'The balance starts on {date}'**
  String cashFlowBalanceStarts(DateTime date);

  /// No description provided for @cashFlowClosing.
  ///
  /// In en, this message translates to:
  /// **'Projected closing balance'**
  String get cashFlowClosing;

  /// No description provided for @cashFlowSetBalance.
  ///
  /// In en, this message translates to:
  /// **'Set balance'**
  String get cashFlowSetBalance;

  /// No description provided for @incomePaymentsHeader.
  ///
  /// In en, this message translates to:
  /// **'Payments this month'**
  String get incomePaymentsHeader;

  /// No description provided for @incomeNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments this month'**
  String get incomeNoPayments;

  /// No description provided for @occurrenceReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get occurrenceReceived;

  /// No description provided for @occurrenceExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get occurrenceExpected;

  /// No description provided for @occurrenceSkipped.
  ///
  /// In en, this message translates to:
  /// **'Not received'**
  String get occurrenceSkipped;

  /// No description provided for @occurrenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{date} · {state}'**
  String occurrenceSubtitle(DateTime date, String state);

  /// No description provided for @occurrenceChangeAmount.
  ///
  /// In en, this message translates to:
  /// **'Change amount or date'**
  String get occurrenceChangeAmount;

  /// No description provided for @occurrenceSkip.
  ///
  /// In en, this message translates to:
  /// **'Mark as not received'**
  String get occurrenceSkip;

  /// No description provided for @occurrenceReset.
  ///
  /// In en, this message translates to:
  /// **'Restore planned payment'**
  String get occurrenceReset;

  /// No description provided for @amountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change payment'**
  String get amountDialogTitle;

  /// No description provided for @amountDialogField.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountDialogField;

  /// No description provided for @typeSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get typeSalary;

  /// No description provided for @typeFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get typeFreelance;

  /// No description provided for @typeSideHustle.
  ///
  /// In en, this message translates to:
  /// **'Side hustle'**
  String get typeSideHustle;

  /// No description provided for @typeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get typeOther;

  /// No description provided for @typeExtraPayment.
  ///
  /// In en, this message translates to:
  /// **'Extra payment'**
  String get typeExtraPayment;

  /// No description provided for @sourceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{type} · {schedule}'**
  String sourceSubtitle(String type, String schedule);

  /// No description provided for @scheduleSummaryOneOff.
  ///
  /// In en, this message translates to:
  /// **'Once on {date}'**
  String scheduleSummaryOneOff(DateTime date);

  /// No description provided for @scheduleSummaryMonthlyDay.
  ///
  /// In en, this message translates to:
  /// **'Monthly on day {day}'**
  String scheduleSummaryMonthlyDay(int day);

  /// No description provided for @scheduleSummaryMonthlyLast.
  ///
  /// In en, this message translates to:
  /// **'Monthly on the last day'**
  String get scheduleSummaryMonthlyLast;

  /// No description provided for @formName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get formName;

  /// No description provided for @formType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get formType;

  /// No description provided for @formAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (net)'**
  String get formAmount;

  /// No description provided for @formSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get formSchedule;

  /// No description provided for @scheduleOneOff.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get scheduleOneOff;

  /// No description provided for @scheduleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get scheduleMonthly;

  /// No description provided for @formDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get formDate;

  /// No description provided for @formDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of the month'**
  String get formDayOfMonth;

  /// No description provided for @formLastDay.
  ///
  /// In en, this message translates to:
  /// **'Last day of the month'**
  String get formLastDay;

  /// No description provided for @formStartDate.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get formStartDate;

  /// No description provided for @formEndDate.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get formEndDate;

  /// No description provided for @formNoEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get formNoEndDate;

  /// No description provided for @formClearEndDate.
  ///
  /// In en, this message translates to:
  /// **'Clear end date'**
  String get formClearEndDate;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get actionArchive;

  /// No description provided for @archiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive this source?'**
  String get archiveConfirmTitle;

  /// No description provided for @archiveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Payments already received stay in your history. No new payments are expected after today.'**
  String get archiveConfirmBody;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get errorNameRequired;

  /// No description provided for @errorAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get errorAmountInvalid;

  /// No description provided for @errorAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'The amount must be greater than zero'**
  String get errorAmountPositive;

  /// No description provided for @errorAmountDecimals.
  ///
  /// In en, this message translates to:
  /// **'At most {digits} decimal places'**
  String errorAmountDecimals(int digits);

  /// No description provided for @errorEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end date is before the start date'**
  String get errorEndBeforeStart;

  /// No description provided for @errorSourceNotFound.
  ///
  /// In en, this message translates to:
  /// **'This income source no longer exists'**
  String get errorSourceNotFound;

  /// No description provided for @errorSourceArchived.
  ///
  /// In en, this message translates to:
  /// **'This income source is archived and can no longer be changed'**
  String get errorSourceArchived;

  /// No description provided for @balanceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set balance'**
  String get balanceDialogTitle;

  /// No description provided for @balanceDialogHelp.
  ///
  /// In en, this message translates to:
  /// **'Your balance at the end of the chosen day. Income after that day is added on top.'**
  String get balanceDialogHelp;

  /// No description provided for @balanceDialogAmount.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceDialogAmount;

  /// No description provided for @balanceDialogDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get balanceDialogDate;

  /// No description provided for @scheduleSeveral.
  ///
  /// In en, this message translates to:
  /// **'Several a month'**
  String get scheduleSeveral;

  /// No description provided for @scheduleWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get scheduleWeekly;

  /// No description provided for @formPaymentDay.
  ///
  /// In en, this message translates to:
  /// **'Payment day {number}'**
  String formPaymentDay(int number);

  /// No description provided for @ruleTypeDay.
  ///
  /// In en, this message translates to:
  /// **'Day of the month'**
  String get ruleTypeDay;

  /// No description provided for @ruleTypeLast.
  ///
  /// In en, this message translates to:
  /// **'Last day of the month'**
  String get ruleTypeLast;

  /// No description provided for @ruleTypeNth.
  ///
  /// In en, this message translates to:
  /// **'Working day of the month'**
  String get ruleTypeNth;

  /// No description provided for @formWorkingDayNumber.
  ///
  /// In en, this message translates to:
  /// **'Working day number'**
  String get formWorkingDayNumber;

  /// No description provided for @formAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add payment day'**
  String get formAddRule;

  /// No description provided for @formRemoveRule.
  ///
  /// In en, this message translates to:
  /// **'Remove payment day'**
  String get formRemoveRule;

  /// No description provided for @formWeekday.
  ///
  /// In en, this message translates to:
  /// **'Weekday'**
  String get formWeekday;

  /// No description provided for @formShift.
  ///
  /// In en, this message translates to:
  /// **'If the day is not a working day'**
  String get formShift;

  /// No description provided for @shiftPrevious.
  ///
  /// In en, this message translates to:
  /// **'Pay on the previous working day'**
  String get shiftPrevious;

  /// No description provided for @shiftNext.
  ///
  /// In en, this message translates to:
  /// **'Pay on the next working day'**
  String get shiftNext;

  /// No description provided for @shiftNone.
  ///
  /// In en, this message translates to:
  /// **'Do not move'**
  String get shiftNone;

  /// No description provided for @errorDuplicateRules.
  ///
  /// In en, this message translates to:
  /// **'Two payment days are the same'**
  String get errorDuplicateRules;

  /// No description provided for @ruleShortDay.
  ///
  /// In en, this message translates to:
  /// **'day {day}'**
  String ruleShortDay(int day);

  /// No description provided for @ruleShortLast.
  ///
  /// In en, this message translates to:
  /// **'last day'**
  String get ruleShortLast;

  /// No description provided for @ruleShortNth.
  ///
  /// In en, this message translates to:
  /// **'working day {n}'**
  String ruleShortNth(int n);

  /// No description provided for @scheduleSummaryMonthlyNth.
  ///
  /// In en, this message translates to:
  /// **'Monthly, working day {n}'**
  String scheduleSummaryMonthlyNth(int n);

  /// No description provided for @scheduleSummarySeveral.
  ///
  /// In en, this message translates to:
  /// **'Monthly on {rules}'**
  String scheduleSummarySeveral(String rules);

  /// No description provided for @scheduleSummaryWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every {weekday}'**
  String scheduleSummaryWeekly(DateTime weekday);

  /// No description provided for @occurrenceDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get occurrenceDateLabel;

  /// No description provided for @scheduleYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get scheduleYearly;

  /// No description provided for @formYearlyAnchor.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get formYearlyAnchor;

  /// No description provided for @yearlyAnchorFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed date'**
  String get yearlyAnchorFixed;

  /// No description provided for @yearlyAnchorHolyWednesday.
  ///
  /// In en, this message translates to:
  /// **'Holy Wednesday (Orthodox Easter)'**
  String get yearlyAnchorHolyWednesday;

  /// No description provided for @yearlyAnchorEasterOffset.
  ///
  /// In en, this message translates to:
  /// **'Orthodox Easter {offset} days'**
  String yearlyAnchorEasterOffset(String offset);

  /// No description provided for @formMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get formMonth;

  /// No description provided for @scheduleSummaryYearlyFixed.
  ///
  /// In en, this message translates to:
  /// **'Every year on {date}'**
  String scheduleSummaryYearlyFixed(DateTime date);

  /// No description provided for @scheduleSummaryYearlyHolyWednesday.
  ///
  /// In en, this message translates to:
  /// **'Every year on Holy Wednesday'**
  String get scheduleSummaryYearlyHolyWednesday;

  /// No description provided for @scheduleSummaryYearlyEaster.
  ///
  /// In en, this message translates to:
  /// **'Every year, Orthodox Easter {offset} days'**
  String scheduleSummaryYearlyEaster(String offset);

  /// No description provided for @formCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get formCurrency;

  /// No description provided for @formCurrencyLocked.
  ///
  /// In en, this message translates to:
  /// **'The currency cannot be changed. Create a new source to use another currency.'**
  String get formCurrencyLocked;

  /// No description provided for @currencyOther.
  ///
  /// In en, this message translates to:
  /// **'Other…'**
  String get currencyOther;

  /// No description provided for @currencyOtherTitle.
  ///
  /// In en, this message translates to:
  /// **'Other currency'**
  String get currencyOtherTitle;

  /// No description provided for @currencyOtherField.
  ///
  /// In en, this message translates to:
  /// **'Currency code (3 letters, for example CHF)'**
  String get currencyOtherField;

  /// No description provided for @currencyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a 3-letter currency code'**
  String get currencyInvalid;

  /// No description provided for @shiftShortPrevious.
  ///
  /// In en, this message translates to:
  /// **'previous working day'**
  String get shiftShortPrevious;

  /// No description provided for @shiftShortNext.
  ///
  /// In en, this message translates to:
  /// **'next working day'**
  String get shiftShortNext;

  /// No description provided for @scheduleSummaryWithShift.
  ///
  /// In en, this message translates to:
  /// **'{summary} · shift: {shift}'**
  String scheduleSummaryWithShift(String summary, String shift);

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your income'**
  String get setupTitle;

  /// No description provided for @setupIntro.
  ///
  /// In en, this message translates to:
  /// **'Tick what applies to you and enter the amounts. Nothing is saved for a line that is not ticked or has no amount. Amounts are net, as you receive them.'**
  String get setupIntro;

  /// No description provided for @setupProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'I am'**
  String get setupProfileLabel;

  /// No description provided for @profileEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get profileEmployee;

  /// No description provided for @profileFreelancer.
  ///
  /// In en, this message translates to:
  /// **'Freelancer'**
  String get profileFreelancer;

  /// No description provided for @profileSideHustle.
  ///
  /// In en, this message translates to:
  /// **'Side hustle'**
  String get profileSideHustle;

  /// No description provided for @setupMainSection.
  ///
  /// In en, this message translates to:
  /// **'Regular income'**
  String get setupMainSection;

  /// No description provided for @setupExtraSection.
  ///
  /// In en, this message translates to:
  /// **'Extra payments'**
  String get setupExtraSection;

  /// No description provided for @setupPrivateSectorNote.
  ///
  /// In en, this message translates to:
  /// **'These suggestions are for private-sector employees. Public-sector rules are not included.'**
  String get setupPrivateSectorNote;

  /// No description provided for @setupSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get setupSuggested;

  /// No description provided for @presetChristmasBonus.
  ///
  /// In en, this message translates to:
  /// **'Christmas bonus'**
  String get presetChristmasBonus;

  /// No description provided for @presetEasterBonus.
  ///
  /// In en, this message translates to:
  /// **'Easter bonus'**
  String get presetEasterBonus;

  /// No description provided for @presetLeaveAllowance.
  ///
  /// In en, this message translates to:
  /// **'Leave allowance'**
  String get presetLeaveAllowance;

  /// No description provided for @amountHintChristmas.
  ///
  /// In en, this message translates to:
  /// **'Roughly up to your net monthly salary'**
  String get amountHintChristmas;

  /// No description provided for @amountHintEaster.
  ///
  /// In en, this message translates to:
  /// **'Roughly up to half of your net monthly salary'**
  String get amountHintEaster;

  /// No description provided for @amountHintLeave.
  ///
  /// In en, this message translates to:
  /// **'Optional. Paid when your leave starts; enter that date'**
  String get amountHintLeave;

  /// No description provided for @setupLeaveDate.
  ///
  /// In en, this message translates to:
  /// **'Date of payment'**
  String get setupLeaveDate;

  /// No description provided for @setupAddYearly.
  ///
  /// In en, this message translates to:
  /// **'Add another yearly payment'**
  String get setupAddYearly;

  /// No description provided for @setupCustomName.
  ///
  /// In en, this message translates to:
  /// **'Yearly payment'**
  String get setupCustomName;

  /// No description provided for @setupRemoveLine.
  ///
  /// In en, this message translates to:
  /// **'Remove this line'**
  String get setupRemoveLine;

  /// No description provided for @setupLastVerified.
  ///
  /// In en, this message translates to:
  /// **'Suggestions last checked on {date}'**
  String setupLastVerified(DateTime date);

  /// No description provided for @setupDuplicateWarning.
  ///
  /// In en, this message translates to:
  /// **'A source named \"{name}\" already exists. Saving creates another one.'**
  String setupDuplicateWarning(String name);

  /// No description provided for @setupFinish.
  ///
  /// In en, this message translates to:
  /// **'Create sources'**
  String get setupFinish;

  /// No description provided for @setupSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get setupSkip;

  /// No description provided for @settingsSetupWizard.
  ///
  /// In en, this message translates to:
  /// **'Set up income sources'**
  String get settingsSetupWizard;

  /// No description provided for @settingsSetupWizardHelp.
  ///
  /// In en, this message translates to:
  /// **'Open the setup wizard again to add the regular and extra payments of a profile.'**
  String get settingsSetupWizardHelp;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @expensesAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get expensesAllCategories;

  /// No description provided for @expensesCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expensesCategoryLabel;

  /// No description provided for @expensesNone.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get expensesNone;

  /// No description provided for @expensesNoneInCategory.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this category this month'**
  String get expensesNoneInCategory;

  /// No description provided for @expensesTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get expensesTotal;

  /// No description provided for @expenseAwaitingAmount.
  ///
  /// In en, this message translates to:
  /// **'Awaiting amount'**
  String get expenseAwaitingAmount;

  /// No description provided for @categoryEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get categoryEnergy;

  /// No description provided for @categoryWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get categoryWater;

  /// No description provided for @categoryTelecom.
  ///
  /// In en, this message translates to:
  /// **'Telecommunications'**
  String get categoryTelecom;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryFuelTransport.
  ///
  /// In en, this message translates to:
  /// **'Fuel / Transport'**
  String get categoryFuelTransport;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get categoryInsurance;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @errorExpenseAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount that was charged, or the original amount and its currency'**
  String get errorExpenseAmountRequired;

  /// No description provided for @errorExpenseOriginalIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter both the original amount and its currency'**
  String get errorExpenseOriginalIncomplete;

  /// No description provided for @errorExpenseOriginalSameCurrency.
  ///
  /// In en, this message translates to:
  /// **'The original currency must differ from the account currency'**
  String get errorExpenseOriginalSameCurrency;

  /// No description provided for @errorExpenseTaxNoAmount.
  ///
  /// In en, this message translates to:
  /// **'VAT/taxes need the amount that was charged'**
  String get errorExpenseTaxNoAmount;

  /// No description provided for @errorExpenseTaxTooLarge.
  ///
  /// In en, this message translates to:
  /// **'VAT/taxes cannot be more than the total'**
  String get errorExpenseTaxTooLarge;

  /// No description provided for @errorExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get errorExpenseCategory;

  /// No description provided for @errorExpenseNotFound.
  ///
  /// In en, this message translates to:
  /// **'This expense no longer exists'**
  String get errorExpenseNotFound;

  /// No description provided for @errorExpenseDocumentNotFound.
  ///
  /// In en, this message translates to:
  /// **'The document of this expense no longer exists'**
  String get errorExpenseDocumentNotFound;

  /// No description provided for @expenseAdd.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expenseAdd;

  /// No description provided for @expenseEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get expenseEditTitle;

  /// No description provided for @expenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get expenseDescription;

  /// No description provided for @expenseAccountCurrency.
  ///
  /// In en, this message translates to:
  /// **'Account currency'**
  String get expenseAccountCurrency;

  /// No description provided for @expenseAmountCharged.
  ///
  /// In en, this message translates to:
  /// **'Amount charged'**
  String get expenseAmountCharged;

  /// No description provided for @expenseAmountChargedHelp.
  ///
  /// In en, this message translates to:
  /// **'What left your pocket, as in your bank\'s message or movement.'**
  String get expenseAmountChargedHelp;

  /// No description provided for @expenseOriginalSection.
  ///
  /// In en, this message translates to:
  /// **'Original amount and currency (optional)'**
  String get expenseOriginalSection;

  /// No description provided for @expenseOriginalAmount.
  ///
  /// In en, this message translates to:
  /// **'Original amount'**
  String get expenseOriginalAmount;

  /// No description provided for @expenseOriginalCurrency.
  ///
  /// In en, this message translates to:
  /// **'Original currency'**
  String get expenseOriginalCurrency;

  /// No description provided for @expenseOriginalHelp.
  ///
  /// In en, this message translates to:
  /// **'Informational, for example the amount in pounds on a receipt. Nothing is converted.'**
  String get expenseOriginalHelp;

  /// No description provided for @expenseTaxSection.
  ///
  /// In en, this message translates to:
  /// **'Of which VAT / taxes (optional)'**
  String get expenseTaxSection;

  /// No description provided for @expenseTaxAmount.
  ///
  /// In en, this message translates to:
  /// **'VAT / taxes'**
  String get expenseTaxAmount;

  /// No description provided for @expenseTaxHelp.
  ///
  /// In en, this message translates to:
  /// **'Informational: part of the total, added to no sum.'**
  String get expenseTaxHelp;

  /// No description provided for @expensePendingNotice.
  ///
  /// In en, this message translates to:
  /// **'No amount has been charged yet. The expense is saved as \"awaiting amount\": it is always listed, but it counts in no total and no balance until you enter the amount that was charged, as in your bank\'s message or movement.'**
  String get expensePendingNotice;

  /// No description provided for @expenseBeforeBalanceWarning.
  ///
  /// In en, this message translates to:
  /// **'The balance starts on {start}. An expense dated before that is kept in the history and the totals, but it does not change the balance. Choose a date from {suggested} on.'**
  String expenseBeforeBalanceWarning(DateTime start, DateTime suggested);

  /// No description provided for @expenseUseBalanceStart.
  ///
  /// In en, this message translates to:
  /// **'Use {date}'**
  String expenseUseBalanceStart(DateTime date);

  /// No description provided for @expenseDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this expense?'**
  String get expenseDeleteTitle;

  /// No description provided for @expenseDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It is removed for good.'**
  String get expenseDeleteBody;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsOpen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsOpen;

  /// No description provided for @settingsPrimaryCurrency.
  ///
  /// In en, this message translates to:
  /// **'Primary currency'**
  String get settingsPrimaryCurrency;

  /// No description provided for @settingsPrimaryCurrencyHelp.
  ///
  /// In en, this message translates to:
  /// **'The default currency of new income sources. Existing sources keep their currency. Amounts in different currencies are never added together.'**
  String get settingsPrimaryCurrencyHelp;

  /// No description provided for @navDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get navDocuments;

  /// No description provided for @documentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsTitle;

  /// No description provided for @documentsImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get documentsImport;

  /// No description provided for @documentsImportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import Scan JSON files'**
  String get documentsImportTooltip;

  /// No description provided for @documentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get documentsEmptyTitle;

  /// No description provided for @documentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Import the JSON files that Scan exports. Your documents stay on this device.'**
  String get documentsEmptyBody;

  /// No description provided for @documentLinkedChip.
  ///
  /// In en, this message translates to:
  /// **'Expense linked'**
  String get documentLinkedChip;

  /// No description provided for @documentLegacyChip.
  ///
  /// In en, this message translates to:
  /// **'Legacy format'**
  String get documentLegacyChip;

  /// No description provided for @documentNoTitle.
  ///
  /// In en, this message translates to:
  /// **'(no text)'**
  String get documentNoTitle;

  /// No description provided for @importInProgress.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importInProgress;

  /// No description provided for @importReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import report'**
  String get importReportTitle;

  /// No description provided for @importSummaryImported.
  ///
  /// In en, this message translates to:
  /// **'Imported: {count}'**
  String importSummaryImported(int count);

  /// No description provided for @importSummaryDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Already imported: {count}'**
  String importSummaryDuplicate(int count);

  /// No description provided for @importSummaryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {count}'**
  String importSummaryFailed(int count);

  /// No description provided for @importSummarySkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped: {count}'**
  String importSummarySkipped(int count);

  /// No description provided for @importResultImported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get importResultImported;

  /// No description provided for @importResultDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Already imported'**
  String get importResultDuplicate;

  /// No description provided for @importResultSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped: not a JSON file'**
  String get importResultSkipped;

  /// No description provided for @importTooManyFiles.
  ///
  /// In en, this message translates to:
  /// **'Too many files: choose at most {limit} at a time.'**
  String importTooManyFiles(int limit);

  /// No description provided for @importPickError.
  ///
  /// In en, this message translates to:
  /// **'The file chooser could not be opened.'**
  String get importPickError;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get importDone;

  /// No description provided for @importErrorEmptyFile.
  ///
  /// In en, this message translates to:
  /// **'The file is empty.'**
  String get importErrorEmptyFile;

  /// No description provided for @importErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is too large ({size}; the limit is {limit}).'**
  String importErrorTooLarge(String size, String limit);

  /// No description provided for @importErrorNotUtf8.
  ///
  /// In en, this message translates to:
  /// **'The file is not valid UTF-8 text.'**
  String get importErrorNotUtf8;

  /// No description provided for @importErrorInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Not valid JSON.'**
  String get importErrorInvalidJson;

  /// No description provided for @importErrorInvalidJsonAt.
  ///
  /// In en, this message translates to:
  /// **'Not valid JSON (line {line}, column {column}).'**
  String importErrorInvalidJsonAt(int line, int column);

  /// No description provided for @importErrorNotAnObject.
  ///
  /// In en, this message translates to:
  /// **'The file must contain a JSON object.'**
  String get importErrorNotAnObject;

  /// No description provided for @importErrorMissingField.
  ///
  /// In en, this message translates to:
  /// **'The field {field} is missing.'**
  String importErrorMissingField(String field);

  /// No description provided for @importErrorWrongType.
  ///
  /// In en, this message translates to:
  /// **'The field {field} has the wrong type.'**
  String importErrorWrongType(String field);

  /// No description provided for @importErrorEmptyOcrText.
  ///
  /// In en, this message translates to:
  /// **'The OCR text is empty.'**
  String get importErrorEmptyOcrText;

  /// No description provided for @importErrorInvalidDocumentId.
  ///
  /// In en, this message translates to:
  /// **'The documentId is empty or longer than 128 characters.'**
  String get importErrorInvalidDocumentId;

  /// No description provided for @importErrorInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'createdAt is not a valid ISO 8601 date and time.'**
  String get importErrorInvalidDate;

  /// No description provided for @importErrorEmptyFileName.
  ///
  /// In en, this message translates to:
  /// **'The file name in {field} is empty.'**
  String importErrorEmptyFileName(String field);

  /// No description provided for @importErrorUnsupportedVersion.
  ///
  /// In en, this message translates to:
  /// **'This file uses schema version {found}; this app understands up to version {known}. Update the app. Nothing was imported.'**
  String importErrorUnsupportedVersion(int found, int known);

  /// No description provided for @importErrorReadError.
  ///
  /// In en, this message translates to:
  /// **'The file could not be read.'**
  String get importErrorReadError;

  /// No description provided for @importErrorStorageError.
  ///
  /// In en, this message translates to:
  /// **'The document could not be saved.'**
  String get importErrorStorageError;

  /// No description provided for @importErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error.'**
  String get importErrorUnexpected;

  /// No description provided for @documentDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get documentDetailTitle;

  /// No description provided for @documentNotFound.
  ///
  /// In en, this message translates to:
  /// **'This document no longer exists.'**
  String get documentNotFound;

  /// No description provided for @documentCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get documentCreatedLabel;

  /// No description provided for @documentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Document id'**
  String get documentIdLabel;

  /// No description provided for @documentSourceLine.
  ///
  /// In en, this message translates to:
  /// **'Imported from {file} on {date}'**
  String documentSourceLine(String file, DateTime date);

  /// No description provided for @documentLegacyNote.
  ///
  /// In en, this message translates to:
  /// **'Read from the legacy Scan format.'**
  String get documentLegacyNote;

  /// No description provided for @documentLanguageLine.
  ///
  /// In en, this message translates to:
  /// **'Language: {code}'**
  String documentLanguageLine(String code);

  /// No description provided for @documentPdfLine.
  ///
  /// In en, this message translates to:
  /// **'PDF: {name}'**
  String documentPdfLine(String name);

  /// No description provided for @documentImagesLine.
  ///
  /// In en, this message translates to:
  /// **'Images ({count}): {names}'**
  String documentImagesLine(int count, String names);

  /// No description provided for @documentFilesNotStored.
  ///
  /// In en, this message translates to:
  /// **'These files are not stored in the app.'**
  String get documentFilesNotStored;

  /// No description provided for @documentOcrHeader.
  ///
  /// In en, this message translates to:
  /// **'Text (OCR)'**
  String get documentOcrHeader;

  /// No description provided for @documentTextTruncated.
  ///
  /// In en, this message translates to:
  /// **'Showing the first {shown} of {total} characters.'**
  String documentTextTruncated(int shown, int total);

  /// No description provided for @documentShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get documentShowAll;

  /// No description provided for @documentCreateExpense.
  ///
  /// In en, this message translates to:
  /// **'Create expense'**
  String get documentCreateExpense;

  /// No description provided for @documentExpensesHeader.
  ///
  /// In en, this message translates to:
  /// **'Expenses from this document'**
  String get documentExpensesHeader;

  /// No description provided for @documentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete document'**
  String get documentDelete;

  /// No description provided for @documentDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this document?'**
  String get documentDeleteTitle;

  /// No description provided for @documentDeleteBodyPlain.
  ///
  /// In en, this message translates to:
  /// **'The document and its text are removed from this device. You can import it again later.'**
  String get documentDeleteBodyPlain;

  /// No description provided for @documentDeleteBodyExpenses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 linked expense stays, without the link to the document.} other{{count} linked expenses stay, without the link to the document.}}'**
  String documentDeleteBodyExpenses(int count);

  /// No description provided for @documentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Document deleted'**
  String get documentDeleted;

  /// No description provided for @expenseFromDocument.
  ///
  /// In en, this message translates to:
  /// **'From the document of {date}'**
  String expenseFromDocument(DateTime date);

  /// No description provided for @expenseOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'View document'**
  String get expenseOpenDocument;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['el', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
