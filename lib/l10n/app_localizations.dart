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
