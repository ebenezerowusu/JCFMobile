// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get begin => 'Começar';

  @override
  String get continueAsGuest => 'Continuar como convidado';

  @override
  String get signIn => 'Entrar';

  @override
  String get alreadyMemberPrompt => 'Já é membro ou estudante?';

  @override
  String get welcomeHeadline => 'Um caminho de liberdade e consciência';

  @override
  String get welcomeSub =>
      'Ensinamentos, prática e serviço para\nbuscadores sinceros prontos a olhar para dentro.';

  @override
  String get onboardTitle1 => 'Sabedoria para a jornada';

  @override
  String get onboardBody1 =>
      'Veja, ouça e leia ensinamentos que\napoiam a consciência e o viver desperto.';

  @override
  String get onboardTitle2 => 'Vá mais fundo com o InnerSpace';

  @override
  String get onboardBody2 =>
      'Construa uma prática constante, acompanhe o seu progresso\ne avance por um caminho guiado de estudo interior.';

  @override
  String get onboardTitle3 => 'Aprender, reunir e servir';

  @override
  String get onboardBody3 =>
      'Participe de programas, conecte-se aos centros\ne ajude a levar a obra adiante.';

  @override
  String get next => 'Próximo';

  @override
  String get skip => 'Pular';

  @override
  String get back => 'Voltar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String pageCounter(int current, int total) {
    return '$current de $total';
  }

  @override
  String get chooseLanguage => 'Escolha o seu idioma';

  @override
  String get changeAnytimeSettings =>
      'Você pode mudar a qualquer momento em Configurações.';

  @override
  String get searchLanguages => 'Pesquisar idiomas';

  @override
  String get moreLanguages => 'Mais idiomas';

  @override
  String get fewerLanguages => 'Menos idiomas';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get howToContinue => 'Como você deseja\ncontinuar?';

  @override
  String get pathSubtitle =>
      'Explore os ensinamentos públicos como convidado, ou entre\npara a sua experiência de membro ou estudante.';

  @override
  String get memberOrStudent => 'Membro ou estudante';

  @override
  String get memberCardBody => 'Acesse o seu aprendizado, prática e atividade.';

  @override
  String get guest => 'Convidado';

  @override
  String get guestCardBody => 'Navegue por ensinamentos e programas públicos.';

  @override
  String get otpNote => 'Sem senha. Enviaremos um código de uso único.';

  @override
  String get brandTagline => 'VIDA CONSCIENTE PARA UMA HUMANIDADE MELHOR';

  @override
  String get stayConnected => 'Fique conectado';

  @override
  String get stayConnectedSub =>
      'Receba inspiração diária, lembretes de prática\ne novidades importantes dos programas.';

  @override
  String get dailyInspiration => 'Inspiração diária';

  @override
  String get practiceReminders => 'Lembretes de prática';

  @override
  String get programmeUpdates => 'Novidades dos programas';

  @override
  String get enableNotifications => 'Ativar notificações';

  @override
  String get notNow => 'Agora não';
}
