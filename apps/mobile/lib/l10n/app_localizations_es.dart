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

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get signInOptionsSub =>
      'Inicia sesión con el número de teléfono o el correo\nregistrados en la Jan Cosmic Foundation.';

  @override
  String get secureAndPrivate => 'SEGURO Y PRIVADO';

  @override
  String get continueWithPhone => 'Continuar con el teléfono';

  @override
  String get continueWithEmail => 'Continuar con el correo';

  @override
  String get noPasswordNeeded => 'No se necesita contraseña.';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get codeSentPhone =>
      'Te enviamos un código de 6 dígitos a tu teléfono.';

  @override
  String get codeSentEmail => 'Te enviamos un código de 6 dígitos a tu correo.';

  @override
  String get verificationCode => 'Código de 6 dígitos';

  @override
  String get verifySignIn => 'Verificar e iniciar sesión';

  @override
  String get invalidCode => 'Código no válido o caducado.';

  @override
  String get startOver => 'Usar otro teléfono o correo';

  @override
  String get genericError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get signInWithPhone => 'Inicia sesión con tu teléfono';

  @override
  String get signInWithEmail => 'Inicia sesión con tu correo';

  @override
  String get oneTimeCodeSub =>
      'Te enviaremos un código de verificación de un solo uso.';

  @override
  String get useEmailInstead => 'Usar el correo';

  @override
  String get usePhoneInstead => 'Usar el teléfono';

  @override
  String get phoneMatchNote =>
      'Tu número debe coincidir con tu registro de\nmiembro o estudiante de JCF.';

  @override
  String get emailMatchNote =>
      'Tu correo debe coincidir con tu registro de\nmiembro o estudiante de JCF.';

  @override
  String get enterVerificationCode => 'Introduce el código de verificación';

  @override
  String codeSentToMasked(String destination) {
    return 'Enviamos un código de 6 dígitos a $destination.';
  }

  @override
  String get verifyAndContinue => 'Verificar y continuar';

  @override
  String resendCodeIn(String time) {
    return 'Reenviar código en $time';
  }

  @override
  String get changePhoneNumber => 'Cambiar número de teléfono';

  @override
  String get changeEmailAddress => 'Cambiar correo electrónico';

  @override
  String get didntReceiveCode => '¿No recibiste el código?';

  @override
  String get resendHelpSub =>
      'Revisa tus mensajes o solicita un nuevo\ncódigo de verificación.';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get contactSupport => 'Contactar con soporte';

  @override
  String get recordNotFoundTitle => 'No encontramos\ntu registro';

  @override
  String get recordNotFoundSub =>
      'El teléfono o correo introducido no está vinculado a\nun registro aprobado de miembro o estudiante de JCF.';

  @override
  String get tryAnotherDetail => 'Probar con otro dato';

  @override
  String get approvalPendingChip => 'Aprobación pendiente';

  @override
  String get accessReviewTitle => 'Tu acceso está\nsiendo revisado';

  @override
  String get accessReviewSub =>
      'Encontramos tu contacto, pero tu acceso de miembro\no estudiante aún no ha sido aprobado.';

  @override
  String get browseWhileWaiting =>
      'Puedes seguir explorando las\nenseñanzas públicas mientras esperas.';

  @override
  String get checkAgain => 'Comprobar de nuevo';

  @override
  String get stillPending => 'Aún pendiente: vuelve a intentarlo pronto.';
}
