// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'Trip2Guide';

  @override
  String get loadingPreparingRoute => 'Preparant la teva pròxima ruta';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => 'EN · English';

  @override
  String get languageSpanish => 'ES · Español';

  @override
  String get languageCatalan => 'CA · Català';

  @override
  String get login => 'Inicia sessió';

  @override
  String get logout => 'Tanca la sessió';

  @override
  String get register => 'Registra\'t';

  @override
  String get viewProfile => 'Mostra el perfil';

  @override
  String get home => 'Inici';

  @override
  String get routes => 'Rutes';

  @override
  String get chats => 'Xats';

  @override
  String get favorites => 'Preferits';

  @override
  String get searchHint => 'On vols explorar avui?';

  @override
  String get searchResults => 'Resultats de cerca';

  @override
  String get show => 'Mostra';

  @override
  String get perPage => 'per pàgina';

  @override
  String get noMatchingRoutes => 'No s\'han trobat rutes coincidents.';

  @override
  String get noFavoriteRoutes => 'Encara no tens rutes preferides.';

  @override
  String get loginToViewFavorites =>
      'Has d\'iniciar sessió per veure les rutes preferides.';

  @override
  String get hideZoneMap => 'Amaga el mapa de zones';

  @override
  String get generalZoneMap => 'Mapa general de rutes amb zones';

  @override
  String get zoneMapHelp =>
      'Tria una zona per mostrar-ne el polígon i cercar rutes a l\'interior.';

  @override
  String zoneMapShowing(String zone) {
    return 'Mostrant rutes dins de $zone.';
  }

  @override
  String get seeAllZones => 'Mostra totes les zones';

  @override
  String get availableZones => 'Zones disponibles';

  @override
  String get searchingZone => 'Cercant rutes dins de la zona seleccionada...';

  @override
  String zoneRoutesFound(int count, String zone) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutes trobades dins de $zone.',
      one: '1 ruta trobada dins de $zone.',
    );
    return '$_temp0';
  }

  @override
  String get noZoneRoutes =>
      'No s\'han trobat rutes dins de la zona seleccionada.';

  @override
  String get zoneRoutesLoadFailed =>
      'No s\'han pogut carregar les rutes de la zona seleccionada.';

  @override
  String get barcelonaCentre => 'Centre de Barcelona';

  @override
  String get barcelonaCentreDescription => 'Zona central de Barcelona';

  @override
  String get madridCentre => 'Centre de Madrid';

  @override
  String get madridCentreDescription => 'Zona central de Madrid';

  @override
  String get sevilleCentre => 'Centre de Sevilla';

  @override
  String get sevilleCentreDescription => 'Zona central de Sevilla';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutes trobades',
      one: '1 ruta trobada',
      zero: 'No s\'han trobat rutes',
    );
    return '$_temp0';
  }

  @override
  String get accessible => 'Accessible';

  @override
  String get all => 'Tots';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get difficulty => 'Dificultat';

  @override
  String get difficultyEasy => 'Fàcil';

  @override
  String get difficultyMedium => 'Mitjana';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get requiredField => 'Camp obligatori';

  @override
  String get validNumber => 'Introdueix un número vàlid';

  @override
  String get validInteger => 'Introdueix un número enter vàlid';

  @override
  String get duration => 'Durada';

  @override
  String get distance => 'Distància';

  @override
  String get notSpecified => 'No especificat';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String kilometers(String distance) {
    return '$distance km';
  }

  @override
  String get featuredDay => 'Ruta destacada del dia';

  @override
  String get featuredWeek => 'Ruta destacada de la setmana';

  @override
  String get featuredMonth => 'Ruta destacada del mes';

  @override
  String get featuredRoute => 'Ruta destacada';

  @override
  String get exploreRoutes => 'Explora les rutes disponibles a Trip2Guide.';

  @override
  String get topVisitedCities => 'Ciutats més visitades';

  @override
  String get topPopularRoutes => 'Les 5 rutes més populars';

  @override
  String get favoriteRoutes => 'Rutes preferides';

  @override
  String get loginForFavorites => 'Inicia sessió per desar preferits.';

  @override
  String get loginToContinue => 'Inicia sessió per continuar.';

  @override
  String get back => 'Enrere';

  @override
  String get next => 'Següent';

  @override
  String get previous => 'Anterior';

  @override
  String showingResults(int start, int end, int total) {
    return 'Mostrant $start-$end de $total';
  }

  @override
  String get createRoute => 'Crea una ruta';

  @override
  String get routeCreated => 'Ruta creada correctament.';

  @override
  String get loginToCreateRoute => 'Inicia sessió per crear una ruta.';

  @override
  String get name => 'Nom';

  @override
  String get description => 'Descripció';

  @override
  String get coverImageUrl => 'URL de la imatge de portada';

  @override
  String get imageUrl => 'URL de la imatge';

  @override
  String get city => 'Ciutat';

  @override
  String get country => 'País';

  @override
  String get wheelchairAccessible => 'Accessible amb cadira de rodes';

  @override
  String get tags => 'Etiquetes';

  @override
  String get tagsHint => 'museu, ciutat, menjar';

  @override
  String get points => 'Punts';

  @override
  String get addPoint => 'Afegeix un punt';

  @override
  String pointNumber(int number) {
    return 'Punt $number';
  }

  @override
  String get pointName => 'Nom del punt';

  @override
  String get pointDescription => 'Descripció del punt';

  @override
  String get pointImageUrl => 'URL de la imatge del punt';

  @override
  String get latitude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String editPointsForRoute(String routeName) {
    return 'Edita els punts - $routeName';
  }

  @override
  String get editPoint => 'Edita el punt';

  @override
  String get pointCreated => 'Punt creat.';

  @override
  String get pointUpdated => 'Punt actualitzat.';

  @override
  String get pointDeleted => 'Punt eliminat.';

  @override
  String get deletePoint => 'Elimina el punt';

  @override
  String deletePointConfirmation(String pointName) {
    return 'Segur que vols eliminar «$pointName»?';
  }

  @override
  String get routeHasNoPoints => 'Aquesta ruta encara no té punts.';

  @override
  String get noRoutePointsMap =>
      'No hi ha punts de ruta disponibles per a aquest mapa.';

  @override
  String get save => 'Desa';

  @override
  String get cancel => 'Cancel·la';

  @override
  String get delete => 'Elimina';

  @override
  String get aboutRoute => 'Sobre aquesta ruta';

  @override
  String get routeTags => 'Etiquetes de la ruta';

  @override
  String get routeMap => 'Mapa de la ruta';

  @override
  String get startRoute => 'Inicia la ruta';

  @override
  String get reviews => 'Ressenyes';

  @override
  String get routeGallery => 'Galeria de la ruta';

  @override
  String get quickActions => 'Accions ràpides';

  @override
  String get saveToFavorites => 'Desa als preferits';

  @override
  String get savedToFavorites => 'Desada als preferits';

  @override
  String get rating => 'Valoració';

  @override
  String get notRated => 'Sense valorar';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ressenyes',
      one: '1 ressenya',
    );
    return '$_temp0';
  }

  @override
  String get loadingReviews => 'Carregant ressenyes...';

  @override
  String get noReviews => 'Encara no hi ha ressenyes.';

  @override
  String get reviewTitleRequired => 'Afegeix un títol a la ressenya.';

  @override
  String get reviewPublished => 'Ressenya publicada correctament.';

  @override
  String get yourReview => 'La teva ressenya';

  @override
  String yourReviewNotice(String title) {
    return 'Has valorat aquesta ruta com a «$title». Només pots publicar una ressenya per ruta.';
  }

  @override
  String get addYourReview => 'Afegeix la teva ressenya';

  @override
  String get scenery => 'Paisatge';

  @override
  String get signage => 'Senyalització';

  @override
  String get safety => 'Seguretat';

  @override
  String get addReview => 'Afegeix una ressenya';

  @override
  String get cancelReview => 'Cancel·la la ressenya';

  @override
  String get loginToReview => 'Inicia sessió per publicar una ressenya';

  @override
  String get reviewTitle => 'Títol';

  @override
  String get reviewComment => 'Comentari';

  @override
  String get publishReview => 'Publica la ressenya';

  @override
  String get publishing => 'Publicant...';

  @override
  String get newGroup => 'Grup nou';

  @override
  String get chatLoadFailed => 'No s\'han pogut carregar els xats.';

  @override
  String get loginToUseChats => 'Has d\'iniciar sessió per utilitzar els xats.';

  @override
  String get noChats => 'No hi ha xats disponibles.';

  @override
  String get alreadyMember => 'Ja n\'ets membre';

  @override
  String get passwordRequiredGroup => 'Cal una contrasenya';

  @override
  String get openGroup => 'Grup obert';

  @override
  String get selectChat => 'Selecciona un xat per veure\'n els missatges.';

  @override
  String get noMessages => 'Encara no hi ha missatges en aquest xat.';

  @override
  String unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count missatges sense llegir',
      one: '1 missatge sense llegir',
    );
    return '$_temp0';
  }

  @override
  String enterGroup(String groupName) {
    return 'Entra a $groupName';
  }

  @override
  String get createGroup => 'Crea un grup';

  @override
  String get messageHint => 'Missatge...';

  @override
  String get groupPassword => 'Contrasenya del grup';

  @override
  String get groupName => 'Nom del grup';

  @override
  String get optionalPassword => 'Contrasenya opcional';

  @override
  String get enter => 'Entra';

  @override
  String get create => 'Crea';

  @override
  String get loginToSendMessages =>
      'Has d\'iniciar sessió per enviar missatges.';

  @override
  String messageSendFailed(String error) {
    return 'No s\'ha pogut enviar el missatge: $error';
  }

  @override
  String get continueAction => 'Continua';

  @override
  String get signIn => 'Inicia sessió';

  @override
  String get signUp => 'Registra\'t';

  @override
  String get createAccount => 'Crea un compte';

  @override
  String get createAccountAction => 'Crea el compte';

  @override
  String get signInSubtitle => 'Introdueix el correu per continuar';

  @override
  String get signUpSubtitle =>
      'Introdueix el correu per registrar-te a l\'aplicació';

  @override
  String get emailRequired => 'Introdueix una adreça de correu.';

  @override
  String get passwordRequired => 'Introdueix una contrasenya.';

  @override
  String get confirmPasswordRequired => 'Confirma la contrasenya.';

  @override
  String get passwordRules =>
      'Mín. 6 caràcters, 1 majúscula, 1 número i 1 caràcter especial.';

  @override
  String get passwordsDoNotMatch => 'Les contrasenyes no coincideixen.';

  @override
  String get required => 'Obligatori';

  @override
  String get loading => 'Carregant...';

  @override
  String get unexpectedError => 'S\'ha produït un error inesperat.';

  @override
  String get legalPrefix => 'En continuar, acceptes els nostres ';

  @override
  String get termsOfService => 'Termes del servei';

  @override
  String get legalAnd => ' i la ';

  @override
  String get privacyPolicy => 'Política de privacitat';

  @override
  String get noAccount => 'No tens cap compte?';

  @override
  String get alreadyAccount => 'Ja tens un compte?';

  @override
  String get continueGoogle => 'Continua amb Google';

  @override
  String get continueAppleUnavailable => 'Continua amb Apple no disponible';

  @override
  String get goToMainPage => 'Ves a la pàgina principal';

  @override
  String get email => 'Correu electrònic';

  @override
  String get firstName => 'Nom';

  @override
  String get lastName => 'Cognoms';

  @override
  String get username => 'Nom d\'usuari';

  @override
  String get password => 'Contrasenya';

  @override
  String get confirmPassword => 'Confirma la contrasenya';

  @override
  String get accountInformation => 'Informació del compte';

  @override
  String get myProfile => 'El meu perfil';

  @override
  String get profileSubtitle =>
      'Consulta i edita la informació del compte i les teves rutes.';

  @override
  String get backHome => 'Torna a l\'inici';

  @override
  String get saving => 'Desant...';

  @override
  String get edit => 'Edita';

  @override
  String get surname => 'Cognoms';

  @override
  String get newPassword => 'Contrasenya nova';

  @override
  String get confirmNewPassword => 'Confirma la contrasenya nova';

  @override
  String get newPasswordsMismatch => 'Les contrasenyes noves no coincideixen.';

  @override
  String get newPasswordLength =>
      'La contrasenya nova ha de tenir almenys 6 caràcters.';

  @override
  String get profileUpdated => 'Perfil actualitzat correctament.';

  @override
  String get profilePasswordUpdated =>
      'Perfil i contrasenya actualitzats correctament.';

  @override
  String get routesCreated => 'Rutes creades';

  @override
  String get pointsCreated => 'Punts creats';

  @override
  String get reviewsWritten => 'Ressenyes escrites';

  @override
  String get noPublishedReviews => 'Encara no has publicat cap ressenya.';

  @override
  String get reviewTitleRequiredShort =>
      'El títol de la ressenya és obligatori.';

  @override
  String get reviewDeleted => 'Ressenya eliminada correctament.';

  @override
  String get editingReview => 'Editant la ressenya';

  @override
  String get editingRoute => 'Editant la ruta';

  @override
  String get deleting => 'Eliminant...';

  @override
  String get date => 'Data';

  @override
  String routeLabel(String name) {
    return 'Ruta: $name';
  }

  @override
  String routeIdLabel(String id) {
    return 'ID de ruta: $id';
  }

  @override
  String get coverImage => 'Imatge de portada';

  @override
  String get imagesCommaSeparated => 'Imatges (separades per comes)';

  @override
  String get tagsCommaSeparated => 'Etiquetes (separades per comes)';

  @override
  String get deleteReview => 'Vols eliminar la ressenya?';

  @override
  String deleteReviewConfirmation(String title) {
    return 'Vols eliminar «$title»? Aquesta acció no es pot desfer.';
  }

  @override
  String get noPublishedRoutes => 'Encara no has publicat cap ruta.';

  @override
  String get creatorStatistics => 'Estadístiques de creador';

  @override
  String get myReviews => 'Les meves ressenyes';

  @override
  String get myPublishedRoutes => 'Les meves rutes publicades';

  @override
  String get userSessionNotFound => 'No s\'ha trobat la sessió de l\'usuari.';

  @override
  String get achievements => 'Assoliments';

  @override
  String get achievementsLoading => 'Carregant assoliments...';

  @override
  String get achievementsUnlocked => 'Mostra els desbloquejats';

  @override
  String get achievementsAll => 'Mostra\'ls tots';

  @override
  String get achievementsEmpty => 'Encara no has desbloquejat cap assoliment.';

  @override
  String get achievementsLoadFailed =>
      'No s\'han pogut carregar els assoliments.';

  @override
  String get accessibility => 'Accessibilitat';

  @override
  String get close => 'Tanca';

  @override
  String get colorAdjustment => 'Ajust de color';

  @override
  String get monochrome => 'Monocrom';

  @override
  String get darkContrast => 'Contrast fosc';

  @override
  String get lightContrast => 'Contrast clar';

  @override
  String get lowSaturation => 'Saturació baixa';

  @override
  String get highSaturation => 'Saturació alta';

  @override
  String get highContrast => 'Contrast alt';

  @override
  String get contentAdjustment => 'Ajust de contingut';

  @override
  String get fontSettings => 'Configuració de la lletra';

  @override
  String get fontSettingsSubtitle =>
      'Augmenta o modifica la llegibilitat del text';

  @override
  String level(int level) {
    return 'Nivell $level';
  }

  @override
  String get lineSpacing => 'Interlineat';

  @override
  String get wordSpacing => 'Espaiat de paraules';

  @override
  String get letterSpacing => 'Espaiat de lletres';

  @override
  String get resetSettings => 'Restableix la configuració';

  @override
  String get openAccessibility => 'Obre la configuració d\'accessibilitat';

  @override
  String get pedroGreeting =>
      'Holaaa, soc en Pedro i soc aquí per ajudar-te a trobar rutes!';

  @override
  String get pedroError =>
      'No he pogut enviar el missatge ara. Torna-ho a provar d\'aquí a un moment.';

  @override
  String get pedroOpen => 'Obre l\'assistent Pedro';

  @override
  String get pedroCloseGreeting => 'Tanca la salutació';

  @override
  String get pedroSubtitle => 'El teu assistent de rutes';

  @override
  String get pedroCloseConversation => 'Tanca la conversa';

  @override
  String get pedroAskHint => 'Pregunta a en Pedro...';

  @override
  String get send => 'Envia';

  @override
  String get pedroThinking => 'En Pedro està pensant...';

  @override
  String get otherOptions => 'Altres opcions';

  @override
  String get viewRoute => 'Mostra la ruta';

  @override
  String get routeNotFound => 'No s\'ha trobat la ruta.';

  @override
  String get routeOpenFailed => 'No s\'ha pogut obrir aquesta ruta.';

  @override
  String get routeFindFailed => 'No s\'ha pogut trobar aquesta ruta.';

  @override
  String get errorInvalidCredentials => 'Credencials incorrectes.';

  @override
  String get errorGoogleLoginFailed =>
      'No s\'ha pogut iniciar sessió amb Google.';

  @override
  String get errorRegistrationFailed => 'No s\'ha pogut registrar l\'usuari.';

  @override
  String get errorUserSessionNotFound =>
      'No s\'ha trobat la sessió de l\'usuari.';

  @override
  String get errorRouteNotFound => 'No s\'ha trobat la ruta.';

  @override
  String get errorLoginToCreateRoutes =>
      'Has d\'iniciar sessió per crear rutes.';

  @override
  String get errorLoginToSaveFavorites =>
      'Has d\'iniciar sessió per desar preferits.';

  @override
  String get errorRequestFailed => 'La sol·licitud ha fallat.';

  @override
  String get errorUnknown => 'Alguna cosa ha anat malament. Torna-ho a provar.';
}
