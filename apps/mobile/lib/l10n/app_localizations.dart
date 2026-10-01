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

  /// No description provided for @sessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired'**
  String get sessionExpiredTitle;

  /// No description provided for @sessionExpiredSub.
  ///
  /// In en, this message translates to:
  /// **'For your security, please verify your\nidentity again to continue.'**
  String get sessionExpiredSub;

  /// No description provided for @signInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign In Again'**
  String get signInAgain;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

  /// No description provided for @signOutWarning.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need a new verification code\nto access your member or student\naccount again.'**
  String get signOutWarning;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirm;

  /// No description provided for @staySignedIn.
  ///
  /// In en, this message translates to:
  /// **'Stay Signed In'**
  String get staySignedIn;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get tabLearn;

  /// No description provided for @tabPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get tabPractice;

  /// No description provided for @tabPrograms.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get tabPrograms;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @dailyInspirationEyebrow.
  ///
  /// In en, this message translates to:
  /// **'DAILY INSPIRATION'**
  String get dailyInspirationEyebrow;

  /// No description provided for @defaultQuote.
  ///
  /// In en, this message translates to:
  /// **'“Freedom begins when awareness becomes your way of living.”'**
  String get defaultQuote;

  /// No description provided for @readReflection.
  ///
  /// In en, this message translates to:
  /// **'Read Reflection'**
  String get readReflection;

  /// No description provided for @beginYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Begin Your Journey'**
  String get beginYourJourney;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @watchATeaching.
  ///
  /// In en, this message translates to:
  /// **'Watch a Teaching'**
  String get watchATeaching;

  /// No description provided for @watchTeachingSub.
  ///
  /// In en, this message translates to:
  /// **'Insights for a\nbrighter tomorrow'**
  String get watchTeachingSub;

  /// No description provided for @tryAPractice.
  ///
  /// In en, this message translates to:
  /// **'Try a Practice'**
  String get tryAPractice;

  /// No description provided for @tryPracticeSub.
  ///
  /// In en, this message translates to:
  /// **'Simple tools\nfor everyday life'**
  String get tryPracticeSub;

  /// No description provided for @findAProgramme.
  ///
  /// In en, this message translates to:
  /// **'Find a Programme'**
  String get findAProgramme;

  /// No description provided for @findProgrammeSub.
  ///
  /// In en, this message translates to:
  /// **'Go deeper\nat your own pace'**
  String get findProgrammeSub;

  /// No description provided for @liveUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Live & Upcoming'**
  String get liveUpcoming;

  /// No description provided for @latestPublicTeachings.
  ///
  /// In en, this message translates to:
  /// **'Latest Public Teachings'**
  String get latestPublicTeachings;

  /// No description provided for @signInBanner.
  ///
  /// In en, this message translates to:
  /// **'Sign in for your member or student experience'**
  String get signInBanner;

  /// No description provided for @signInBannerSub.
  ///
  /// In en, this message translates to:
  /// **'Access guided practices, programmes, live events and more.'**
  String get signInBannerSub;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @welcomeBackName.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,\n{name}'**
  String welcomeBackName(String name);

  /// No description provided for @memberChip.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberChip;

  /// No description provided for @studentChip.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get studentChip;

  /// No description provided for @memberTagline.
  ///
  /// In en, this message translates to:
  /// **'A more conscious you creates a brighter tomorrow.'**
  String get memberTagline;

  /// No description provided for @studentTagline.
  ///
  /// In en, this message translates to:
  /// **'A calmer mind. A brighter you.'**
  String get studentTagline;

  /// No description provided for @continueLearningEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE LEARNING'**
  String get continueLearningEyebrow;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @upcomingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get upcomingEyebrow;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @announcementEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ANNOUNCEMENT'**
  String get announcementEyebrow;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @myCard.
  ///
  /// In en, this message translates to:
  /// **'My Card'**
  String get myCard;

  /// No description provided for @myCardSub.
  ///
  /// In en, this message translates to:
  /// **'Your membership'**
  String get myCardSub;

  /// No description provided for @consultationAction.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultationAction;

  /// No description provided for @consultationSub.
  ///
  /// In en, this message translates to:
  /// **'Seek guidance'**
  String get consultationSub;

  /// No description provided for @giveAction.
  ///
  /// In en, this message translates to:
  /// **'Give'**
  String get giveAction;

  /// No description provided for @giveSub.
  ///
  /// In en, this message translates to:
  /// **'Support our work'**
  String get giveSub;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get myGroups;

  /// No description provided for @myGroupsSub.
  ///
  /// In en, this message translates to:
  /// **'Connect & grow'**
  String get myGroupsSub;

  /// No description provided for @innerspaceJourneyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'INNERSPACE JOURNEY'**
  String get innerspaceJourneyEyebrow;

  /// No description provided for @continueLesson.
  ///
  /// In en, this message translates to:
  /// **'Continue Lesson'**
  String get continueLesson;

  /// No description provided for @todaysPractice.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Practice'**
  String get todaysPractice;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @quickActionsSub.
  ///
  /// In en, this message translates to:
  /// **'Everything you need, close at hand.'**
  String get quickActionsSub;

  /// No description provided for @membershipCardTitle.
  ///
  /// In en, this message translates to:
  /// **'My Membership Card'**
  String get membershipCardTitle;

  /// No description provided for @membershipCardSub.
  ///
  /// In en, this message translates to:
  /// **'Your Jan Cosmic identity'**
  String get membershipCardSub;

  /// No description provided for @bookConsultation.
  ///
  /// In en, this message translates to:
  /// **'Book Consultation'**
  String get bookConsultation;

  /// No description provided for @bookConsultationSub.
  ///
  /// In en, this message translates to:
  /// **'Connect with our guides'**
  String get bookConsultationSub;

  /// No description provided for @giveTileSub.
  ///
  /// In en, this message translates to:
  /// **'Support a brighter tomorrow'**
  String get giveTileSub;

  /// No description provided for @myGroupsTileSub.
  ///
  /// In en, this message translates to:
  /// **'Find your community'**
  String get myGroupsTileSub;

  /// No description provided for @guidanceRequest.
  ///
  /// In en, this message translates to:
  /// **'Guidance Request'**
  String get guidanceRequest;

  /// No description provided for @guidanceRequestSub.
  ///
  /// In en, this message translates to:
  /// **'Ask. Explore. Evolve.'**
  String get guidanceRequestSub;

  /// No description provided for @findCentre.
  ///
  /// In en, this message translates to:
  /// **'Find a Centre'**
  String get findCentre;

  /// No description provided for @findCentreSub.
  ///
  /// In en, this message translates to:
  /// **'Locate a Jan Cosmic Centre near you'**
  String get findCentreSub;

  /// No description provided for @myRegistrations.
  ///
  /// In en, this message translates to:
  /// **'My Registrations'**
  String get myRegistrations;

  /// No description provided for @myRegistrationsSub.
  ///
  /// In en, this message translates to:
  /// **'Events and programs you\'re part of'**
  String get myRegistrationsSub;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @shopSub.
  ///
  /// In en, this message translates to:
  /// **'Conscious choices for a better world'**
  String get shopSub;

  /// No description provided for @downloadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// No description provided for @downloadsSub.
  ///
  /// In en, this message translates to:
  /// **'Resources for your journey'**
  String get downloadsSub;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSub.
  ///
  /// In en, this message translates to:
  /// **'Personalize your experience'**
  String get settingsSub;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This part of the app is on its way.\nCheck back shortly.'**
  String get comingSoonBody;

  /// No description provided for @exploreRelated.
  ///
  /// In en, this message translates to:
  /// **'Explore Related Teaching'**
  String get exploreRelated;

  /// No description provided for @shareLabel.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareLabel;

  /// No description provided for @shareInspirationTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Inspiration'**
  String get shareInspirationTitle;

  /// No description provided for @shareInspirationSub.
  ///
  /// In en, this message translates to:
  /// **'Create and share a message that uplifts.\nSpread awareness. Inspire a better tomorrow.'**
  String get shareInspirationSub;

  /// No description provided for @chooseStyle.
  ///
  /// In en, this message translates to:
  /// **'Choose a style'**
  String get chooseStyle;

  /// No description provided for @differentLooks.
  ///
  /// In en, this message translates to:
  /// **'Different looks. Same message.'**
  String get differentLooks;

  /// No description provided for @styleLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get styleLight;

  /// No description provided for @styleCosmic.
  ///
  /// In en, this message translates to:
  /// **'Cosmic'**
  String get styleCosmic;

  /// No description provided for @styleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get styleMinimal;

  /// No description provided for @continueLearningTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearningTitle;

  /// No description provided for @activeSeriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active series'**
  String activeSeriesCount(int count);

  /// No description provided for @lessonsCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons completed'**
  String lessonsCompletedCount(int count);

  /// No description provided for @resumeLesson.
  ///
  /// In en, this message translates to:
  /// **'Resume Lesson'**
  String get resumeLesson;

  /// No description provided for @lessonXofY.
  ///
  /// In en, this message translates to:
  /// **'Lesson {x} of {y}'**
  String lessonXofY(int x, int y);

  /// No description provided for @recentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get recentlyViewed;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get filterVideo;

  /// No description provided for @filterAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get filterAudio;

  /// No description provided for @viewedToday.
  ///
  /// In en, this message translates to:
  /// **'Viewed today'**
  String get viewedToday;

  /// No description provided for @viewedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Viewed yesterday'**
  String get viewedYesterday;

  /// No description provided for @viewedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Viewed {days} days ago'**
  String viewedDaysAgo(int days);

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as complete'**
  String get markComplete;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// No description provided for @nothingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Nothing in progress yet.\nOpen a lesson to begin your journey.'**
  String get nothingInProgress;

  /// No description provided for @continuePracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue Practice'**
  String get continuePracticeTitle;

  /// No description provided for @practiceTagline.
  ///
  /// In en, this message translates to:
  /// **'A more conscious you, a brighter world.'**
  String get practiceTagline;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak'**
  String dayStreak(int days);

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get keepGoing;

  /// No description provided for @practicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} practices'**
  String practicesCount(int count);

  /// No description provided for @thisWeekShort.
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get thisWeekShort;

  /// No description provided for @todaysPracticeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S PRACTICE'**
  String get todaysPracticeEyebrow;

  /// No description provided for @guidedAudio.
  ///
  /// In en, this message translates to:
  /// **'Guided audio'**
  String get guidedAudio;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{min} min'**
  String minutesShort(int min);

  /// No description provided for @thisWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeekTitle;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @weeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get weeklyGoal;

  /// No description provided for @nOfGoalPractices.
  ///
  /// In en, this message translates to:
  /// **'{done} of {goal} practices'**
  String nOfGoalPractices(int done, int goal);

  /// No description provided for @yourPractices.
  ///
  /// In en, this message translates to:
  /// **'Your Practices'**
  String get yourPractices;

  /// No description provided for @viewPracticeHistory.
  ///
  /// In en, this message translates to:
  /// **'View Practice History'**
  String get viewPracticeHistory;

  /// No description provided for @playAudio.
  ///
  /// In en, this message translates to:
  /// **'Play audio'**
  String get playAudio;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markDone;

  /// No description provided for @doneToday.
  ///
  /// In en, this message translates to:
  /// **'Done for today'**
  String get doneToday;

  /// No description provided for @upcomingActivitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Activities'**
  String get upcomingActivitiesTitle;

  /// No description provided for @upcomingActivitiesTagline.
  ///
  /// In en, this message translates to:
  /// **'Join, learn and grow together'**
  String get upcomingActivitiesTagline;

  /// No description provided for @filterProgrammes.
  ///
  /// In en, this message translates to:
  /// **'Programmes'**
  String get filterProgrammes;

  /// No description provided for @filterLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get filterLive;

  /// No description provided for @filterPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get filterPractice;

  /// No description provided for @todaySection.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todaySection;

  /// No description provided for @tomorrowSection.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrowSection;

  /// No description provided for @laterSection.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterSection;

  /// No description provided for @liveSoonBadge.
  ///
  /// In en, this message translates to:
  /// **'Live Soon'**
  String get liveSoonBadge;

  /// No description provided for @onlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineLabel;

  /// No description provided for @audiencePublic.
  ///
  /// In en, this message translates to:
  /// **'All are welcome'**
  String get audiencePublic;

  /// No description provided for @audienceMembers.
  ///
  /// In en, this message translates to:
  /// **'Members & students'**
  String get audienceMembers;

  /// No description provided for @audienceStudents.
  ///
  /// In en, this message translates to:
  /// **'Students only'**
  String get audienceStudents;

  /// No description provided for @reminderOnSnack.
  ///
  /// In en, this message translates to:
  /// **'Reminder set — we\'ll notify you.'**
  String get reminderOnSnack;

  /// No description provided for @reminderOffSnack.
  ///
  /// In en, this message translates to:
  /// **'Reminder removed.'**
  String get reminderOffSnack;

  /// No description provided for @signInForReminders.
  ///
  /// In en, this message translates to:
  /// **'Sign in to set reminders.'**
  String get signInForReminders;

  /// No description provided for @noUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled yet. Check back soon.'**
  String get noUpcoming;

  /// No description provided for @announcementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementsTitle;

  /// No description provided for @announcementsTagline.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with the latest from the JCF community.'**
  String get announcementsTagline;

  /// No description provided for @chipGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get chipGeneral;

  /// No description provided for @chipMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get chipMembers;

  /// No description provided for @chipStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get chipStudents;

  /// No description provided for @pinnedAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Pinned Announcement'**
  String get pinnedAnnouncement;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet. Check back soon.'**
  String get noAnnouncements;

  /// No description provided for @headerTagline.
  ///
  /// In en, this message translates to:
  /// **'Awareness for a Better Tomorrow'**
  String get headerTagline;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchJcfTitle.
  ///
  /// In en, this message translates to:
  /// **'Search JCF'**
  String get searchJcfTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search teachings, programmes and more'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearLabel;

  /// No description provided for @browseByCategory.
  ///
  /// In en, this message translates to:
  /// **'Browse by Category'**
  String get browseByCategory;

  /// No description provided for @categoryTeachings.
  ///
  /// In en, this message translates to:
  /// **'Teachings'**
  String get categoryTeachings;

  /// No description provided for @categoryPractices.
  ///
  /// In en, this message translates to:
  /// **'Practices'**
  String get categoryPractices;

  /// No description provided for @categoryProgrammes.
  ///
  /// In en, this message translates to:
  /// **'Programmes'**
  String get categoryProgrammes;

  /// No description provided for @categoryEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get categoryEvents;

  /// No description provided for @categoryCentres.
  ///
  /// In en, this message translates to:
  /// **'Centres'**
  String get categoryCentres;

  /// No description provided for @popularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearches;

  /// No description provided for @resultsFor.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}} for “{query}”'**
  String resultsFor(int count, String query);

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”. Try another word.'**
  String noResults(String query);

  /// No description provided for @allLevelsChip.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get allLevelsChip;

  /// No description provided for @kindVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get kindVideo;

  /// No description provided for @kindAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get kindAudio;

  /// No description provided for @kindPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get kindPractice;

  /// No description provided for @kindProgramme.
  ///
  /// In en, this message translates to:
  /// **'Programme'**
  String get kindProgramme;

  /// No description provided for @kindEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get kindEvent;

  /// No description provided for @kindCentre.
  ///
  /// In en, this message translates to:
  /// **'Centre'**
  String get kindCentre;

  /// No description provided for @kindAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get kindAnnouncement;

  /// No description provided for @alreadyPartOfJcf.
  ///
  /// In en, this message translates to:
  /// **'Already part of JCF?'**
  String get alreadyPartOfJcf;

  /// No description provided for @statusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get statusLive;

  /// No description provided for @statusStartingSoon.
  ///
  /// In en, this message translates to:
  /// **'Starting soon'**
  String get statusStartingSoon;

  /// No description provided for @statusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statusUpcoming;

  /// No description provided for @joinLive.
  ///
  /// In en, this message translates to:
  /// **'Join Live'**
  String get joinLive;

  /// No description provided for @welcomeBackGeneric.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBackGeneric;

  /// No description provided for @continueYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Continue Your Journey'**
  String get continueYourJourney;

  /// No description provided for @viewActivity.
  ///
  /// In en, this message translates to:
  /// **'View Activity'**
  String get viewActivity;

  /// No description provided for @continueLearningCta.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearningCta;

  /// No description provided for @continuePracticeCta.
  ///
  /// In en, this message translates to:
  /// **'Continue Practice'**
  String get continuePracticeCta;

  /// No description provided for @forMembers.
  ///
  /// In en, this message translates to:
  /// **'For Members'**
  String get forMembers;

  /// No description provided for @memberExclusive.
  ///
  /// In en, this message translates to:
  /// **'MEMBER EXCLUSIVE'**
  String get memberExclusive;

  /// No description provided for @watchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch Now'**
  String get watchNow;

  /// No description provided for @listenNow.
  ///
  /// In en, this message translates to:
  /// **'Listen Now'**
  String get listenNow;

  /// No description provided for @readNow.
  ///
  /// In en, this message translates to:
  /// **'Read Now'**
  String get readNow;

  /// No description provided for @startCourse.
  ///
  /// In en, this message translates to:
  /// **'Start Course'**
  String get startCourse;

  /// No description provided for @exploreSeries.
  ///
  /// In en, this message translates to:
  /// **'Explore Series'**
  String get exploreSeries;

  /// No description provided for @communitySection.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communitySection;

  /// No description provided for @readUpdate.
  ///
  /// In en, this message translates to:
  /// **'Read Update'**
  String get readUpdate;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsTitle;

  /// No description provided for @myLibrary.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get myLibrary;

  /// No description provided for @myPrograms.
  ///
  /// In en, this message translates to:
  /// **'My Programs'**
  String get myPrograms;

  /// No description provided for @savedLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedLabel;

  /// No description provided for @downloadsLabel.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsLabel;

  /// No description provided for @lessonProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} lessons'**
  String lessonProgress(int done, int total);

  /// No description provided for @remainingTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String remainingTime(int minutes);

  /// No description provided for @watchReplay.
  ///
  /// In en, this message translates to:
  /// **'Watch Replay'**
  String get watchReplay;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events'**
  String get noUpcomingEvents;

  /// No description provided for @offlineShowingSaved.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing saved content'**
  String get offlineShowingSaved;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @sectionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This section couldn\'t load.'**
  String get sectionUnavailable;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @studentChipLabel.
  ///
  /// In en, this message translates to:
  /// **'JCF Student'**
  String get studentChipLabel;

  /// No description provided for @myProgramEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MY PROGRAM'**
  String get myProgramEyebrow;

  /// No description provided for @continueProgram.
  ///
  /// In en, this message translates to:
  /// **'Continue Program'**
  String get continueProgram;

  /// No description provided for @viewAllPrograms.
  ///
  /// In en, this message translates to:
  /// **'View All Programs'**
  String get viewAllPrograms;

  /// No description provided for @todaysLearning.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Learning'**
  String get todaysLearning;

  /// No description provided for @nextLiveClass.
  ///
  /// In en, this message translates to:
  /// **'Next Live Class'**
  String get nextLiveClass;

  /// No description provided for @viewSchedule.
  ///
  /// In en, this message translates to:
  /// **'View Schedule'**
  String get viewSchedule;

  /// No description provided for @yourProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgressTitle;

  /// No description provided for @mentorSupport.
  ///
  /// In en, this message translates to:
  /// **'Mentor Support'**
  String get mentorSupport;

  /// No description provided for @importantUpdates.
  ///
  /// In en, this message translates to:
  /// **'Important Updates'**
  String get importantUpdates;

  /// No description provided for @startLesson.
  ///
  /// In en, this message translates to:
  /// **'Start Lesson'**
  String get startLesson;

  /// No description provided for @nextLesson.
  ///
  /// In en, this message translates to:
  /// **'Next Lesson'**
  String get nextLesson;

  /// No description provided for @reviewLesson.
  ///
  /// In en, this message translates to:
  /// **'Review Lesson'**
  String get reviewLesson;

  /// No description provided for @beginPractice.
  ///
  /// In en, this message translates to:
  /// **'Begin Practice'**
  String get beginPractice;

  /// No description provided for @reviewPractice.
  ///
  /// In en, this message translates to:
  /// **'Review Practice'**
  String get reviewPractice;

  /// No description provided for @completeNow.
  ///
  /// In en, this message translates to:
  /// **'Complete Now'**
  String get completeNow;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get allCaughtUp;

  /// No description provided for @joinClass.
  ///
  /// In en, this message translates to:
  /// **'Join Class'**
  String get joinClass;

  /// No description provided for @viewClassSummary.
  ///
  /// In en, this message translates to:
  /// **'View Class Summary'**
  String get viewClassSummary;

  /// No description provided for @viewUpdate.
  ///
  /// In en, this message translates to:
  /// **'View Update'**
  String get viewUpdate;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusReplay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get statusReplay;

  /// No description provided for @statusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get statusNotStarted;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get statusDueSoon;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusExcused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get statusExcused;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @priorityImportant.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get priorityImportant;

  /// No description provided for @messageMentor.
  ///
  /// In en, this message translates to:
  /// **'Message Mentor'**
  String get messageMentor;

  /// No description provided for @viewMentor.
  ///
  /// In en, this message translates to:
  /// **'View Mentor'**
  String get viewMentor;

  /// No description provided for @noMentorAssigned.
  ///
  /// In en, this message translates to:
  /// **'No mentor assigned yet - programme support can help.'**
  String get noMentorAssigned;

  /// No description provided for @viewProgress.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  /// No description provided for @milestoneLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get milestoneLocked;

  /// No description provided for @milestoneAchieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get milestoneAchieved;

  /// No description provided for @myCourses.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get myCourses;

  /// No description provided for @scheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleLabel;

  /// No description provided for @assignmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignmentsLabel;

  /// No description provided for @lessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} lessons'**
  String lessonsCompleted(int done, int total);

  /// No description provided for @practicesCompleted.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} practices'**
  String practicesCompleted(int done, int total);

  /// No description provided for @programProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'Program progress, {percent} percent complete.'**
  String programProgressSemantics(int percent);

  /// No description provided for @dueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueLabel(String date);

  /// No description provided for @accessExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Your access has expired'**
  String get accessExpiredTitle;

  /// No description provided for @programPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'This programme is paused'**
  String get programPausedTitle;

  /// No description provided for @noProgramEnrolled.
  ///
  /// In en, this message translates to:
  /// **'You are not enrolled in a programme yet.'**
  String get noProgramEnrolled;

  /// No description provided for @pauseAndReflect.
  ///
  /// In en, this message translates to:
  /// **'Pause and Reflect'**
  String get pauseAndReflect;

  /// No description provided for @markAsReflected.
  ///
  /// In en, this message translates to:
  /// **'Mark as Reflected'**
  String get markAsReflected;

  /// No description provided for @reflectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Reflected'**
  String get reflectedLabel;

  /// No description provided for @undoReflected.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoReflected;

  /// No description provided for @saveForLater.
  ///
  /// In en, this message translates to:
  /// **'Save for Later'**
  String get saveForLater;

  /// No description provided for @savedLabel2.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedLabel2;

  /// No description provided for @continueReflecting.
  ///
  /// In en, this message translates to:
  /// **'Continue Reflecting'**
  String get continueReflecting;

  /// No description provided for @shareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get shareAsImage;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @previewCard.
  ///
  /// In en, this message translates to:
  /// **'Preview Card'**
  String get previewCard;

  /// No description provided for @previousInspiration.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousInspiration;

  /// No description provided for @nextInspiration.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextInspiration;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @readingTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String readingTime(int minutes);

  /// No description provided for @inspirationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This inspiration is no longer available.'**
  String get inspirationUnavailable;

  /// No description provided for @exploreLatest.
  ///
  /// In en, this message translates to:
  /// **'Explore Latest Inspirations'**
  String get exploreLatest;

  /// No description provided for @signInToSave.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save this inspiration.'**
  String get signInToSave;

  /// No description provided for @signInToReflect.
  ///
  /// In en, this message translates to:
  /// **'Sign in to record your reflection.'**
  String get signInToReflect;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get openInBrowser;

  /// No description provided for @listenToReflection.
  ///
  /// In en, this message translates to:
  /// **'Listen to this reflection'**
  String get listenToReflection;

  /// No description provided for @createShareCard.
  ///
  /// In en, this message translates to:
  /// **'Create Share Card'**
  String get createShareCard;

  /// No description provided for @resetLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetLabel;

  /// No description provided for @formatSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get formatSquare;

  /// No description provided for @formatStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get formatStory;

  /// No description provided for @chooseAStyle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Style'**
  String get chooseAStyle;

  /// No description provided for @textAlignment.
  ///
  /// In en, this message translates to:
  /// **'Text Alignment'**
  String get textAlignment;

  /// No description provided for @alignStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get alignStart;

  /// No description provided for @alignCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get alignCenter;

  /// No description provided for @alignEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get alignEnd;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get textColor;

  /// No description provided for @textLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get textLight;

  /// No description provided for @textDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get textDark;

  /// No description provided for @sizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get sizeSmall;

  /// No description provided for @sizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sizeMedium;

  /// No description provided for @sizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get sizeLarge;

  /// No description provided for @showLogo.
  ///
  /// In en, this message translates to:
  /// **'Show Logo'**
  String get showLogo;

  /// No description provided for @showSource.
  ///
  /// In en, this message translates to:
  /// **'Show Source'**
  String get showSource;

  /// No description provided for @showWebsite.
  ///
  /// In en, this message translates to:
  /// **'Show Website'**
  String get showWebsite;

  /// No description provided for @saveImage.
  ///
  /// In en, this message translates to:
  /// **'Save Image'**
  String get saveImage;

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved to your gallery'**
  String get imageSaved;

  /// No description provided for @unableToGenerate.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate the image.'**
  String get unableToGenerate;

  /// No description provided for @unableToSave.
  ///
  /// In en, this message translates to:
  /// **'Unable to save the image.'**
  String get unableToSave;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo permission denied. Allow access in Settings to save.'**
  String get permissionDenied;

  /// No description provided for @sharingNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This inspiration cannot be shared.'**
  String get sharingNotAllowed;

  /// No description provided for @templateCosmic.
  ///
  /// In en, this message translates to:
  /// **'Cosmic'**
  String get templateCosmic;

  /// No description provided for @templateDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get templateDawn;

  /// No description provided for @templateStillness.
  ///
  /// In en, this message translates to:
  /// **'Stillness'**
  String get templateStillness;

  /// No description provided for @templateLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get templateLight;

  /// No description provided for @shareCardPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Share card preview. {style} style, {format} format, {alignment} text.'**
  String shareCardPreviewLabel(String style, String format, String alignment);

  /// No description provided for @liveNow.
  ///
  /// In en, this message translates to:
  /// **'Live Now'**
  String get liveNow;

  /// No description provided for @liveEvent.
  ///
  /// In en, this message translates to:
  /// **'Live Event'**
  String get liveEvent;

  /// No description provided for @replayTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replayTitle;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get statusEnded;

  /// No description provided for @goLive.
  ///
  /// In en, this message translates to:
  /// **'Go Live'**
  String get goLive;

  /// No description provided for @reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get reconnecting;

  /// No description provided for @chatTab.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTab;

  /// No description provided for @aboutTab.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTab;

  /// No description provided for @joinTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Join the conversation'**
  String get joinTheConversation;

  /// No description provided for @signInToParticipate.
  ///
  /// In en, this message translates to:
  /// **'Sign in to participate'**
  String get signInToParticipate;

  /// No description provided for @chatReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Chat is read-only'**
  String get chatReadOnly;

  /// No description provided for @chatClosed.
  ///
  /// In en, this message translates to:
  /// **'Chat is closed'**
  String get chatClosed;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @followLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followLabel;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind Me'**
  String get remindMe;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get addToCalendar;

  /// No description provided for @replayProcessing.
  ///
  /// In en, this message translates to:
  /// **'Replay Processing'**
  String get replayProcessing;

  /// No description provided for @streamWillBeginHere.
  ///
  /// In en, this message translates to:
  /// **'The stream will begin here'**
  String get streamWillBeginHere;

  /// No description provided for @streamUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This stream is unavailable right now.'**
  String get streamUnavailable;

  /// No description provided for @eventCancelled.
  ///
  /// In en, this message translates to:
  /// **'This event was cancelled.'**
  String get eventCancelled;

  /// No description provided for @eventRescheduled.
  ///
  /// In en, this message translates to:
  /// **'This event was rescheduled.'**
  String get eventRescheduled;

  /// No description provided for @signInToWatch.
  ///
  /// In en, this message translates to:
  /// **'Sign in to watch this session.'**
  String get signInToWatch;

  /// No description provided for @membersOnlyEvent.
  ///
  /// In en, this message translates to:
  /// **'This session is for members and students.'**
  String get membersOnlyEvent;

  /// No description provided for @studentsOnlyEvent.
  ///
  /// In en, this message translates to:
  /// **'This session is for enrolled students.'**
  String get studentsOnlyEvent;

  /// No description provided for @viewerCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 watching} other{{count} watching}}'**
  String viewerCount(int count);

  /// No description provided for @reportMessage.
  ///
  /// In en, this message translates to:
  /// **'Report message'**
  String get reportMessage;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// No description provided for @messageReported.
  ///
  /// In en, this message translates to:
  /// **'Reported to the moderators.'**
  String get messageReported;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'You will not see their messages.'**
  String get userBlocked;

  /// No description provided for @slowModeOn.
  ///
  /// In en, this message translates to:
  /// **'Slow mode is on. Try again in {seconds}s.'**
  String slowModeOn(int seconds);

  /// No description provided for @reactAppreciate.
  ///
  /// In en, this message translates to:
  /// **'Appreciate'**
  String get reactAppreciate;

  /// No description provided for @reactThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you'**
  String get reactThanks;

  /// No description provided for @reactInsight.
  ///
  /// In en, this message translates to:
  /// **'Insightful'**
  String get reactInsight;

  /// No description provided for @reactLabel.
  ///
  /// In en, this message translates to:
  /// **'React'**
  String get reactLabel;

  /// No description provided for @eventLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get eventLanguage;

  /// No description provided for @eventSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get eventSchedule;

  /// No description provided for @eventFacilitator.
  ///
  /// In en, this message translates to:
  /// **'Facilitator'**
  String get eventFacilitator;

  /// No description provided for @captionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Captions'**
  String get captionsLabel;

  /// No description provided for @startsIn.
  ///
  /// In en, this message translates to:
  /// **'Starts in {time}'**
  String startsIn(String time);

  /// No description provided for @playLabel.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playLabel;

  /// No description provided for @pauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseLabel;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get readLess;

  /// No description provided for @activitiesListView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get activitiesListView;

  /// No description provided for @activitiesCalendarView.
  ///
  /// In en, this message translates to:
  /// **'Calendar view'**
  String get activitiesCalendarView;

  /// No description provided for @activitiesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search activities'**
  String get activitiesSearchHint;

  /// No description provided for @activitiesFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get activitiesFilterButton;

  /// No description provided for @activitiesFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter activities'**
  String get activitiesFiltersTitle;

  /// No description provided for @activitiesFilterTypeGroup.
  ///
  /// In en, this message translates to:
  /// **'Activity type'**
  String get activitiesFilterTypeGroup;

  /// No description provided for @activitiesFilterLanguageGroup.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get activitiesFilterLanguageGroup;

  /// No description provided for @activitiesFilterFeeGroup.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get activitiesFilterFeeGroup;

  /// No description provided for @activitiesFilterAccessGroup.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get activitiesFilterAccessGroup;

  /// No description provided for @activitiesFilterFeeAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get activitiesFilterFeeAny;

  /// No description provided for @activitiesFilterFeeFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get activitiesFilterFeeFree;

  /// No description provided for @activitiesFilterFeePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get activitiesFilterFeePaid;

  /// No description provided for @activitiesFilterOpenToMe.
  ///
  /// In en, this message translates to:
  /// **'Only what I can join'**
  String get activitiesFilterOpenToMe;

  /// No description provided for @activitiesFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get activitiesFilterApply;

  /// No description provided for @activitiesFilterClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get activitiesFilterClearAll;

  /// No description provided for @activitiesChipAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get activitiesChipAll;

  /// No description provided for @activitiesChipLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get activitiesChipLive;

  /// No description provided for @activitiesChipOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get activitiesChipOnline;

  /// No description provided for @activitiesChipInPerson.
  ///
  /// In en, this message translates to:
  /// **'In person'**
  String get activitiesChipInPerson;

  /// No description provided for @activitiesFeaturedEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get activitiesFeaturedEyebrow;

  /// No description provided for @activitiesToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get activitiesToday;

  /// No description provided for @activitiesTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get activitiesTomorrow;

  /// No description provided for @activitiesThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get activitiesThisWeek;

  /// No description provided for @activitiesAllDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get activitiesAllDay;

  /// No description provided for @activitiesFormatOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get activitiesFormatOnline;

  /// No description provided for @activitiesFormatInPerson.
  ///
  /// In en, this message translates to:
  /// **'In person'**
  String get activitiesFormatInPerson;

  /// No description provided for @activitiesFormatHybrid.
  ///
  /// In en, this message translates to:
  /// **'In person & online'**
  String get activitiesFormatHybrid;

  /// No description provided for @activitiesFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get activitiesFree;

  /// No description provided for @activitiesRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get activitiesRegister;

  /// No description provided for @activitiesRegistered.
  ///
  /// In en, this message translates to:
  /// **'You\'re registered'**
  String get activitiesRegistered;

  /// No description provided for @activitiesJoinWaitlist.
  ///
  /// In en, this message translates to:
  /// **'Join waitlist'**
  String get activitiesJoinWaitlist;

  /// No description provided for @activitiesWaitlisted.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the waitlist'**
  String get activitiesWaitlisted;

  /// No description provided for @activitiesRegistrationFull.
  ///
  /// In en, this message translates to:
  /// **'Fully booked'**
  String get activitiesRegistrationFull;

  /// No description provided for @activitiesRegistrationClosed.
  ///
  /// In en, this message translates to:
  /// **'Registration closed'**
  String get activitiesRegistrationClosed;

  /// No description provided for @activitiesRegistrationOpensOn.
  ///
  /// In en, this message translates to:
  /// **'Opens {date}'**
  String activitiesRegistrationOpensOn(String date);

  /// No description provided for @activitiesRegisterExternally.
  ///
  /// In en, this message translates to:
  /// **'Register on the website'**
  String get activitiesRegisterExternally;

  /// No description provided for @activitiesCancelRegistration.
  ///
  /// In en, this message translates to:
  /// **'Cancel my place'**
  String get activitiesCancelRegistration;

  /// No description provided for @activitiesSeatsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place left} other{{count} places left}}'**
  String activitiesSeatsLeft(int count);

  /// No description provided for @activitiesCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get activitiesCancelled;

  /// No description provided for @activitiesRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get activitiesRescheduled;

  /// No description provided for @activitiesMembersOnly.
  ///
  /// In en, this message translates to:
  /// **'Members only'**
  String get activitiesMembersOnly;

  /// No description provided for @activitiesStudentsOnly.
  ///
  /// In en, this message translates to:
  /// **'Students only'**
  String get activitiesStudentsOnly;

  /// No description provided for @activitiesSignInToJoin.
  ///
  /// In en, this message translates to:
  /// **'Sign in to join'**
  String get activitiesSignInToJoin;

  /// No description provided for @activitiesNothingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get activitiesNothingScheduled;

  /// No description provided for @activitiesNothingScheduledBody.
  ///
  /// In en, this message translates to:
  /// **'There are no activities on this day yet. Try another week.'**
  String get activitiesNothingScheduledBody;

  /// No description provided for @activitiesNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No activities match'**
  String get activitiesNoMatches;

  /// No description provided for @activitiesNoMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter or clear them all.'**
  String get activitiesNoMatchesBody;

  /// No description provided for @activitiesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the schedule'**
  String get activitiesLoadFailed;

  /// No description provided for @activitiesLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get activitiesLoadFailedBody;

  /// No description provided for @activitiesRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get activitiesRetry;

  /// No description provided for @activitiesOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing a saved copy from {when}'**
  String activitiesOfflineNotice(String when);

  /// No description provided for @activitiesRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete that. Please try again.'**
  String get activitiesRegistrationFailed;

  /// No description provided for @activitiesRegistrationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'You\'re registered for {title}'**
  String activitiesRegistrationConfirmed(String title);

  /// No description provided for @activitiesWaitlistConfirmed.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the waitlist for {title}'**
  String activitiesWaitlistConfirmed(String title);

  /// No description provided for @activitiesPlaceReleased.
  ///
  /// In en, this message translates to:
  /// **'Your place has been released'**
  String get activitiesPlaceReleased;

  /// No description provided for @activitiesSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved to your list'**
  String get activitiesSavedSnack;

  /// No description provided for @activitiesUnsavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Removed from your list'**
  String get activitiesUnsavedSnack;

  /// No description provided for @activitiesPreviousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get activitiesPreviousWeek;

  /// No description provided for @activitiesNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get activitiesNextWeek;

  /// No description provided for @activitiesPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get activitiesPreviousMonth;

  /// No description provided for @activitiesNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get activitiesNextMonth;

  /// No description provided for @activitiesClearDay.
  ///
  /// In en, this message translates to:
  /// **'Show all dates'**
  String get activitiesClearDay;

  /// No description provided for @activitiesFilterCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Filters} =1{Filters (1)} other{Filters ({count})}}'**
  String activitiesFilterCount(int count);

  /// No description provided for @learnHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get learnHubTitle;

  /// No description provided for @learnResumeLabel.
  ///
  /// In en, this message translates to:
  /// **'RESUME WHERE YOU LEFT OFF'**
  String get learnResumeLabel;

  /// No description provided for @learnResumeSection.
  ///
  /// In en, this message translates to:
  /// **'Resume where you left off'**
  String get learnResumeSection;

  /// No description provided for @learnStartLesson.
  ///
  /// In en, this message translates to:
  /// **'Start Lesson'**
  String get learnStartLesson;

  /// No description provided for @learnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get learnContinue;

  /// No description provided for @learnNextLesson.
  ///
  /// In en, this message translates to:
  /// **'Next Lesson'**
  String get learnNextLesson;

  /// No description provided for @learnReviewLesson.
  ///
  /// In en, this message translates to:
  /// **'Review Lesson'**
  String get learnReviewLesson;

  /// No description provided for @learnJoinLive.
  ///
  /// In en, this message translates to:
  /// **'Join Live'**
  String get learnJoinLive;

  /// No description provided for @learnRetryDownload.
  ///
  /// In en, this message translates to:
  /// **'Retry Download'**
  String get learnRetryDownload;

  /// No description provided for @learnViewAccess.
  ///
  /// In en, this message translates to:
  /// **'View Access'**
  String get learnViewAccess;

  /// No description provided for @learnRemaining.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String learnRemaining(int minutes);

  /// No description provided for @learnPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String learnPercentComplete(int percent);

  /// No description provided for @learnSummaryLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons completed'**
  String get learnSummaryLessons;

  /// No description provided for @learnSummaryStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get learnSummaryStreak;

  /// No description provided for @learnSummaryDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get learnSummaryDownloads;

  /// No description provided for @learnSummaryCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses completed'**
  String get learnSummaryCourses;

  /// No description provided for @learnActiveCourses.
  ///
  /// In en, this message translates to:
  /// **'Your Active Courses'**
  String get learnActiveCourses;

  /// No description provided for @learnSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get learnSeeAll;

  /// No description provided for @learnStartCourse.
  ///
  /// In en, this message translates to:
  /// **'Start Course'**
  String get learnStartCourse;

  /// No description provided for @learnReviewCourse.
  ///
  /// In en, this message translates to:
  /// **'Review Course'**
  String get learnReviewCourse;

  /// No description provided for @learnViewCourse.
  ///
  /// In en, this message translates to:
  /// **'View Course'**
  String get learnViewCourse;

  /// No description provided for @learnUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get learnUpNext;

  /// No description provided for @learnRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get learnRecommended;

  /// No description provided for @learnLessonCount.
  ///
  /// In en, this message translates to:
  /// **'{modules,plural,=0{{lessons,plural,=1{1 lesson}other{{lessons} lessons}}}other{{modules,plural,=1{1 module}other{{modules} modules}}}}'**
  String learnLessonCount(int modules, int lessons);

  /// No description provided for @learnLessonsOnly.
  ///
  /// In en, this message translates to:
  /// **'{lessons,plural,=1{1 lesson}other{{lessons} lessons}}'**
  String learnLessonsOnly(int lessons);

  /// No description provided for @learnTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get learnTypeVideo;

  /// No description provided for @learnTypeAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get learnTypeAudio;

  /// No description provided for @learnTypeWritten.
  ///
  /// In en, this message translates to:
  /// **'Written'**
  String get learnTypeWritten;

  /// No description provided for @learnTypeReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get learnTypeReflection;

  /// No description provided for @learnTypePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get learnTypePractice;

  /// No description provided for @learnTypeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get learnTypeQuiz;

  /// No description provided for @learnTypeLive.
  ///
  /// In en, this message translates to:
  /// **'Live session'**
  String get learnTypeLive;

  /// No description provided for @learnTypeResource.
  ///
  /// In en, this message translates to:
  /// **'Resource'**
  String get learnTypeResource;

  /// No description provided for @learnStatusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get learnStatusNotStarted;

  /// No description provided for @learnStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get learnStatusInProgress;

  /// No description provided for @learnStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get learnStatusCompleted;

  /// No description provided for @learnStatusLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get learnStatusLocked;

  /// No description provided for @learnStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Access expired'**
  String get learnStatusExpired;

  /// No description provided for @learnStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get learnStatusPaused;

  /// No description provided for @learnDownloadDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Available offline'**
  String get learnDownloadDownloaded;

  /// No description provided for @learnDownloadDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get learnDownloadDownloading;

  /// No description provided for @learnDownloadQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get learnDownloadQueued;

  /// No description provided for @learnDownloadPaused.
  ///
  /// In en, this message translates to:
  /// **'Download paused'**
  String get learnDownloadPaused;

  /// No description provided for @learnDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get learnDownloadFailed;

  /// No description provided for @learnDownloadExpired.
  ///
  /// In en, this message translates to:
  /// **'Download expired'**
  String get learnDownloadExpired;

  /// No description provided for @learnDownloadUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get learnDownloadUpdate;

  /// No description provided for @learnPrerequisiteTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish this first'**
  String get learnPrerequisiteTitle;

  /// No description provided for @learnPrerequisiteBody.
  ///
  /// In en, this message translates to:
  /// **'Complete {title} to unlock this lesson.'**
  String learnPrerequisiteBody(String title);

  /// No description provided for @learnOpenPrerequisite.
  ///
  /// In en, this message translates to:
  /// **'Open {title}'**
  String learnOpenPrerequisite(String title);

  /// No description provided for @learnEmptyResumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to resume yet'**
  String get learnEmptyResumeTitle;

  /// No description provided for @learnEmptyResumeBody.
  ///
  /// In en, this message translates to:
  /// **'Start a course and it will wait for you here.'**
  String get learnEmptyResumeBody;

  /// No description provided for @learnEmptyResumeAction.
  ///
  /// In en, this message translates to:
  /// **'Start a Course'**
  String get learnEmptyResumeAction;

  /// No description provided for @learnEmptyCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no active courses'**
  String get learnEmptyCoursesTitle;

  /// No description provided for @learnEmptyCoursesBody.
  ///
  /// In en, this message translates to:
  /// **'Browse the library or look through the programmes.'**
  String get learnEmptyCoursesBody;

  /// No description provided for @learnEmptyCoursesAction.
  ///
  /// In en, this message translates to:
  /// **'Browse Learning'**
  String get learnEmptyCoursesAction;

  /// No description provided for @learnEmptyUpNextTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get learnEmptyUpNextTitle;

  /// No description provided for @learnEmptyUpNextBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting. Explore what we recommend next.'**
  String get learnEmptyUpNextBody;

  /// No description provided for @learnErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your learning'**
  String get learnErrorTitle;

  /// No description provided for @learnErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get learnErrorBody;

  /// No description provided for @learnRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get learnRetry;

  /// No description provided for @learnOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing a saved copy from {when}'**
  String learnOfflineNotice(String when);

  /// No description provided for @learnFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter lessons'**
  String get learnFiltersTitle;

  /// No description provided for @learnFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get learnFilterStatus;

  /// No description provided for @learnFilterType.
  ///
  /// In en, this message translates to:
  /// **'Lesson type'**
  String get learnFilterType;

  /// No description provided for @learnFilterDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded only'**
  String get learnFilterDownloaded;

  /// No description provided for @learnFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get learnFilterApply;

  /// No description provided for @learnFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get learnFilterClear;

  /// No description provided for @learnFilterAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get learnFilterAny;

  /// No description provided for @learnFilterCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural,=0{Filters}other{Filters ({count})}}'**
  String learnFilterCount(int count);

  /// No description provided for @learnMyDownloads.
  ///
  /// In en, this message translates to:
  /// **'My Downloads'**
  String get learnMyDownloads;

  /// No description provided for @learnHistory.
  ///
  /// In en, this message translates to:
  /// **'Learning History'**
  String get learnHistory;

  /// No description provided for @learnCompletedCourses.
  ///
  /// In en, this message translates to:
  /// **'Completed Courses'**
  String get learnCompletedCourses;

  /// No description provided for @learnHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get learnHelp;

  /// No description provided for @learnSemanticCourse.
  ///
  /// In en, this message translates to:
  /// **'{title}. {percent} percent complete. Current lesson: {lesson}.'**
  String learnSemanticCourse(String title, int percent, String lesson);

  /// No description provided for @splashFoundationName.
  ///
  /// In en, this message translates to:
  /// **'JAN COSMIC FOUNDATION'**
  String get splashFoundationName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Awaken. Learn. Transform.'**
  String get splashTagline;

  /// No description provided for @splashPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your experience…'**
  String get splashPreparing;

  /// No description provided for @splashStillPreparing.
  ///
  /// In en, this message translates to:
  /// **'Still preparing…'**
  String get splashStillPreparing;

  /// No description provided for @splashStartupFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t start the app.'**
  String get splashStartupFailed;

  /// No description provided for @splashCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get splashCheckConnection;

  /// No description provided for @splashTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get splashTryAgain;

  /// No description provided for @splashContinueOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue Offline'**
  String get splashContinueOffline;

  /// No description provided for @splashUpdateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'A new version is required'**
  String get splashUpdateRequiredTitle;

  /// No description provided for @splashUpdateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Update to keep using the app. This version is no longer supported.'**
  String get splashUpdateRequiredMessage;

  /// No description provided for @splashUpdateApp.
  ///
  /// In en, this message translates to:
  /// **'Update App'**
  String get splashUpdateApp;

  /// No description provided for @splashMaintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll be back shortly'**
  String get splashMaintenanceTitle;

  /// No description provided for @splashMaintenanceMessage.
  ///
  /// In en, this message translates to:
  /// **'The app is briefly unavailable while we make an improvement.'**
  String get splashMaintenanceMessage;

  /// No description provided for @splashGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get splashGenericError;

  /// No description provided for @splashLogoLabel.
  ///
  /// In en, this message translates to:
  /// **'Jan Cosmic Foundation logo'**
  String get splashLogoLabel;

  /// No description provided for @splashLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get splashLoadingLabel;

  /// No description provided for @welcomeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'WELCOME'**
  String get welcomeEyebrow;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Begin your journey within'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore timeless teachings, guided practices, and a community devoted to conscious living.'**
  String get welcomeDescription;

  /// No description provided for @welcomeAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create account'**
  String get welcomeAccountAction;

  /// No description provided for @welcomeGuestAction.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get welcomeGuestAction;

  /// No description provided for @welcomeAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the'**
  String get welcomeAgreementPrefix;

  /// No description provided for @welcomeAgreementJoin.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get welcomeAgreementJoin;

  /// No description provided for @welcomeTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get welcomeTermsOfUse;

  /// No description provided for @welcomePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get welcomePrivacyPolicy;

  /// No description provided for @welcomeLanguageSelector.
  ///
  /// In en, this message translates to:
  /// **'Language: {language}'**
  String welcomeLanguageSelector(String language);

  /// No description provided for @welcomeChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get welcomeChooseLanguage;

  /// No description provided for @welcomeGuestFailure.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t continue as a guest. Please try again.'**
  String get welcomeGuestFailure;

  /// No description provided for @welcomeLanguageFailure.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t change the language.'**
  String get welcomeLanguageFailure;

  /// No description provided for @welcomeRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get welcomeRetry;

  /// No description provided for @legalUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Not published yet'**
  String get legalUnavailableTitle;

  /// No description provided for @legalUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This document has not been published. Please check back, or contact the foundation.'**
  String get legalUnavailableBody;

  /// No description provided for @legalLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this document.'**
  String get legalLoadFailed;

  /// No description provided for @legalLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String legalLastUpdated(String date);

  /// No description provided for @legalShownInEnglish.
  ///
  /// In en, this message translates to:
  /// **'Shown in English; a translation is not yet available.'**
  String get legalShownInEnglish;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingPagePosition.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String onboardingPagePosition(int current, int total);

  /// No description provided for @onboardingCompletionFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your progress. Please try again.'**
  String get onboardingCompletionFailed;

  /// No description provided for @onboardingTeachingsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'TEACHINGS'**
  String get onboardingTeachingsEyebrow;

  /// No description provided for @onboardingTeachingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover timeless teachings'**
  String get onboardingTeachingsTitle;

  /// No description provided for @onboardingTeachingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore wisdom through video, audio, and written teachings designed for everyday life.'**
  String get onboardingTeachingsDescription;

  /// No description provided for @onboardingInnerSpaceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'INNERSPACE'**
  String get onboardingInnerSpaceEyebrow;

  /// No description provided for @onboardingInnerSpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Go deeper within'**
  String get onboardingInnerSpaceTitle;

  /// No description provided for @onboardingInnerSpaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Build a personal practice with guided meditation, reflection, and tools for inner awareness.'**
  String get onboardingInnerSpaceDescription;

  /// No description provided for @onboardingCommunityEyebrow.
  ///
  /// In en, this message translates to:
  /// **'COMMUNITY & SERVICE'**
  String get onboardingCommunityEyebrow;

  /// No description provided for @onboardingCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Grow together. Serve with purpose.'**
  String get onboardingCommunityTitle;

  /// No description provided for @onboardingCommunityDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect with others, join meaningful programs, and turn inner growth into compassionate action.'**
  String get onboardingCommunityDescription;

  /// No description provided for @languageSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageSelectionTitle;

  /// No description provided for @languageSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings.'**
  String get languageSelectionDescription;

  /// No description provided for @languageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search languages'**
  String get languageSearchHint;

  /// No description provided for @languageSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search field'**
  String get languageSearchClear;

  /// No description provided for @languageContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get languageContinue;

  /// No description provided for @languageNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No languages found'**
  String get languageNoResultsTitle;

  /// No description provided for @languageNoResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Try a different language name or code.'**
  String get languageNoResultsDescription;

  /// No description provided for @languageClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get languageClearSearch;

  /// No description provided for @languageSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get languageSelected;

  /// No description provided for @languageDirectionRtl.
  ///
  /// In en, this message translates to:
  /// **'RTL'**
  String get languageDirectionRtl;

  /// No description provided for @languageDirectionRtlLabel.
  ///
  /// In en, this message translates to:
  /// **'Right-to-left script'**
  String get languageDirectionRtlLabel;

  /// No description provided for @languageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your language. Please try again.'**
  String get languageSaveFailed;

  /// No description provided for @languageRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get languageRetry;

  /// No description provided for @languageResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No languages} =1{1 language} other{{count} languages}}'**
  String languageResultCount(int count);

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageSwahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get languageSwahili;

  /// No description provided for @notificationPermissionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'STAY CONNECTED'**
  String get notificationPermissionEyebrow;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your journey in reach'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications for live sessions, practice reminders, program updates, and important announcements.'**
  String get notificationPermissionDescription;

  /// No description provided for @notificationBenefitLiveSessions.
  ///
  /// In en, this message translates to:
  /// **'Live session reminders'**
  String get notificationBenefitLiveSessions;

  /// No description provided for @notificationBenefitPractice.
  ///
  /// In en, this message translates to:
  /// **'Daily practice prompts'**
  String get notificationBenefitPractice;

  /// No description provided for @notificationBenefitUpdates.
  ///
  /// In en, this message translates to:
  /// **'Important updates'**
  String get notificationBenefitUpdates;

  /// No description provided for @notificationPermissionEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationPermissionEnable;

  /// No description provided for @notificationPermissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notificationPermissionNotNow;

  /// No description provided for @notificationPermissionControlMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re in control. Change this anytime in Settings.'**
  String get notificationPermissionControlMessage;

  /// No description provided for @notificationPermissionRequesting.
  ///
  /// In en, this message translates to:
  /// **'Asking your device…'**
  String get notificationPermissionRequesting;

  /// No description provided for @notificationPermissionEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are enabled'**
  String get notificationPermissionEnabled;

  /// No description provided for @notificationPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get notificationPermissionDeniedTitle;

  /// No description provided for @notificationPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'You can turn them on anytime in Settings. Everything else in the app works as usual.'**
  String get notificationPermissionDeniedMessage;

  /// No description provided for @notificationPermissionBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked'**
  String get notificationPermissionBlockedTitle;

  /// No description provided for @notificationPermissionBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your device is blocking notifications for this app. You can allow them in Settings.'**
  String get notificationPermissionBlockedMessage;

  /// No description provided for @notificationPermissionRestrictedMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications are restricted on this device and can\'t be turned on from here.'**
  String get notificationPermissionRestrictedMessage;

  /// No description provided for @notificationPermissionUnsupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'This device doesn\'t support notifications. Everything else in the app works as usual.'**
  String get notificationPermissionUnsupportedMessage;

  /// No description provided for @notificationPermissionNotReachableMessage.
  ///
  /// In en, this message translates to:
  /// **'Permission granted. Sending notifications isn\'t switched on in this version of the app yet, so none will arrive for now.'**
  String get notificationPermissionNotReachableMessage;

  /// No description provided for @notificationPermissionRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Permission granted, but this device couldn\'t be registered, so notifications won\'t arrive yet.'**
  String get notificationPermissionRegistrationFailed;

  /// No description provided for @notificationPermissionRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t ask for permission. Please try again.'**
  String get notificationPermissionRequestFailed;

  /// No description provided for @notificationPermissionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your choice. Please try again.'**
  String get notificationPermissionSaveFailed;

  /// No description provided for @notificationPermissionSettingsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open Settings. Open your device Settings, find Jan Cosmic Foundation, and allow notifications there.'**
  String get notificationPermissionSettingsUnavailable;

  /// No description provided for @notificationPermissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get notificationPermissionOpenSettings;

  /// No description provided for @notificationPermissionContinueWithout.
  ///
  /// In en, this message translates to:
  /// **'Continue without notifications'**
  String get notificationPermissionContinueWithout;

  /// No description provided for @notificationPermissionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get notificationPermissionContinue;

  /// No description provided for @notificationPermissionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notificationPermissionDone;

  /// No description provided for @notificationPermissionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get notificationPermissionRetry;

  /// No description provided for @notificationPermissionBellLabel.
  ///
  /// In en, this message translates to:
  /// **'Illustration of a notification bell'**
  String get notificationPermissionBellLabel;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Choose what this app may send you'**
  String get notificationSettingsSub;
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
