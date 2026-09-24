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

  @override
  String get memberStudentContent => 'CONTENIDO PARA MIEMBROS Y ESTUDIANTES';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get premiumTeachingSub =>
      'Esta enseñanza está disponible para miembros\ny estudiantes aprobados de JCF.';

  @override
  String get returnToPublicTeachings => 'Volver a las enseñanzas públicas';

  @override
  String get sessionExpiredTitle => 'Tu sesión ha expirado';

  @override
  String get sessionExpiredSub =>
      'Por tu seguridad, verifica de nuevo\ntu identidad para continuar.';

  @override
  String get signInAgain => 'Iniciar sesión de nuevo';

  @override
  String get signOutQuestion => '¿Cerrar sesión?';

  @override
  String get signOutWarning =>
      'Necesitarás un nuevo código de verificación\npara volver a acceder a tu cuenta de\nmiembro o estudiante.';

  @override
  String get signOutConfirm => 'Cerrar sesión';

  @override
  String get staySignedIn => 'Seguir conectado';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabLearn => 'Aprender';

  @override
  String get tabPractice => 'Práctica';

  @override
  String get tabPrograms => 'Programas';

  @override
  String get tabMore => 'Más';

  @override
  String get dailyInspirationEyebrow => 'INSPIRACIÓN DIARIA';

  @override
  String get defaultQuote =>
      '«La libertad comienza cuando la consciencia se vuelve tu forma de vivir.»';

  @override
  String get readReflection => 'Leer la reflexión';

  @override
  String get beginYourJourney => 'Comienza tu camino';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get watchATeaching => 'Ver una enseñanza';

  @override
  String get watchTeachingSub => 'Claves para un\nmañana mejor';

  @override
  String get tryAPractice => 'Probar una práctica';

  @override
  String get tryPracticeSub => 'Herramientas simples\npara el día a día';

  @override
  String get findAProgramme => 'Encontrar un programa';

  @override
  String get findProgrammeSub => 'Profundiza\na tu propio ritmo';

  @override
  String get liveUpcoming => 'En vivo y próximos';

  @override
  String get latestPublicTeachings => 'Últimas enseñanzas públicas';

  @override
  String get signInBanner =>
      'Inicia sesión en tu experiencia de miembro o estudiante';

  @override
  String get signInBannerSub =>
      'Accede a prácticas guiadas, programas, eventos en vivo y más.';

  @override
  String greetingMorning(String name) {
    return 'Buenos días, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Buenas tardes, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Buenas noches, $name';
  }

  @override
  String welcomeBackName(String name) {
    return 'Bienvenido de nuevo,\n$name';
  }

  @override
  String get memberChip => 'Miembro';

  @override
  String get studentChip => 'Estudiante';

  @override
  String get memberTagline => 'Un tú más consciente crea un mañana mejor.';

  @override
  String get studentTagline => 'Una mente más serena. Un tú más luminoso.';

  @override
  String get continueLearningEyebrow => 'CONTINUAR APRENDIENDO';

  @override
  String get resume => 'Reanudar';

  @override
  String get upcomingEyebrow => 'PRÓXIMO';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get announcementEyebrow => 'ANUNCIO';

  @override
  String get learnMore => 'Saber más';

  @override
  String get myCard => 'Mi tarjeta';

  @override
  String get myCardSub => 'Tu membresía';

  @override
  String get consultationAction => 'Consulta';

  @override
  String get consultationSub => 'Buscar orientación';

  @override
  String get giveAction => 'Donar';

  @override
  String get giveSub => 'Apoya nuestra labor';

  @override
  String get myGroups => 'Mis grupos';

  @override
  String get myGroupsSub => 'Conectar y crecer';

  @override
  String get innerspaceJourneyEyebrow => 'CAMINO INNERSPACE';

  @override
  String get continueLesson => 'Continuar la lección';

  @override
  String get todaysPractice => 'La práctica de hoy';

  @override
  String get startLabel => 'Comenzar';

  @override
  String get quickActions => 'Acciones rápidas';

  @override
  String get quickActionsSub => 'Todo lo que necesitas, al alcance de la mano.';

  @override
  String get membershipCardTitle => 'Mi tarjeta de miembro';

  @override
  String get membershipCardSub => 'Tu identidad Jan Cosmic';

  @override
  String get bookConsultation => 'Reservar consulta';

  @override
  String get bookConsultationSub => 'Conecta con nuestros guías';

  @override
  String get giveTileSub => 'Apoya un mañana mejor';

  @override
  String get myGroupsTileSub => 'Encuentra tu comunidad';

  @override
  String get guidanceRequest => 'Solicitud de guía';

  @override
  String get guidanceRequestSub => 'Pregunta. Explora. Evoluciona.';

  @override
  String get findCentre => 'Encontrar un centro';

  @override
  String get findCentreSub => 'Localiza un centro Jan Cosmic cerca de ti';

  @override
  String get myRegistrations => 'Mis inscripciones';

  @override
  String get myRegistrationsSub => 'Eventos y programas en los que participas';

  @override
  String get shopTitle => 'Tienda';

  @override
  String get shopSub => 'Elecciones conscientes para un mundo mejor';

  @override
  String get downloadsTitle => 'Descargas';

  @override
  String get downloadsSub => 'Recursos para tu camino';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSub => 'Personaliza tu experiencia';

  @override
  String get comingSoonTitle => 'Próximamente';

  @override
  String get comingSoonBody =>
      'Esta parte de la app está en camino.\nVuelve pronto.';

  @override
  String get exploreRelated => 'Explorar la enseñanza relacionada';

  @override
  String get shareLabel => 'Compartir';

  @override
  String get shareInspirationTitle => 'Compartir inspiración';

  @override
  String get shareInspirationSub =>
      'Crea y comparte un mensaje que eleva.\nDifunde consciencia. Inspira un mañana mejor.';

  @override
  String get chooseStyle => 'Elige un estilo';

  @override
  String get differentLooks => 'Distintos estilos. El mismo mensaje.';

  @override
  String get styleLight => 'Claro';

  @override
  String get styleCosmic => 'Cósmico';

  @override
  String get styleMinimal => 'Minimalista';

  @override
  String get continueLearningTitle => 'Continuar aprendiendo';

  @override
  String activeSeriesCount(int count) {
    return '$count series activas';
  }

  @override
  String lessonsCompletedCount(int count) {
    return '$count lecciones completadas';
  }

  @override
  String get resumeLesson => 'Reanudar lección';

  @override
  String lessonXofY(int x, int y) {
    return 'Lección $x de $y';
  }

  @override
  String get recentlyViewed => 'Visto recientemente';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterVideo => 'Vídeo';

  @override
  String get filterAudio => 'Audio';

  @override
  String get viewedToday => 'Visto hoy';

  @override
  String get viewedYesterday => 'Visto ayer';

  @override
  String viewedDaysAgo(int days) {
    return 'Visto hace $days días';
  }

  @override
  String get markComplete => 'Marcar como completada';

  @override
  String get completedLabel => 'Completada';

  @override
  String get nothingInProgress =>
      'Nada en curso todavía.\nAbre una lección para comenzar tu camino.';

  @override
  String get continuePracticeTitle => 'Continuar la práctica';

  @override
  String get practiceTagline => 'Un tú más consciente, un mundo más luminoso.';

  @override
  String dayStreak(int days) {
    return 'Racha de $days días';
  }

  @override
  String get keepGoing => '¡Sigue así!';

  @override
  String practicesCount(int count) {
    return '$count prácticas';
  }

  @override
  String get thisWeekShort => 'esta semana';

  @override
  String get todaysPracticeEyebrow => 'PRÁCTICA DE HOY';

  @override
  String get guidedAudio => 'Audio guiado';

  @override
  String minutesShort(int min) {
    return '$min min';
  }

  @override
  String get thisWeekTitle => 'Esta semana';

  @override
  String get yourProgress => 'Tu progreso';

  @override
  String get weeklyGoal => 'Meta semanal';

  @override
  String nOfGoalPractices(int done, int goal) {
    return '$done de $goal prácticas';
  }

  @override
  String get yourPractices => 'Tus prácticas';

  @override
  String get viewPracticeHistory => 'Ver historial de prácticas';

  @override
  String get playAudio => 'Reproducir audio';

  @override
  String get markDone => 'Marcar como hecha';

  @override
  String get doneToday => 'Hecha por hoy';

  @override
  String get upcomingActivitiesTitle => 'Próximas actividades';

  @override
  String get upcomingActivitiesTagline => 'Únete, aprende y crece en comunidad';

  @override
  String get filterProgrammes => 'Programas';

  @override
  String get filterLive => 'En vivo';

  @override
  String get filterPractice => 'Práctica';

  @override
  String get todaySection => 'Hoy';

  @override
  String get tomorrowSection => 'Mañana';

  @override
  String get laterSection => 'Más adelante';

  @override
  String get liveSoonBadge => 'Pronto en vivo';

  @override
  String get onlineLabel => 'En línea';

  @override
  String get audiencePublic => 'Todos son bienvenidos';

  @override
  String get audienceMembers => 'Miembros y estudiantes';

  @override
  String get audienceStudents => 'Solo estudiantes';

  @override
  String get reminderOnSnack => 'Recordatorio activado: te avisaremos.';

  @override
  String get reminderOffSnack => 'Recordatorio eliminado.';

  @override
  String get signInForReminders => 'Inicia sesión para crear recordatorios.';

  @override
  String get noUpcoming => 'No hay nada programado todavía. Vuelve pronto.';

  @override
  String get announcementsTitle => 'Anuncios';

  @override
  String get announcementsTagline =>
      'Mantente al día con lo último de la comunidad JCF.';

  @override
  String get chipGeneral => 'General';

  @override
  String get chipMembers => 'Miembros';

  @override
  String get chipStudents => 'Estudiantes';

  @override
  String get pinnedAnnouncement => 'Anuncio fijado';

  @override
  String get noAnnouncements => 'No hay anuncios todavía. Vuelve pronto.';

  @override
  String get headerTagline => 'Conciencia para un mañana mejor';

  @override
  String get searchTitle => 'Buscar';

  @override
  String get searchJcfTitle => 'Buscar en JCF';

  @override
  String get searchHint => 'Enseñanzas, programas y más';

  @override
  String get recentSearches => 'Búsquedas recientes';

  @override
  String get clearLabel => 'Borrar';

  @override
  String get browseByCategory => 'Explorar por categoría';

  @override
  String get categoryTeachings => 'Enseñanzas';

  @override
  String get categoryPractices => 'Prácticas';

  @override
  String get categoryProgrammes => 'Programas';

  @override
  String get categoryEvents => 'Eventos';

  @override
  String get categoryCentres => 'Centros';

  @override
  String get popularSearches => 'Búsquedas populares';

  @override
  String resultsFor(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0 para “$query”';
  }

  @override
  String noResults(String query) {
    return 'Sin resultados para “$query”. Prueba con otra palabra.';
  }

  @override
  String get allLevelsChip => 'Todos los niveles';

  @override
  String get kindVideo => 'Vídeo';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindPractice => 'Práctica';

  @override
  String get kindProgramme => 'Programa';

  @override
  String get kindEvent => 'Evento';

  @override
  String get kindCentre => 'Centro';

  @override
  String get kindAnnouncement => 'Anuncio';

  @override
  String get alreadyPartOfJcf => '¿Ya formas parte de JCF?';

  @override
  String get statusLive => 'En vivo';

  @override
  String get statusStartingSoon => 'Comienza pronto';

  @override
  String get statusUpcoming => 'Próximamente';

  @override
  String get joinLive => 'Unirse en vivo';
}
