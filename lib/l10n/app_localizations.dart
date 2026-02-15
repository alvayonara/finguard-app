import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @insightNegativeCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Your expenses this month are higher than your income.'**
  String get insightNegativeCashFlow;

  /// No description provided for @insightExpenseSpike.
  ///
  /// In en, this message translates to:
  /// **'Your spending is much higher than usual.'**
  String get insightExpenseSpike;

  /// No description provided for @insightBudgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'You have exceeded your budget limits.'**
  String get insightBudgetExceeded;

  /// No description provided for @insightSpendingSpike.
  ///
  /// In en, this message translates to:
  /// **'Your spending has increased significantly.'**
  String get insightSpendingSpike;

  /// No description provided for @insightStable.
  ///
  /// In en, this message translates to:
  /// **'Your financial condition is stable this week.'**
  String get insightStable;

  /// No description provided for @insightLowRisk.
  ///
  /// In en, this message translates to:
  /// **'Your finances are healthy. Keep it up!'**
  String get insightLowRisk;

  /// No description provided for @insightMediumRisk.
  ///
  /// In en, this message translates to:
  /// **'Your finances need attention.'**
  String get insightMediumRisk;

  /// No description provided for @insightHighRisk.
  ///
  /// In en, this message translates to:
  /// **'Immediate action needed for your finances.'**
  String get insightHighRisk;

  /// No description provided for @recNegativeCashflow.
  ///
  /// In en, this message translates to:
  /// **'Reduce non-essential expenses this month.'**
  String get recNegativeCashflow;

  /// No description provided for @recExpenseSpike.
  ///
  /// In en, this message translates to:
  /// **'Avoid large spending for the next few days.'**
  String get recExpenseSpike;

  /// No description provided for @recBudgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Review your budget and adjust spending.'**
  String get recBudgetExceeded;

  /// No description provided for @recStable.
  ///
  /// In en, this message translates to:
  /// **'Maintain your current spending pattern.'**
  String get recStable;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
