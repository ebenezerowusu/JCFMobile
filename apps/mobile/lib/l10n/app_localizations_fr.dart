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
}
