// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get begin => 'Comenzar';

  @override
  String get continueAsGuest => 'Continuar como invitado';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get alreadyMemberPrompt => '¿Ya eres miembro o estudiante?';

  @override
  String get welcomeHeadline => 'Un camino de libertad y consciencia';

  @override
  String get welcomeSub =>
      'Enseñanzas, práctica y servicio para\nbuscadores sinceros listos para mirar hacia dentro.';

  @override
  String get onboardTitle1 => 'Sabiduría para el camino';

  @override
  String get onboardBody1 =>
      'Mira, escucha y lee enseñanzas que\nfomentan la consciencia y una vida despierta.';

  @override
  String get onboardTitle2 => 'Ve más profundo con InnerSpace';

  @override
  String get onboardBody2 =>
      'Construye una práctica constante, sigue tu progreso\ny avanza por un camino guiado de estudio interior.';

  @override
  String get onboardTitle3 => 'Aprender, reunirse y servir';

  @override
  String get onboardBody3 =>
      'Únete a programas, conecta con los centros\ny ayuda a llevar la obra adelante.';

  @override
  String get next => 'Siguiente';

  @override
  String get skip => 'Omitir';

  @override
  String get back => 'Atrás';

  @override
  String get continueLabel => 'Continuar';

  @override
  String pageCounter(int current, int total) {
    return '$current de $total';
  }

  @override
  String get chooseLanguage => 'Elige tu idioma';

  @override
  String get changeAnytimeSettings =>
      'Puedes cambiarlo en cualquier momento en Ajustes.';

  @override
  String get searchLanguages => 'Buscar idiomas';

  @override
  String get moreLanguages => 'Más idiomas';

  @override
  String get fewerLanguages => 'Menos idiomas';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get howToContinue => '¿Cómo deseas\ncontinuar?';

  @override
  String get pathSubtitle =>
      'Explora las enseñanzas públicas como invitado, o inicia sesión\npara tu experiencia de miembro o estudiante.';

  @override
  String get memberOrStudent => 'Miembro o estudiante';

  @override
  String get memberCardBody => 'Accede a tu aprendizaje, práctica y actividad.';

  @override
  String get guest => 'Invitado';

  @override
  String get guestCardBody => 'Explora enseñanzas y programas públicos.';

  @override
  String get otpNote =>
      'Sin contraseña. Te enviaremos un código de un solo uso.';

  @override
  String get brandTagline => 'VIDA CONSCIENTE PARA UNA HUMANIDAD MEJOR';

  @override
  String get stayConnected => 'Mantente conectado';

  @override
  String get stayConnectedSub =>
      'Recibe inspiración diaria, recordatorios de práctica\ny novedades importantes de los programas.';

  @override
  String get dailyInspiration => 'Inspiración diaria';

  @override
  String get practiceReminders => 'Recordatorios de práctica';

  @override
  String get programmeUpdates => 'Novedades de programas';

  @override
  String get enableNotifications => 'Activar notificaciones';

  @override
  String get notNow => 'Ahora no';
}
