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
}
