// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get begin => 'Commencer';

  @override
  String get continueAsGuest => 'Continuer en invité';

  @override
  String get signIn => 'Se connecter';

  @override
  String get alreadyMemberPrompt => 'Déjà membre ou étudiant ?';

  @override
  String get welcomeHeadline => 'Un chemin de liberté et de conscience';

  @override
  String get welcomeSub =>
      'Enseignements, pratique et service pour\nles chercheurs sincères prêts à se tourner vers l\'intérieur.';

  @override
  String get onboardTitle1 => 'La sagesse pour le voyage';

  @override
  String get onboardBody1 =>
      'Regardez, écoutez et lisez des enseignements qui\nnourrissent la conscience et une vie éveillée.';

  @override
  String get onboardTitle2 => 'Allez plus loin avec InnerSpace';

  @override
  String get onboardBody2 =>
      'Construisez une pratique régulière, suivez vos progrès\net avancez sur un chemin guidé d\'étude intérieure.';

  @override
  String get onboardTitle3 => 'Apprendre, se réunir et servir';

  @override
  String get onboardBody3 =>
      'Rejoignez des programmes, connectez-vous aux centres\net contribuez à faire avancer l\'œuvre.';

  @override
  String get next => 'Suivant';

  @override
  String get skip => 'Passer';

  @override
  String get back => 'Retour';

  @override
  String get continueLabel => 'Continuer';

  @override
  String pageCounter(int current, int total) {
    return '$current sur $total';
  }

  @override
  String get chooseLanguage => 'Choisissez votre langue';

  @override
  String get changeAnytimeSettings =>
      'Vous pourrez la changer à tout moment dans les Réglages.';

  @override
  String get searchLanguages => 'Rechercher une langue';

  @override
  String get moreLanguages => 'Plus de langues';

  @override
  String get fewerLanguages => 'Moins de langues';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get howToContinue => 'Comment souhaitez-vous\ncontinuer ?';

  @override
  String get pathSubtitle =>
      'Explorez les enseignements publics en invité, ou connectez-vous\npour votre espace membre ou étudiant.';

  @override
  String get memberOrStudent => 'Membre ou étudiant';

  @override
  String get memberCardBody =>
      'Accédez à votre apprentissage, votre pratique et votre activité.';

  @override
  String get guest => 'Invité';

  @override
  String get guestCardBody =>
      'Parcourez les enseignements et programmes publics.';

  @override
  String get otpNote =>
      'Pas de mot de passe. Nous vous enverrons un code unique.';

  @override
  String get brandTagline => 'UNE VIE CONSCIENTE POUR UNE HUMANITÉ MEILLEURE';

  @override
  String get stayConnected => 'Restez connecté';

  @override
  String get stayConnectedSub =>
      'Recevez l\'inspiration quotidienne, des rappels de pratique\net les actualités importantes des programmes.';

  @override
  String get dailyInspiration => 'Inspiration quotidienne';

  @override
  String get practiceReminders => 'Rappels de pratique';

  @override
  String get programmeUpdates => 'Actualités des programmes';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get signInOptionsSub =>
      'Connectez-vous avec le numéro de téléphone ou\nl\'adresse e-mail enregistrés auprès de la Jan Cosmic Foundation.';

  @override
  String get secureAndPrivate => 'SÉCURISÉ ET PRIVÉ';

  @override
  String get continueWithPhone => 'Continuer avec le téléphone';

  @override
  String get continueWithEmail => 'Continuer avec l\'e-mail';

  @override
  String get noPasswordNeeded => 'Pas de mot de passe requis.';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get codeSentPhone =>
      'Nous avons envoyé un code à 6 chiffres sur votre téléphone.';

  @override
  String get codeSentEmail =>
      'Nous avons envoyé un code à 6 chiffres à votre adresse e-mail.';

  @override
  String get verificationCode => 'Code à 6 chiffres';

  @override
  String get verifySignIn => 'Vérifier et se connecter';

  @override
  String get invalidCode => 'Code invalide ou expiré.';

  @override
  String get startOver => 'Utiliser un autre téléphone ou e-mail';

  @override
  String get genericError => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get signInWithPhone => 'Connectez-vous avec votre téléphone';

  @override
  String get signInWithEmail => 'Connectez-vous avec votre e-mail';

  @override
  String get oneTimeCodeSub =>
      'Nous vous enverrons un code de vérification à usage unique.';

  @override
  String get useEmailInstead => 'Utiliser l\'e-mail';

  @override
  String get usePhoneInstead => 'Utiliser le téléphone';

  @override
  String get phoneMatchNote =>
      'Votre numéro doit correspondre à votre dossier\nde membre ou d\'étudiant JCF.';

  @override
  String get emailMatchNote =>
      'Votre e-mail doit correspondre à votre dossier\nde membre ou d\'étudiant JCF.';

  @override
  String get enterVerificationCode => 'Saisissez le code de vérification';

  @override
  String codeSentToMasked(String destination) {
    return 'Nous avons envoyé un code à 6 chiffres à $destination.';
  }

  @override
  String get verifyAndContinue => 'Vérifier et continuer';

  @override
  String resendCodeIn(String time) {
    return 'Renvoyer le code dans $time';
  }

  @override
  String get changePhoneNumber => 'Changer de numéro de téléphone';

  @override
  String get changeEmailAddress => 'Changer d\'adresse e-mail';

  @override
  String get didntReceiveCode => 'Vous n\'avez pas reçu le code ?';

  @override
  String get resendHelpSub =>
      'Vérifiez vos messages ou demandez un\nnouveau code de vérification.';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get contactSupport => 'Contacter l\'assistance';

  @override
  String get recordNotFoundTitle => 'Nous n\'avons pas trouvé\nvotre dossier';

  @override
  String get recordNotFoundSub =>
      'Le numéro de téléphone ou l\'e-mail saisi n\'est lié à\naucun dossier approuvé de membre ou d\'étudiant JCF.';

  @override
  String get tryAnotherDetail => 'Essayer une autre donnée';

  @override
  String get approvalPendingChip => 'Approbation en attente';

  @override
  String get accessReviewTitle => 'Votre accès est\nen cours d\'examen';

  @override
  String get accessReviewSub =>
      'Votre contact a été trouvé, mais votre accès membre\nou étudiant n\'a pas encore été approuvé.';

  @override
  String get browseWhileWaiting =>
      'Vous pouvez continuer à parcourir les\nenseignements publics en attendant.';

  @override
  String get checkAgain => 'Vérifier à nouveau';

  @override
  String get stillPending => 'Toujours en attente — revenez bientôt.';

  @override
  String get memberStudentContent => 'CONTENU MEMBRES ET ÉTUDIANTS';

  @override
  String get signInToContinue => 'Connectez-vous pour continuer';

  @override
  String get premiumTeachingSub =>
      'Cet enseignement est réservé aux membres\net étudiants JCF approuvés.';

  @override
  String get returnToPublicTeachings => 'Retour aux enseignements publics';

  @override
  String get sessionExpiredTitle => 'Votre session a expiré';

  @override
  String get sessionExpiredSub =>
      'Pour votre sécurité, veuillez vérifier à\nnouveau votre identité pour continuer.';

  @override
  String get signInAgain => 'Se reconnecter';

  @override
  String get signOutQuestion => 'Se déconnecter ?';

  @override
  String get signOutWarning =>
      'Vous aurez besoin d\'un nouveau code de\nvérification pour accéder à nouveau à votre\ncompte membre ou étudiant.';

  @override
  String get signOutConfirm => 'Se déconnecter';

  @override
  String get staySignedIn => 'Rester connecté';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabLearn => 'Apprendre';

  @override
  String get tabPractice => 'Pratique';

  @override
  String get tabPrograms => 'Programmes';

  @override
  String get tabMore => 'Plus';

  @override
  String get dailyInspirationEyebrow => 'INSPIRATION DU JOUR';

  @override
  String get defaultQuote =>
      '« La liberté commence quand la conscience devient votre façon de vivre. »';

  @override
  String get readReflection => 'Lire la réflexion';

  @override
  String get beginYourJourney => 'Commencez votre voyage';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get watchATeaching => 'Regarder un enseignement';

  @override
  String get watchTeachingSub => 'Des éclairages pour un\nlendemain meilleur';

  @override
  String get tryAPractice => 'Essayer une pratique';

  @override
  String get tryPracticeSub => 'Des outils simples\npour la vie quotidienne';

  @override
  String get findAProgramme => 'Trouver un programme';

  @override
  String get findProgrammeSub => 'Aller plus loin\nà votre rythme';

  @override
  String get liveUpcoming => 'En direct et à venir';

  @override
  String get latestPublicTeachings => 'Derniers enseignements publics';

  @override
  String get signInBanner => 'Connectez-vous à votre espace membre ou étudiant';

  @override
  String get signInBannerSub =>
      'Accédez aux pratiques guidées, programmes, événements en direct et plus.';

  @override
  String greetingMorning(String name) {
    return 'Bonjour, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Bon après-midi, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Bonsoir, $name';
  }

  @override
  String welcomeBackName(String name) {
    return 'Bon retour,\n$name';
  }

  @override
  String get memberChip => 'Membre';

  @override
  String get studentChip => 'Étudiant';

  @override
  String get memberTagline =>
      'Une conscience plus vive crée un lendemain meilleur.';

  @override
  String get studentTagline => 'Un esprit plus calme. Un vous plus lumineux.';

  @override
  String get continueLearningEyebrow => 'REPRENDRE L\'APPRENTISSAGE';

  @override
  String get resume => 'Reprendre';

  @override
  String get upcomingEyebrow => 'À VENIR';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get announcementEyebrow => 'ANNONCE';

  @override
  String get learnMore => 'En savoir plus';

  @override
  String get myCard => 'Ma carte';

  @override
  String get myCardSub => 'Votre adhésion';

  @override
  String get consultationAction => 'Consultation';

  @override
  String get consultationSub => 'Demander conseil';

  @override
  String get giveAction => 'Donner';

  @override
  String get giveSub => 'Soutenir notre œuvre';

  @override
  String get myGroups => 'Mes groupes';

  @override
  String get myGroupsSub => 'Se connecter et grandir';

  @override
  String get innerspaceJourneyEyebrow => 'PARCOURS INNERSPACE';

  @override
  String get continueLesson => 'Continuer la leçon';

  @override
  String get todaysPractice => 'La pratique du jour';

  @override
  String get startLabel => 'Commencer';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get quickActionsSub => 'Tout ce qu\'il vous faut, à portée de main.';

  @override
  String get membershipCardTitle => 'Ma carte de membre';

  @override
  String get membershipCardSub => 'Votre identité Jan Cosmic';

  @override
  String get bookConsultation => 'Réserver une consultation';

  @override
  String get bookConsultationSub => 'Échanger avec nos guides';

  @override
  String get giveTileSub => 'Soutenir un lendemain meilleur';

  @override
  String get myGroupsTileSub => 'Trouver votre communauté';

  @override
  String get guidanceRequest => 'Demande de guidance';

  @override
  String get guidanceRequestSub => 'Demander. Explorer. Évoluer.';

  @override
  String get findCentre => 'Trouver un centre';

  @override
  String get findCentreSub =>
      'Localisez un centre Jan Cosmic près de chez vous';

  @override
  String get myRegistrations => 'Mes inscriptions';

  @override
  String get myRegistrationsSub =>
      'Les événements et programmes auxquels vous participez';

  @override
  String get shopTitle => 'Boutique';

  @override
  String get shopSub => 'Des choix conscients pour un monde meilleur';

  @override
  String get downloadsTitle => 'Téléchargements';

  @override
  String get downloadsSub => 'Des ressources pour votre chemin';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSub => 'Personnalisez votre expérience';

  @override
  String get comingSoonTitle => 'Bientôt disponible';

  @override
  String get comingSoonBody =>
      'Cette partie de l\'application arrive.\nRevenez bientôt.';

  @override
  String get exploreRelated => 'Explorer l\'enseignement lié';

  @override
  String get shareLabel => 'Partager';

  @override
  String get shareInspirationTitle => 'Partager l\'inspiration';

  @override
  String get shareInspirationSub =>
      'Créez et partagez un message qui élève.\nDiffusez la conscience. Inspirez un lendemain meilleur.';

  @override
  String get chooseStyle => 'Choisissez un style';

  @override
  String get differentLooks => 'Des styles différents. Le même message.';

  @override
  String get styleLight => 'Clair';

  @override
  String get styleCosmic => 'Cosmique';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get continueLearningTitle => 'Reprendre l\'apprentissage';

  @override
  String activeSeriesCount(int count) {
    return '$count séries en cours';
  }

  @override
  String lessonsCompletedCount(int count) {
    return '$count leçons terminées';
  }

  @override
  String get resumeLesson => 'Reprendre la leçon';

  @override
  String lessonXofY(int x, int y) {
    return 'Leçon $x sur $y';
  }

  @override
  String get recentlyViewed => 'Vu récemment';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterVideo => 'Vidéo';

  @override
  String get filterAudio => 'Audio';

  @override
  String get viewedToday => 'Vu aujourd\'hui';

  @override
  String get viewedYesterday => 'Vu hier';

  @override
  String viewedDaysAgo(int days) {
    return 'Vu il y a $days jours';
  }

  @override
  String get markComplete => 'Marquer comme terminé';

  @override
  String get completedLabel => 'Terminé';

  @override
  String get nothingInProgress =>
      'Rien en cours pour l\'instant.\nOuvrez une leçon pour commencer votre chemin.';

  @override
  String get continuePracticeTitle => 'Poursuivre la pratique';

  @override
  String get practiceTagline =>
      'Un vous plus conscient, un monde plus lumineux.';

  @override
  String dayStreak(int days) {
    return 'Série de $days jours';
  }

  @override
  String get keepGoing => 'Continuez !';

  @override
  String practicesCount(int count) {
    return '$count pratiques';
  }

  @override
  String get thisWeekShort => 'cette semaine';

  @override
  String get todaysPracticeEyebrow => 'PRATIQUE DU JOUR';

  @override
  String get guidedAudio => 'Audio guidé';

  @override
  String minutesShort(int min) {
    return '$min min';
  }

  @override
  String get thisWeekTitle => 'Cette semaine';

  @override
  String get yourProgress => 'Vos progrès';

  @override
  String get weeklyGoal => 'Objectif hebdo';

  @override
  String nOfGoalPractices(int done, int goal) {
    return '$done sur $goal pratiques';
  }

  @override
  String get yourPractices => 'Vos pratiques';

  @override
  String get viewPracticeHistory => 'Voir l\'historique des pratiques';

  @override
  String get playAudio => 'Écouter l\'audio';

  @override
  String get markDone => 'Marquer comme faite';

  @override
  String get doneToday => 'Fait pour aujourd\'hui';
}
