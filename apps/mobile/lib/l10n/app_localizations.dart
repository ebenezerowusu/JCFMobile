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
