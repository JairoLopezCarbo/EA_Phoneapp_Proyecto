// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Trip2Guide';

  @override
  String get loadingPreparingRoute => 'Preparando tu próxima ruta';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => 'EN · English';

  @override
  String get languageSpanish => 'ES · Español';

  @override
  String get languageCatalan => 'CA · Català';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get home => 'Inicio';

  @override
  String get routes => 'Rutas';

  @override
  String get chats => 'Chats';

  @override
  String get favorites => 'Favoritos';

  @override
  String get searchHint => '¿Dónde quieres explorar hoy?';

  @override
  String get searchResults => 'Resultados de búsqueda';

  @override
  String get show => 'Mostrar';

  @override
  String get perPage => 'por página';

  @override
  String get noMatchingRoutes => 'No se han encontrado rutas coincidentes.';

  @override
  String get noFavoriteRoutes => 'Todavía no tienes rutas favoritas.';

  @override
  String get loginToViewFavorites =>
      'Debes iniciar sesión para ver tus rutas favoritas.';

  @override
  String get hideZoneMap => 'Ocultar mapa de zonas';

  @override
  String get generalZoneMap => 'Mapa general de rutas con zonas';

  @override
  String get zoneMapHelp =>
      'Elige una zona para mostrar su polígono y buscar rutas en su interior.';

  @override
  String zoneMapShowing(String zone) {
    return 'Mostrando rutas dentro de $zone.';
  }

  @override
  String get seeAllZones => 'Ver todas las zonas';

  @override
  String get availableZones => 'Zonas disponibles';

  @override
  String get searchingZone =>
      'Buscando rutas dentro de la zona seleccionada...';

  @override
  String zoneRoutesFound(int count, String zone) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutas encontradas dentro de $zone.',
      one: '1 ruta encontrada dentro de $zone.',
    );
    return '$_temp0';
  }

  @override
  String get noZoneRoutes =>
      'No se han encontrado rutas dentro de la zona seleccionada.';

  @override
  String get zoneRoutesLoadFailed =>
      'No se han podido cargar las rutas de la zona seleccionada.';

  @override
  String get barcelonaCentre => 'Centro de Barcelona';

  @override
  String get barcelonaCentreDescription => 'Zona central de Barcelona';

  @override
  String get madridCentre => 'Centro de Madrid';

  @override
  String get madridCentreDescription => 'Zona central de Madrid';

  @override
  String get sevilleCentre => 'Centro de Sevilla';

  @override
  String get sevilleCentreDescription => 'Zona central de Sevilla';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutas encontradas',
      one: '1 ruta encontrada',
      zero: 'No se han encontrado rutas',
    );
    return '$_temp0';
  }

  @override
  String get accessible => 'Accesible';

  @override
  String get all => 'Todos';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get difficulty => 'Dificultad';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Media';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get requiredField => 'Campo obligatorio';

  @override
  String get validNumber => 'Introduce un número válido';

  @override
  String get validInteger => 'Introduce un número entero válido';

  @override
  String get duration => 'Duración';

  @override
  String get distance => 'Distancia';

  @override
  String get notSpecified => 'No especificado';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String kilometers(String distance) {
    return '$distance km';
  }

  @override
  String get featuredDay => 'Ruta destacada del día';

  @override
  String get featuredWeek => 'Ruta destacada de la semana';

  @override
  String get featuredMonth => 'Ruta destacada del mes';

  @override
  String get featuredRoute => 'Ruta destacada';

  @override
  String get exploreRoutes => 'Explora las rutas disponibles en Trip2Guide.';

  @override
  String get topVisitedCities => 'Ciudades más visitadas';

  @override
  String get topPopularRoutes => 'Las 5 rutas más populares';

  @override
  String get favoriteRoutes => 'Rutas favoritas';

  @override
  String get loginForFavorites => 'Inicia sesión para guardar favoritos.';

  @override
  String get loginToContinue => 'Inicia sesión para continuar.';

  @override
  String get back => 'Volver';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String showingResults(int start, int end, int total) {
    return 'Mostrando $start-$end de $total';
  }

  @override
  String get createRoute => 'Crear ruta';

  @override
  String get routeCreated => 'Ruta creada correctamente.';

  @override
  String get loginToCreateRoute => 'Inicia sesión para crear una ruta.';

  @override
  String get name => 'Nombre';

  @override
  String get description => 'Descripción';

  @override
  String get coverImageUrl => 'URL de la imagen de portada';

  @override
  String get imageUrl => 'URL de la imagen';

  @override
  String get city => 'Ciudad';

  @override
  String get country => 'País';

  @override
  String get wheelchairAccessible => 'Accesible en silla de ruedas';

  @override
  String get tags => 'Etiquetas';

  @override
  String get tagsHint => 'museo, ciudad, comida';

  @override
  String get points => 'Puntos';

  @override
  String get addPoint => 'Añadir punto';

  @override
  String pointNumber(int number) {
    return 'Punto $number';
  }

  @override
  String get pointName => 'Nombre del punto';

  @override
  String get pointDescription => 'Descripción del punto';

  @override
  String get pointImageUrl => 'URL de la imagen del punto';

  @override
  String get latitude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String editPointsForRoute(String routeName) {
    return 'Editar puntos - $routeName';
  }

  @override
  String get editPoint => 'Editar punto';

  @override
  String get pointCreated => 'Punto creado.';

  @override
  String get pointUpdated => 'Punto actualizado.';

  @override
  String get pointDeleted => 'Punto eliminado.';

  @override
  String get deletePoint => 'Eliminar punto';

  @override
  String deletePointConfirmation(String pointName) {
    return '¿Seguro que quieres eliminar «$pointName»?';
  }

  @override
  String get routeHasNoPoints => 'Esta ruta todavía no tiene puntos.';

  @override
  String get noRoutePointsMap =>
      'No hay puntos de ruta disponibles para este mapa.';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get aboutRoute => 'Sobre esta ruta';

  @override
  String get routeTags => 'Etiquetas de la ruta';

  @override
  String get routeMap => 'Mapa de la ruta';

  @override
  String get startRoute => 'Iniciar ruta';

  @override
  String get reviews => 'Reseñas';

  @override
  String get routeGallery => 'Galería de la ruta';

  @override
  String get quickActions => 'Acciones rápidas';

  @override
  String get saveToFavorites => 'Guardar en favoritos';

  @override
  String get savedToFavorites => 'Guardada en favoritos';

  @override
  String get rating => 'Valoración';

  @override
  String get notRated => 'Sin valorar';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reseñas',
      one: '1 reseña',
    );
    return '$_temp0';
  }

  @override
  String get loadingReviews => 'Cargando reseñas...';

  @override
  String get noReviews => 'Todavía no hay reseñas.';

  @override
  String get reviewTitleRequired => 'Añade un título a la reseña.';

  @override
  String get reviewPublished => 'Reseña publicada correctamente.';

  @override
  String get yourReview => 'Tu reseña';

  @override
  String yourReviewNotice(String title) {
    return 'Has valorado esta ruta como «$title». Solo puedes publicar una reseña por ruta.';
  }

  @override
  String get addYourReview => 'Añade tu reseña';

  @override
  String get scenery => 'Paisaje';

  @override
  String get signage => 'Señalización';

  @override
  String get safety => 'Seguridad';

  @override
  String get addReview => 'Añadir reseña';

  @override
  String get cancelReview => 'Cancelar reseña';

  @override
  String get loginToReview => 'Inicia sesión para publicar una reseña';

  @override
  String get reviewTitle => 'Título';

  @override
  String get reviewComment => 'Comentario';

  @override
  String get publishReview => 'Publicar reseña';

  @override
  String get publishing => 'Publicando...';

  @override
  String get newGroup => 'Nuevo grupo';

  @override
  String get chatLoadFailed => 'No se han podido cargar los chats.';

  @override
  String get loginToUseChats => 'Debes iniciar sesión para usar los chats.';

  @override
  String get noChats => 'No hay chats disponibles.';

  @override
  String get alreadyMember => 'Ya eres miembro';

  @override
  String get passwordRequiredGroup => 'Se necesita contraseña';

  @override
  String get openGroup => 'Grupo abierto';

  @override
  String get selectChat => 'Selecciona un chat para ver sus mensajes.';

  @override
  String get noMessages => 'Todavía no hay mensajes en este chat.';

  @override
  String unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes sin leer',
      one: '1 mensaje sin leer',
    );
    return '$_temp0';
  }

  @override
  String enterGroup(String groupName) {
    return 'Entrar en $groupName';
  }

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get messageHint => 'Mensaje...';

  @override
  String get groupPassword => 'Contraseña del grupo';

  @override
  String get groupName => 'Nombre del grupo';

  @override
  String get optionalPassword => 'Contraseña opcional';

  @override
  String get enter => 'Entrar';

  @override
  String get create => 'Crear';

  @override
  String get loginToSendMessages =>
      'Debes iniciar sesión para enviar mensajes.';

  @override
  String messageSendFailed(String error) {
    return 'No se pudo enviar el mensaje: $error';
  }

  @override
  String get continueAction => 'Continuar';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get createAccountAction => 'Crear cuenta';

  @override
  String get signInSubtitle => 'Introduce tu correo para continuar';

  @override
  String get signUpSubtitle =>
      'Introduce tu correo para registrarte en la aplicación';

  @override
  String get emailRequired => 'Introduce una dirección de correo.';

  @override
  String get passwordRequired => 'Introduce una contraseña.';

  @override
  String get confirmPasswordRequired => 'Confirma tu contraseña.';

  @override
  String get passwordRules =>
      'Mín. 6 caracteres, 1 mayúscula, 1 número y 1 carácter especial.';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get required => 'Obligatorio';

  @override
  String get loading => 'Cargando...';

  @override
  String get unexpectedError => 'Se ha producido un error inesperado.';

  @override
  String get legalPrefix => 'Al continuar, aceptas nuestros ';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get legalAnd => ' y la ';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get noAccount => '¿No tienes una cuenta?';

  @override
  String get alreadyAccount => '¿Ya tienes una cuenta?';

  @override
  String get continueGoogle => 'Continuar con Google';

  @override
  String get continueAppleUnavailable => 'Continuar con Apple no disponible';

  @override
  String get goToMainPage => 'Ir a la página principal';

  @override
  String get email => 'Correo electrónico';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellidos';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get accountInformation => 'Información de la cuenta';

  @override
  String get myProfile => 'Mi perfil';

  @override
  String get profileSubtitle =>
      'Consulta y edita la información de tu cuenta y tus rutas.';

  @override
  String get backHome => 'Volver al inicio';

  @override
  String get saving => 'Guardando...';

  @override
  String get edit => 'Editar';

  @override
  String get surname => 'Apellidos';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get newPasswordsMismatch => 'Las nuevas contraseñas no coinciden.';

  @override
  String get newPasswordLength =>
      'La nueva contraseña debe tener al menos 6 caracteres.';

  @override
  String get profileUpdated => 'Perfil actualizado correctamente.';

  @override
  String get profilePasswordUpdated =>
      'Perfil y contraseña actualizados correctamente.';

  @override
  String get routesCreated => 'Rutas creadas';

  @override
  String get pointsCreated => 'Puntos creados';

  @override
  String get reviewsWritten => 'Reseñas escritas';

  @override
  String get noPublishedReviews => 'Todavía no has publicado ninguna reseña.';

  @override
  String get reviewTitleRequiredShort =>
      'El título de la reseña es obligatorio.';

  @override
  String get reviewDeleted => 'Reseña eliminada correctamente.';

  @override
  String get editingReview => 'Editando reseña';

  @override
  String get editingRoute => 'Editando ruta';

  @override
  String get deleting => 'Eliminando...';

  @override
  String get date => 'Fecha';

  @override
  String routeLabel(String name) {
    return 'Ruta: $name';
  }

  @override
  String routeIdLabel(String id) {
    return 'ID de ruta: $id';
  }

  @override
  String get coverImage => 'Imagen de portada';

  @override
  String get imagesCommaSeparated => 'Imágenes (separadas por comas)';

  @override
  String get tagsCommaSeparated => 'Etiquetas (separadas por comas)';

  @override
  String get deleteReview => '¿Eliminar reseña?';

  @override
  String deleteReviewConfirmation(String title) {
    return '¿Eliminar «$title»? Esta acción no se puede deshacer.';
  }

  @override
  String get noPublishedRoutes => 'Todavía no has publicado ninguna ruta.';

  @override
  String get creatorStatistics => 'Estadísticas de creador';

  @override
  String get myReviews => 'Mis reseñas';

  @override
  String get myPublishedRoutes => 'Mis rutas publicadas';

  @override
  String get userSessionNotFound =>
      'No se ha encontrado la sesión del usuario.';

  @override
  String get achievements => 'Logros';

  @override
  String get achievementsLoading => 'Cargando logros...';

  @override
  String get achievementsUnlocked => 'Ver desbloqueados';

  @override
  String get achievementsAll => 'Ver todos';

  @override
  String get achievementsEmpty => 'Todavía no has desbloqueado ningún logro.';

  @override
  String get achievementsLoadFailed => 'No se han podido cargar los logros.';

  @override
  String get accessibility => 'Accesibilidad';

  @override
  String get close => 'Cerrar';

  @override
  String get colorAdjustment => 'Ajuste de color';

  @override
  String get monochrome => 'Monocromo';

  @override
  String get darkContrast => 'Contraste oscuro';

  @override
  String get lightContrast => 'Contraste claro';

  @override
  String get lowSaturation => 'Saturación baja';

  @override
  String get highSaturation => 'Saturación alta';

  @override
  String get highContrast => 'Contraste alto';

  @override
  String get contentAdjustment => 'Ajuste de contenido';

  @override
  String get fontSettings => 'Ajustes de fuente';

  @override
  String get fontSettingsSubtitle =>
      'Aumenta o modifica la legibilidad del texto';

  @override
  String level(int level) {
    return 'Nivel $level';
  }

  @override
  String get lineSpacing => 'Interlineado';

  @override
  String get wordSpacing => 'Espaciado de palabras';

  @override
  String get letterSpacing => 'Espaciado de letras';

  @override
  String get resetSettings => 'Restablecer ajustes';

  @override
  String get openAccessibility => 'Abrir ajustes de accesibilidad';

  @override
  String get pedroGreeting =>
      '¡Holaaa, soy Pedro y estoy aquí para ayudarte a encontrar rutas!';

  @override
  String get pedroError =>
      'No he podido enviar el mensaje ahora. Inténtalo de nuevo en un momento.';

  @override
  String get pedroOpen => 'Abrir el asistente Pedro';

  @override
  String get pedroCloseGreeting => 'Cerrar saludo';

  @override
  String get pedroSubtitle => 'Tu asistente de rutas';

  @override
  String get pedroCloseConversation => 'Cerrar conversación';

  @override
  String get pedroAskHint => 'Pregunta a Pedro...';

  @override
  String get send => 'Enviar';

  @override
  String get pedroThinking => 'Pedro está pensando...';

  @override
  String get otherOptions => 'Otras opciones';

  @override
  String get viewRoute => 'Ver ruta';

  @override
  String get routeNotFound => 'Ruta no encontrada.';

  @override
  String get routeOpenFailed => 'No se ha podido abrir esa ruta.';

  @override
  String get routeFindFailed => 'No se ha podido encontrar esa ruta.';

  @override
  String get errorInvalidCredentials => 'Credenciales incorrectas.';

  @override
  String get errorGoogleLoginFailed => 'No se pudo iniciar sesión con Google.';

  @override
  String get errorRegistrationFailed => 'No se pudo registrar al usuario.';

  @override
  String get errorUserSessionNotFound =>
      'No se ha encontrado la sesión del usuario.';

  @override
  String get errorRouteNotFound => 'Ruta no encontrada.';

  @override
  String get errorLoginToCreateRoutes =>
      'Debes iniciar sesión para crear rutas.';

  @override
  String get errorLoginToSaveFavorites =>
      'Debes iniciar sesión para guardar favoritos.';

  @override
  String get errorRequestFailed => 'La solicitud ha fallado.';

  @override
  String get errorUnknown => 'Algo ha ido mal. Inténtalo de nuevo.';
}
