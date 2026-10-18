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
}
