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

  @override
  String get welcomeBackGeneric => 'Bienvenido de nuevo';

  @override
  String get continueYourJourney => 'Continúa tu camino';

  @override
  String get viewActivity => 'Ver actividad';

  @override
  String get continueLearningCta => 'Seguir aprendiendo';

  @override
  String get continuePracticeCta => 'Seguir practicando';

  @override
  String get forMembers => 'Para miembros';

  @override
  String get memberExclusive => 'EXCLUSIVO PARA MIEMBROS';

  @override
  String get watchNow => 'Ver ahora';

  @override
  String get listenNow => 'Escuchar';

  @override
  String get readNow => 'Leer';

  @override
  String get startCourse => 'Empezar curso';

  @override
  String get exploreSeries => 'Explorar serie';

  @override
  String get communitySection => 'Comunidad';

  @override
  String get readUpdate => 'Leer novedad';

  @override
  String get quickActionsTitle => 'Acciones rápidas';

  @override
  String get myLibrary => 'Mi biblioteca';

  @override
  String get myPrograms => 'Mis programas';

  @override
  String get savedLabel => 'Guardados';

  @override
  String get downloadsLabel => 'Descargas';

  @override
  String lessonProgress(int done, int total) {
    return '$done de $total lecciones';
  }

  @override
  String remainingTime(int minutes) {
    return '$minutes min restantes';
  }

  @override
  String get watchReplay => 'Ver repetición';

  @override
  String get noUpcomingEvents => 'No hay eventos próximos';

  @override
  String get offlineShowingSaved => 'Sin conexión: contenido guardado';

  @override
  String get retryLabel => 'Reintentar';

  @override
  String get sectionUnavailable => 'Esta sección no se pudo cargar.';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get studentChipLabel => 'Estudiante JCF';

  @override
  String get myProgramEyebrow => 'MI PROGRAMA';

  @override
  String get continueProgram => 'Continuar programa';

  @override
  String get viewAllPrograms => 'Ver todos los programas';

  @override
  String get todaysLearning => 'Aprendizaje de hoy';

  @override
  String get nextLiveClass => 'Próxima clase en vivo';

  @override
  String get viewSchedule => 'Ver horario';

  @override
  String get yourProgressTitle => 'Tu progreso';

  @override
  String get mentorSupport => 'Acompañamiento';

  @override
  String get importantUpdates => 'Avisos importantes';

  @override
  String get startLesson => 'Empezar lección';

  @override
  String get nextLesson => 'Siguiente lección';

  @override
  String get reviewLesson => 'Repasar lección';

  @override
  String get beginPractice => 'Empezar práctica';

  @override
  String get reviewPractice => 'Repasar práctica';

  @override
  String get completeNow => 'Completar ahora';

  @override
  String get allCaughtUp => 'Estás al día';

  @override
  String get joinClass => 'Unirse a la clase';

  @override
  String get viewClassSummary => 'Ver resumen';

  @override
  String get viewUpdate => 'Ver actualización';

  @override
  String get statusMissed => 'Perdida';

  @override
  String get statusCancelled => 'Cancelada';

  @override
  String get statusReplay => 'Repetición';

  @override
  String get statusNotStarted => 'Sin empezar';

  @override
  String get statusInProgress => 'En curso';

  @override
  String get statusCompleted => 'Completada';

  @override
  String get statusDueSoon => 'Vence pronto';

  @override
  String get statusOverdue => 'Vencida';

  @override
  String get statusExcused => 'Excusada';

  @override
  String get priorityUrgent => 'Urgente';

  @override
  String get priorityImportant => 'Importante';

  @override
  String get messageMentor => 'Escribir al mentor';

  @override
  String get viewMentor => 'Ver mentor';

  @override
  String get noMentorAssigned =>
      'Aún no tienes mentor asignado; el equipo del programa puede ayudarte.';

  @override
  String get viewProgress => 'Ver progreso';

  @override
  String get milestoneLocked => 'Bloqueado';

  @override
  String get milestoneAchieved => 'Logrado';

  @override
  String get myCourses => 'Mis cursos';

  @override
  String get scheduleLabel => 'Horario';

  @override
  String get assignmentsLabel => 'Tareas';

  @override
  String lessonsCompleted(int done, int total) {
    return '$done de $total lecciones';
  }

  @override
  String practicesCompleted(int done, int total) {
    return '$done de $total prácticas';
  }

  @override
  String programProgressSemantics(int percent) {
    return 'Progreso del programa, $percent por ciento.';
  }

  @override
  String dueLabel(String date) {
    return 'Vence el $date';
  }

  @override
  String get accessExpiredTitle => 'Tu acceso ha caducado';

  @override
  String get programPausedTitle => 'Este programa está en pausa';

  @override
  String get noProgramEnrolled => 'Todavía no estás inscrito en un programa.';

  @override
  String get pauseAndReflect => 'Pausa y reflexiona';

  @override
  String get markAsReflected => 'Marcar como reflexionado';

  @override
  String get reflectedLabel => 'Reflexionado';

  @override
  String get undoReflected => 'Deshacer';

  @override
  String get saveForLater => 'Guardar';

  @override
  String get savedLabel2 => 'Guardado';

  @override
  String get continueReflecting => 'Sigue reflexionando';

  @override
  String get shareAsImage => 'Compartir como imagen';

  @override
  String get shareLink => 'Compartir enlace';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get linkCopied => 'Enlace copiado';

  @override
  String get previewCard => 'Vista previa';

  @override
  String get previousInspiration => 'Anterior';

  @override
  String get nextInspiration => 'Siguiente';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String readingTime(int minutes) {
    return '$minutes min de lectura';
  }

  @override
  String get inspirationUnavailable =>
      'Esta inspiración ya no está disponible.';

  @override
  String get exploreLatest => 'Ver las últimas inspiraciones';

  @override
  String get signInToSave => 'Inicia sesión para guardar esta inspiración.';

  @override
  String get signInToReflect => 'Inicia sesión para registrar tu reflexión.';

  @override
  String get textSize => 'Tamaño del texto';

  @override
  String get openInBrowser => 'Abrir en el navegador';

  @override
  String get listenToReflection => 'Escuchar esta reflexión';

  @override
  String get createShareCard => 'Crear tarjeta';

  @override
  String get resetLabel => 'Restablecer';

  @override
  String get formatSquare => 'Cuadrado';

  @override
  String get formatStory => 'Historia';

  @override
  String get chooseAStyle => 'Elige un estilo';

  @override
  String get textAlignment => 'Alineación del texto';

  @override
  String get alignStart => 'Inicio';

  @override
  String get alignCenter => 'Centro';

  @override
  String get alignEnd => 'Final';

  @override
  String get textColor => 'Color del texto';

  @override
  String get textLight => 'Claro';

  @override
  String get textDark => 'Oscuro';

  @override
  String get sizeSmall => 'Pequeño';

  @override
  String get sizeMedium => 'Mediano';

  @override
  String get sizeLarge => 'Grande';

  @override
  String get showLogo => 'Mostrar logo';

  @override
  String get showSource => 'Mostrar fuente';

  @override
  String get showWebsite => 'Mostrar sitio web';

  @override
  String get saveImage => 'Guardar imagen';

  @override
  String get imageSaved => 'Imagen guardada en tu galería';

  @override
  String get unableToGenerate => 'No se pudo generar la imagen.';

  @override
  String get unableToSave => 'No se pudo guardar la imagen.';

  @override
  String get permissionDenied =>
      'Permiso de fotos denegado. Actívalo en Ajustes.';

  @override
  String get sharingNotAllowed => 'Esta inspiración no se puede compartir.';

  @override
  String get templateCosmic => 'Cósmico';

  @override
  String get templateDawn => 'Amanecer';

  @override
  String get templateStillness => 'Quietud';

  @override
  String get templateLight => 'Claridad';

  @override
  String shareCardPreviewLabel(String style, String format, String alignment) {
    return 'Vista previa. Estilo $style, formato $format, texto $alignment.';
  }

  @override
  String get liveNow => 'En vivo';

  @override
  String get liveEvent => 'Evento en vivo';

  @override
  String get replayTitle => 'Repetición';

  @override
  String get statusScheduled => 'Programado';

  @override
  String get statusEnded => 'Finalizado';

  @override
  String get goLive => 'Ir al directo';

  @override
  String get reconnecting => 'Reconectando…';

  @override
  String get chatTab => 'Chat';

  @override
  String get aboutTab => 'Información';

  @override
  String get joinTheConversation => 'Únete a la conversación';

  @override
  String get signInToParticipate => 'Inicia sesión para participar';

  @override
  String get chatReadOnly => 'Solo lectura';

  @override
  String get chatClosed => 'Chat cerrado';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get followLabel => 'Seguir';

  @override
  String get remindMe => 'Recordarme';

  @override
  String get addToCalendar => 'Añadir al calendario';

  @override
  String get replayProcessing => 'Repetición en proceso';

  @override
  String get streamWillBeginHere => 'La transmisión comenzará aquí';

  @override
  String get streamUnavailable => 'Esta transmisión no está disponible ahora.';

  @override
  String get eventCancelled => 'Este evento fue cancelado.';

  @override
  String get eventRescheduled => 'Este evento fue reprogramado.';

  @override
  String get signInToWatch => 'Inicia sesión para ver esta sesión.';

  @override
  String get membersOnlyEvent => 'Esta sesión es para miembros y estudiantes.';

  @override
  String get studentsOnlyEvent => 'Esta sesión es para estudiantes inscritos.';

  @override
  String viewerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viendo',
      one: '1 viendo',
    );
    return '$_temp0';
  }

  @override
  String get reportMessage => 'Reportar mensaje';

  @override
  String get blockUser => 'Bloquear';

  @override
  String get messageReported => 'Reportado a los moderadores.';

  @override
  String get userBlocked => 'No verás sus mensajes.';

  @override
  String slowModeOn(int seconds) {
    return 'Modo lento activo. Inténtalo en $seconds s.';
  }

  @override
  String get reactAppreciate => 'Gratitud';

  @override
  String get reactThanks => 'Gracias';

  @override
  String get reactInsight => 'Revelador';

  @override
  String get reactLabel => 'Reaccionar';

  @override
  String get eventLanguage => 'Idioma';

  @override
  String get eventSchedule => 'Horario';

  @override
  String get eventFacilitator => 'Facilitador';

  @override
  String get captionsLabel => 'Subtítulos';

  @override
  String startsIn(String time) {
    return 'Comienza en $time';
  }

  @override
  String get playLabel => 'Reproducir';

  @override
  String get pauseLabel => 'Pausa';

  @override
  String get readMore => 'Leer más';

  @override
  String get readLess => 'Leer menos';

  @override
  String get activitiesListView => 'Vista de lista';

  @override
  String get activitiesCalendarView => 'Vista de calendario';

  @override
  String get activitiesSearchHint => 'Buscar actividades';

  @override
  String get activitiesFilterButton => 'Filtros';

  @override
  String get activitiesFiltersTitle => 'Filtrar actividades';

  @override
  String get activitiesFilterTypeGroup => 'Tipo de actividad';

  @override
  String get activitiesFilterLanguageGroup => 'Idioma';

  @override
  String get activitiesFilterFeeGroup => 'Coste';

  @override
  String get activitiesFilterAccessGroup => 'Acceso';

  @override
  String get activitiesFilterFeeAny => 'Cualquiera';

  @override
  String get activitiesFilterFeeFree => 'Gratis';

  @override
  String get activitiesFilterFeePaid => 'De pago';

  @override
  String get activitiesFilterOpenToMe => 'Solo a lo que puedo asistir';

  @override
  String get activitiesFilterApply => 'Ver resultados';

  @override
  String get activitiesFilterClearAll => 'Borrar todo';

  @override
  String get activitiesChipAll => 'Todo';

  @override
  String get activitiesChipLive => 'En directo';

  @override
  String get activitiesChipOnline => 'En línea';

  @override
  String get activitiesChipInPerson => 'Presencial';

  @override
  String get activitiesFeaturedEyebrow => 'Destacado';

  @override
  String get activitiesToday => 'Hoy';

  @override
  String get activitiesTomorrow => 'Mañana';

  @override
  String get activitiesThisWeek => 'Esta semana';

  @override
  String get activitiesAllDay => 'Todo el día';

  @override
  String get activitiesFormatOnline => 'En línea';

  @override
  String get activitiesFormatInPerson => 'Presencial';

  @override
  String get activitiesFormatHybrid => 'Presencial y en línea';

  @override
  String get activitiesFree => 'Gratis';

  @override
  String get activitiesRegister => 'Inscribirse';

  @override
  String get activitiesRegistered => 'Estás inscrito';

  @override
  String get activitiesJoinWaitlist => 'Unirse a la lista de espera';

  @override
  String get activitiesWaitlisted => 'Estás en la lista de espera';

  @override
  String get activitiesRegistrationFull => 'Completo';

  @override
  String get activitiesRegistrationClosed => 'Inscripción cerrada';

  @override
  String activitiesRegistrationOpensOn(String date) {
    return 'Abre el $date';
  }

  @override
  String get activitiesRegisterExternally => 'Inscribirse en la web';

  @override
  String get activitiesCancelRegistration => 'Cancelar mi plaza';

  @override
  String activitiesSeatsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count plazas',
      one: 'Queda 1 plaza',
    );
    return '$_temp0';
  }

  @override
  String get activitiesCancelled => 'Cancelado';

  @override
  String get activitiesRescheduled => 'Reprogramado';

  @override
  String get activitiesMembersOnly => 'Solo miembros';

  @override
  String get activitiesStudentsOnly => 'Solo estudiantes';

  @override
  String get activitiesSignInToJoin => 'Inicia sesión para asistir';

  @override
  String get activitiesNothingScheduled => 'No hay nada programado';

  @override
  String get activitiesNothingScheduledBody =>
      'Todavía no hay actividades ese día. Prueba otra semana.';

  @override
  String get activitiesNoMatches => 'Ninguna actividad coincide';

  @override
  String get activitiesNoMatchesBody => 'Prueba otro filtro o bórralos todos.';

  @override
  String get activitiesLoadFailed => 'No pudimos cargar el programa';

  @override
  String get activitiesLoadFailedBody =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get activitiesRetry => 'Reintentar';

  @override
  String activitiesOfflineNotice(String when) {
    return 'Copia guardada del $when';
  }

  @override
  String get activitiesRegistrationFailed =>
      'No pudimos completarlo. Inténtalo de nuevo.';

  @override
  String activitiesRegistrationConfirmed(String title) {
    return 'Estás inscrito en $title';
  }

  @override
  String activitiesWaitlistConfirmed(String title) {
    return 'Estás en la lista de espera de $title';
  }

  @override
  String get activitiesPlaceReleased => 'Tu plaza ha sido liberada';

  @override
  String get activitiesSavedSnack => 'Guardado en tu lista';

  @override
  String get activitiesUnsavedSnack => 'Quitado de tu lista';

  @override
  String get activitiesPreviousWeek => 'Semana anterior';

  @override
  String get activitiesNextWeek => 'Semana siguiente';

  @override
  String get activitiesPreviousMonth => 'Mes anterior';

  @override
  String get activitiesNextMonth => 'Mes siguiente';

  @override
  String get activitiesClearDay => 'Mostrar todas las fechas';

  @override
  String activitiesFilterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filtros ($count)',
      one: 'Filtros (1)',
      zero: 'Filtros',
    );
    return '$_temp0';
  }

  @override
  String get learnHubTitle => 'Continuar aprendiendo';

  @override
  String get learnResumeLabel => 'CONTINÚA DONDE LO DEJASTE';

  @override
  String get learnResumeSection => 'Continúa donde lo dejaste';

  @override
  String get learnStartLesson => 'Empezar lección';

  @override
  String get learnContinue => 'Continuar';

  @override
  String get learnNextLesson => 'Siguiente lección';

  @override
  String get learnReviewLesson => 'Repasar lección';

  @override
  String get learnJoinLive => 'Unirse al directo';

  @override
  String get learnRetryDownload => 'Reintentar descarga';

  @override
  String get learnViewAccess => 'Ver acceso';

  @override
  String learnRemaining(int minutes) {
    return 'Quedan $minutes min';
  }

  @override
  String learnPercentComplete(int percent) {
    return '$percent % completado';
  }

  @override
  String get learnSummaryLessons => 'Lecciones completadas';

  @override
  String get learnSummaryStreak => 'Días seguidos';

  @override
  String get learnSummaryDownloads => 'Descargadas';

  @override
  String get learnSummaryCourses => 'Cursos completados';

  @override
  String get learnActiveCourses => 'Tus cursos activos';

  @override
  String get learnSeeAll => 'Ver todo';

  @override
  String get learnStartCourse => 'Empezar curso';

  @override
  String get learnReviewCourse => 'Repasar curso';

  @override
  String get learnViewCourse => 'Ver curso';

  @override
  String get learnUpNext => 'A continuación';

  @override
  String get learnRecommended => 'Recomendado para ti';

  @override
  String learnLessonCount(int modules, int lessons) {
    String _temp0 = intl.Intl.pluralLogic(
      modules,
      locale: localeName,
      other: '$modules módulos',
      one: '1 módulo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      lessons,
      locale: localeName,
      other: '$lessons lecciones',
      one: '1 lección',
    );
    String _temp2 = intl.Intl.pluralLogic(
      modules,
      locale: localeName,
      other: '$_temp0',
      zero: '$_temp1',
    );
    return '$_temp2';
  }

  @override
  String learnLessonsOnly(int lessons) {
    String _temp0 = intl.Intl.pluralLogic(
      lessons,
      locale: localeName,
      other: '$lessons lecciones',
      one: '1 lección',
    );
    return '$_temp0';
  }

  @override
  String get learnTypeVideo => 'Vídeo';

  @override
  String get learnTypeAudio => 'Audio';

  @override
  String get learnTypeWritten => 'Escrito';

  @override
  String get learnTypeReflection => 'Reflexión';

  @override
  String get learnTypePractice => 'Práctica';

  @override
  String get learnTypeQuiz => 'Cuestionario';

  @override
  String get learnTypeLive => 'Sesión en directo';

  @override
  String get learnTypeResource => 'Recurso';

  @override
  String get learnStatusNotStarted => 'Sin empezar';

  @override
  String get learnStatusInProgress => 'En curso';

  @override
  String get learnStatusCompleted => 'Completada';

  @override
  String get learnStatusLocked => 'Bloqueada';

  @override
  String get learnStatusExpired => 'Acceso caducado';

  @override
  String get learnStatusPaused => 'En pausa';

  @override
  String get learnDownloadDownloaded => 'Disponible sin conexión';

  @override
  String get learnDownloadDownloading => 'Descargando';

  @override
  String get learnDownloadQueued => 'En cola';

  @override
  String get learnDownloadPaused => 'Descarga en pausa';

  @override
  String get learnDownloadFailed => 'Descarga fallida';

  @override
  String get learnDownloadExpired => 'Descarga caducada';

  @override
  String get learnDownloadUpdate => 'Actualización necesaria';

  @override
  String get learnPrerequisiteTitle => 'Termina esto primero';

  @override
  String learnPrerequisiteBody(String title) {
    return 'Completa $title para desbloquear esta lección.';
  }

  @override
  String learnOpenPrerequisite(String title) {
    return 'Abrir $title';
  }

  @override
  String get learnEmptyResumeTitle => 'Nada que retomar todavía';

  @override
  String get learnEmptyResumeBody => 'Empieza un curso y te esperará aquí.';

  @override
  String get learnEmptyResumeAction => 'Empezar un curso';

  @override
  String get learnEmptyCoursesTitle => 'No tienes cursos activos';

  @override
  String get learnEmptyCoursesBody => 'Explora la biblioteca o los programas.';

  @override
  String get learnEmptyCoursesAction => 'Explorar';

  @override
  String get learnEmptyUpNextTitle => 'Estás al día';

  @override
  String get learnEmptyUpNextBody =>
      'No hay nada pendiente. Mira lo que recomendamos.';

  @override
  String get learnErrorTitle => 'No pudimos cargar tu aprendizaje';

  @override
  String get learnErrorBody => 'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get learnRetry => 'Reintentar';

  @override
  String learnOfflineNotice(String when) {
    return 'Copia guardada del $when';
  }

  @override
  String get learnFiltersTitle => 'Filtrar lecciones';

  @override
  String get learnFilterStatus => 'Progreso';

  @override
  String get learnFilterType => 'Tipo de lección';

  @override
  String get learnFilterDownloaded => 'Solo descargadas';

  @override
  String get learnFilterApply => 'Ver resultados';

  @override
  String get learnFilterClear => 'Borrar todo';

  @override
  String get learnFilterAny => 'Cualquiera';

  @override
  String learnFilterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filtros ($count)',
      zero: 'Filtros',
    );
    return '$_temp0';
  }

  @override
  String get learnMyDownloads => 'Mis descargas';

  @override
  String get learnHistory => 'Historial';

  @override
  String get learnCompletedCourses => 'Cursos completados';

  @override
  String get learnHelp => 'Ayuda';

  @override
  String learnSemanticCourse(String title, int percent, String lesson) {
    return '$title. $percent por ciento completado. Lección actual: $lesson.';
  }

  @override
  String get splashFoundationName => 'JAN COSMIC FOUNDATION';

  @override
  String get splashTagline => 'Despierta. Aprende. Transforma.';

  @override
  String get splashPreparing => 'Preparando tu experiencia…';

  @override
  String get splashStillPreparing => 'Todavía preparando…';

  @override
  String get splashStartupFailed => 'No pudimos iniciar la aplicación.';

  @override
  String get splashCheckConnection =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get splashTryAgain => 'Reintentar';

  @override
  String get splashContinueOffline => 'Continuar sin conexión';

  @override
  String get splashUpdateRequiredTitle => 'Se requiere una nueva versión';

  @override
  String get splashUpdateRequiredMessage =>
      'Actualiza para seguir usando la aplicación. Esta versión ya no es compatible.';

  @override
  String get splashUpdateApp => 'Actualizar';

  @override
  String get splashMaintenanceTitle => 'Volvemos enseguida';

  @override
  String get splashMaintenanceMessage =>
      'La aplicación no está disponible mientras hacemos una mejora.';

  @override
  String get splashGenericError => 'Algo salió mal.';

  @override
  String get splashLogoLabel => 'Logotipo de Jan Cosmic Foundation';

  @override
  String get splashLoadingLabel => 'Cargando';

  @override
  String get welcomeEyebrow => 'BIENVENIDO';

  @override
  String get welcomeTitle => 'Comienza tu viaje interior';

  @override
  String get welcomeDescription =>
      'Explora enseñanzas atemporales, prácticas guiadas y una comunidad dedicada a la vida consciente.';

  @override
  String get welcomeAccountAction => 'Iniciar sesión o crear cuenta';

  @override
  String get welcomeGuestAction => 'Continuar como invitado';

  @override
  String get welcomeAgreementPrefix => 'Al continuar, aceptas los';

  @override
  String get welcomeAgreementJoin => 'y la';

  @override
  String get welcomeTermsOfUse => 'Términos de uso';

  @override
  String get welcomePrivacyPolicy => 'Política de privacidad';

  @override
  String welcomeLanguageSelector(String language) {
    return 'Idioma: $language';
  }

  @override
  String get welcomeChooseLanguage => 'Elige un idioma';

  @override
  String get welcomeGuestFailure =>
      'No pudimos continuar como invitado. Inténtalo de nuevo.';

  @override
  String get welcomeLanguageFailure => 'No pudimos cambiar el idioma.';

  @override
  String get welcomeRetry => 'Reintentar';

  @override
  String get legalUnavailableTitle => 'Aún no publicado';

  @override
  String get legalUnavailableBody =>
      'Este documento no se ha publicado. Vuelve más tarde o contacta con la fundación.';

  @override
  String get legalLoadFailed => 'No pudimos cargar este documento.';

  @override
  String legalLastUpdated(String date) {
    return 'Actualizado el $date';
  }

  @override
  String get legalShownInEnglish =>
      'Se muestra en inglés; la traducción aún no está disponible.';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String onboardingPagePosition(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get onboardingCompletionFailed =>
      'No pudimos guardar tu progreso. Inténtalo de nuevo.';

  @override
  String get onboardingTeachingsEyebrow => 'ENSEÑANZAS';

  @override
  String get onboardingTeachingsTitle => 'Descubre enseñanzas atemporales';

  @override
  String get onboardingTeachingsDescription =>
      'Explora la sabiduría con enseñanzas en vídeo, audio y texto, pensadas para la vida cotidiana.';

  @override
  String get onboardingInnerSpaceEyebrow => 'INNERSPACE';

  @override
  String get onboardingInnerSpaceTitle => 'Profundiza en tu interior';

  @override
  String get onboardingInnerSpaceDescription =>
      'Construye una práctica personal con meditación guiada, reflexión y herramientas de conciencia interior.';

  @override
  String get onboardingCommunityEyebrow => 'COMUNIDAD Y SERVICIO';

  @override
  String get onboardingCommunityTitle => 'Crecer juntos. Servir con propósito.';

  @override
  String get onboardingCommunityDescription =>
      'Conecta con otras personas, únete a programas con sentido y convierte el crecimiento interior en acción compasiva.';

  @override
  String get languageSelectionTitle => 'Elige tu idioma';

  @override
  String get languageSelectionDescription =>
      'Puedes cambiarlo más tarde en Ajustes.';

  @override
  String get languageSearchHint => 'Buscar idiomas';

  @override
  String get languageSearchClear => 'Borrar el campo de búsqueda';

  @override
  String get languageContinue => 'Continuar';

  @override
  String get languageNoResultsTitle => 'No se encontraron idiomas';

  @override
  String get languageNoResultsDescription =>
      'Prueba con otro nombre o código de idioma.';

  @override
  String get languageClearSearch => 'Borrar búsqueda';

  @override
  String get languageSelected => 'Seleccionado';

  @override
  String get languageDirectionRtl => 'RTL';

  @override
  String get languageDirectionRtlLabel => 'Escritura de derecha a izquierda';

  @override
  String get languageSaveFailed =>
      'No pudimos guardar tu idioma. Inténtalo de nuevo.';

  @override
  String get languageRetry => 'Reintentar';

  @override
  String languageResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count idiomas',
      one: '1 idioma',
      zero: 'Ningún idioma',
    );
    return '$_temp0';
  }

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get languageSwahili => 'Suajili';
}
