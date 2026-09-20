import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get begin;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @alreadyMemberPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already a member or student?'**
  String get alreadyMemberPrompt;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'A Path of Freedom and Awareness'**
  String get welcomeHeadline;

  /// No description provided for @welcomeSub.
  ///
  /// In en, this message translates to:
  /// **'Teachings, practice and service for\nsincere seekers ready to turn inward.'**
  String get welcomeSub;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Wisdom for the journey'**
  String get onboardTitle1;

  /// No description provided for @onboardBody1.
  ///
  /// In en, this message translates to:
  /// **'Watch, listen and read teachings that\nsupport awareness and conscious living.'**
  String get onboardBody1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Go deeper with InnerSpace'**
  String get onboardTitle2;

  /// No description provided for @onboardBody2.
  ///
  /// In en, this message translates to:
  /// **'Build a steady practice, follow your progress\nand move through a guided path of inner study.'**
  String get onboardBody2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Learn, gather and serve'**
  String get onboardTitle3;

  /// No description provided for @onboardBody3.
  ///
  /// In en, this message translates to:
  /// **'Join programmes, connect with centres\nand help carry the work forward.'**
  String get onboardBody3;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @pageCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String pageCounter(int current, int total);

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @changeAnytimeSettings.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings.'**
  String get changeAnytimeSettings;

  /// No description provided for @searchLanguages.
  ///
  /// In en, this message translates to:
  /// **'Search languages'**
  String get searchLanguages;

  /// No description provided for @moreLanguages.
  ///
  /// In en, this message translates to:
  /// **'More languages'**
  String get moreLanguages;

  /// No description provided for @fewerLanguages.
  ///
  /// In en, this message translates to:
  /// **'Fewer languages'**
  String get fewerLanguages;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @howToContinue.
  ///
  /// In en, this message translates to:
  /// **'How would you like\nto continue?'**
  String get howToContinue;

  /// No description provided for @pathSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore public teachings as a guest, or sign in\nfor your member or student experience.'**
  String get pathSubtitle;

  /// No description provided for @memberOrStudent.
  ///
  /// In en, this message translates to:
  /// **'Member or Student'**
  String get memberOrStudent;

  /// No description provided for @memberCardBody.
  ///
  /// In en, this message translates to:
  /// **'Access your learning, practice and activity.'**
  String get memberCardBody;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @guestCardBody.
  ///
  /// In en, this message translates to:
  /// **'Browse public teachings and programmes.'**
  String get guestCardBody;

  /// No description provided for @otpNote.
  ///
  /// In en, this message translates to:
  /// **'No password needed. We\'ll send a one-time code.'**
  String get otpNote;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'CONSCIOUS LIVING FOR A BRIGHTER HUMANITY'**
  String get brandTagline;

  /// No description provided for @stayConnected.
  ///
  /// In en, this message translates to:
  /// **'Stay connected'**
  String get stayConnected;

  /// No description provided for @stayConnectedSub.
  ///
  /// In en, this message translates to:
  /// **'Receive daily inspiration, practice reminders\nand important programme updates.'**
  String get stayConnectedSub;

  /// No description provided for @dailyInspiration.
  ///
  /// In en, this message translates to:
  /// **'Daily inspiration'**
  String get dailyInspiration;

  /// No description provided for @practiceReminders.
  ///
  /// In en, this message translates to:
  /// **'Practice reminders'**
  String get practiceReminders;

  /// No description provided for @programmeUpdates.
  ///
  /// In en, this message translates to:
  /// **'Programme updates'**
  String get programmeUpdates;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInOptionsSub.
  ///
  /// In en, this message translates to:
  /// **'Sign in using the phone number or email\naddress registered with Jan Cosmic Foundation.'**
  String get signInOptionsSub;

  /// No description provided for @secureAndPrivate.
  ///
  /// In en, this message translates to:
  /// **'SECURE AND PRIVATE'**
  String get secureAndPrivate;

  /// No description provided for @continueWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with Phone'**
  String get continueWithPhone;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get continueWithEmail;

  /// No description provided for @noPasswordNeeded.
  ///
  /// In en, this message translates to:
  /// **'No password needed.'**
  String get noPasswordNeeded;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @codeSentPhone.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to your phone.'**
  String get codeSentPhone;

  /// No description provided for @codeSentEmail.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to your email.'**
  String get codeSentEmail;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get verificationCode;

  /// No description provided for @verifySignIn.
  ///
  /// In en, this message translates to:
  /// **'Verify & sign in'**
  String get verifySignIn;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code.'**
  String get invalidCode;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Use a different phone or email'**
  String get startOver;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @signInWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone'**
  String get signInWithPhone;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email'**
  String get signInWithEmail;

  /// No description provided for @oneTimeCodeSub.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a one-time verification code.'**
  String get oneTimeCodeSub;

  /// No description provided for @useEmailInstead.
  ///
  /// In en, this message translates to:
  /// **'Use Email Instead'**
  String get useEmailInstead;

  /// No description provided for @usePhoneInstead.
  ///
  /// In en, this message translates to:
  /// **'Use Phone Instead'**
  String get usePhoneInstead;

  /// No description provided for @phoneMatchNote.
  ///
  /// In en, this message translates to:
  /// **'Your number must match your JCF membership\nor student record.'**
  String get phoneMatchNote;

  /// No description provided for @emailMatchNote.
  ///
  /// In en, this message translates to:
  /// **'Your email must match your JCF membership\nor student record.'**
  String get emailMatchNote;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// No description provided for @codeSentToMasked.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {destination}.'**
  String codeSentToMasked(String destination);

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify and Continue'**
  String get verifyAndContinue;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time}'**
  String resendCodeIn(String time);

  /// No description provided for @changePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get changePhoneNumber;

  /// No description provided for @changeEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Change email address'**
  String get changeEmailAddress;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resendHelpSub.
  ///
  /// In en, this message translates to:
  /// **'Check your messages or request a new\nverification code.'**
  String get resendHelpSub;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @recordNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find\nyour record'**
  String get recordNotFoundTitle;

  /// No description provided for @recordNotFoundSub.
  ///
  /// In en, this message translates to:
  /// **'The phone number or email you entered is not\nlinked to an approved JCF member or student record.'**
  String get recordNotFoundSub;

  /// No description provided for @tryAnotherDetail.
  ///
  /// In en, this message translates to:
  /// **'Try Another Detail'**
  String get tryAnotherDetail;

  /// No description provided for @approvalPendingChip.
  ///
  /// In en, this message translates to:
  /// **'Approval pending'**
  String get approvalPendingChip;

  /// No description provided for @accessReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your access is\nbeing reviewed'**
  String get accessReviewTitle;

  /// No description provided for @accessReviewSub.
  ///
  /// In en, this message translates to:
  /// **'Your contact was found, but your member or\nstudent access has not been approved yet.'**
  String get accessReviewSub;

  /// No description provided for @browseWhileWaiting.
  ///
  /// In en, this message translates to:
  /// **'You can continue browsing\npublic teachings while you wait.'**
  String get browseWhileWaiting;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check Again'**
  String get checkAgain;

  /// No description provided for @stillPending.
  ///
  /// In en, this message translates to:
  /// **'Still pending — please check back soon.'**
  String get stillPending;

  /// No description provided for @memberStudentContent.
  ///
  /// In en, this message translates to:
  /// **'MEMBER & STUDENT CONTENT'**
  String get memberStudentContent;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @premiumTeachingSub.
  ///
  /// In en, this message translates to:
  /// **'This teaching is available to approved\nJCF members and students.'**
  String get premiumTeachingSub;

  /// No description provided for @returnToPublicTeachings.
  ///
  /// In en, this message translates to:
  /// **'Return to Public Teachings'**
  String get returnToPublicTeachings;
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
      <String>['de', 'en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
