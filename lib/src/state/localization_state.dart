import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocale {
  en('en', 'EN', 'English'),
  es('es', 'ES', 'Español'),
  ca('ca', 'CA', 'Català');

  const AppLocale(this.code, this.shortLabel, this.label);

  final String code;
  final String shortLabel;
  final String label;

  static AppLocale fromCode(String? code) {
    return AppLocale.values.firstWhere(
      (locale) => locale.code == code,
      orElse: () => AppLocale.en,
    );
  }
}

class LocalizationState extends ChangeNotifier {
  static const _storageKey = 'trip2guide_locale';

  AppLocale _locale = AppLocale.en;

  AppLocale get locale => _locale;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _locale = AppLocale.fromCode(preferences.getString(_storageKey));
    notifyListeners();
  }

  Future<void> setLocale(AppLocale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, locale.code);
  }

  String t(String key, [Map<String, Object> values = const {}]) {
    var text =
        _translations[_locale]?[key] ??
        _translations[AppLocale.en]?[key] ??
        key;

    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value.toString());
    }

    return text;
  }
}

const _translations = {
  AppLocale.en: {
    'common.accessible': 'Accessible',
    'common.all': 'All',
    'common.back': 'Back',
    'common.cancel': 'Cancel',
    'common.save': 'Save',
    'common.saving': 'Saving...',
    'common.edit': 'Edit',
    'common.delete': 'Delete',
    'common.difficulty.easy': 'Easy',
    'common.difficulty.hard': 'Hard',
    'common.difficulty.medium': 'Medium',
    'common.language': 'Language',
    'common.next': 'Next',
    'common.no': 'No',
    'common.notSpecified': 'Not specified',
    'common.yes': 'Yes',
    'home.featuredDay': 'Featured route of the day',
    'home.featuredMonth': 'Featured route of the month',
    'home.featuredRoute': 'Featured route',
    'home.featuredWeek': 'Featured route of the week',
    'home.popularRoutes': 'Top 5 popular routes',
    'home.searchIntro': 'Explore the routes available in Trip2Guide.',
    'home.visitedCities': 'Top most visited cities',
    'loading.subtitle': 'Preparing your next route',
    'nav.favorites': 'Favorites',
    'nav.home': 'Home',
    'nav.login': 'Login',
    'nav.logout': 'Logout',
    'nav.profile': 'View profile',
    'nav.routes': 'Routes',
    'nav.chats': 'Chats',
    'chat.newGroup': 'New group',
    'chat.empty': 'There are no chats available.',
    'profile.title': 'My profile',
    'profile.subtitle': 'View and edit your account information and routes.',
    'profile.userNotFound': 'User session not found.',
    'profile.backHome': 'Back to home',
    'profile.accountInfo': 'Account information',
    'profile.name': 'Name',
    'profile.surname': 'Surname',
    'profile.username': 'Username',
    'profile.email': 'Email',
    'profile.newPassword': 'New password',
    'profile.confirmNewPassword': 'Confirm new password',
    'profile.passwordMismatch': 'The new passwords do not match.',
    'profile.passwordMin':
        'The new password must contain at least 6 characters.',
    'profile.updated': 'Profile updated successfully.',
    'profile.updatedPassword': 'Profile and password updated successfully.',
    'profile.creatorStats': 'Creator statistics',
    'profile.routesCreated': 'Routes created',
    'profile.pointsCreated': 'Points created',
    'profile.reviewsWritten': 'Reviews written',
    'profile.myReviews': 'My reviews',
    'profile.loadingReviews': 'Loading reviews...',
    'profile.noReviews': 'You have not published any reviews yet.',
    'profile.deleteReviewTitle': 'Delete review?',
    'profile.deleteReviewConfirm':
        'Delete "{name}"? This action cannot be undone.',
    'profile.myPublishedRoutes': 'My published routes',
    'profile.noPublishedRoutes': 'You have not published any routes yet.',
    'routes.generalMap': 'General route map with zones',
    'routes.hideZoneMap': 'Hide zone map',
    'routes.mapHelp':
        'Choose a zone below to show its polygon and search routes inside it.',
    'routes.showingZone': 'Showing routes inside {zone}.',
    'routes.seeAllZones': 'See all zones',
    'routes.searchingZone': 'Searching for routes inside the selected zone...',
    'search.accessible': 'Accessible',
    'search.distanceAsc': 'Distance ↑',
    'search.distanceDesc': 'Distance ↓',
    'search.difficultyAsc': 'Difficulty ↑',
    'search.difficultyDesc': 'Difficulty ↓',
    'search.durationAsc': 'Duration ↑',
    'search.durationDesc': 'Duration ↓',
    'search.noResults': 'No matching routes found.',
    'search.perPage': 'per page',
    'search.placeholder': 'Where do you want to explore today?',
    'search.results': 'Search results',
    'search.show': 'Show',
    'search.showing': 'Showing {start}-{end} of {total}',
  },
  AppLocale.es: {
    'common.accessible': 'Accesible',
    'common.all': 'Todas',
    'common.back': 'Atrás',
    'common.cancel': 'Cancelar',
    'common.save': 'Guardar',
    'common.saving': 'Guardando...',
    'common.edit': 'Editar',
    'common.delete': 'Eliminar',
    'common.difficulty.easy': 'Fácil',
    'common.difficulty.hard': 'Difícil',
    'common.difficulty.medium': 'Media',
    'common.language': 'Idioma',
    'common.next': 'Siguiente',
    'common.no': 'No',
    'common.notSpecified': 'No especificado',
    'common.yes': 'Sí',
    'home.featuredDay': 'Ruta destacada del día',
    'home.featuredMonth': 'Ruta destacada del mes',
    'home.featuredRoute': 'Ruta destacada',
    'home.featuredWeek': 'Ruta destacada de la semana',
    'home.popularRoutes': 'Top 5 rutas populares',
    'home.searchIntro': 'Explora las rutas disponibles en Trip2Guide.',
    'home.visitedCities': 'Ciudades más visitadas',
    'loading.subtitle': 'Preparando tu próxima ruta',
    'nav.favorites': 'Favoritos',
    'nav.home': 'Inicio',
    'nav.login': 'Login',
    'nav.logout': 'Cerrar sesión',
    'nav.profile': 'Ver perfil',
    'nav.routes': 'Rutas',
    'nav.chats': 'Chats',
    'chat.newGroup': 'Nuevo grupo',
    'chat.empty': 'No hay chats disponibles.',
    'profile.title': 'Mi perfil',
    'profile.subtitle':
        'Consulta y edita la información de tu cuenta y tus rutas.',
    'profile.userNotFound': 'Sesión de usuario no encontrada.',
    'profile.backHome': 'Volver al inicio',
    'profile.accountInfo': 'Información de la cuenta',
    'profile.name': 'Nombre',
    'profile.surname': 'Apellidos',
    'profile.username': 'Usuario',
    'profile.email': 'Email',
    'profile.newPassword': 'Nueva contraseña',
    'profile.confirmNewPassword': 'Confirmar nueva contraseña',
    'profile.passwordMismatch': 'Las nuevas contraseñas no coinciden.',
    'profile.passwordMin':
        'La nueva contraseña debe tener al menos 6 caracteres.',
    'profile.updated': 'Perfil actualizado correctamente.',
    'profile.updatedPassword':
        'Perfil y contraseña actualizados correctamente.',
    'profile.creatorStats': 'Estadísticas de creador',
    'profile.routesCreated': 'Rutas creadas',
    'profile.pointsCreated': 'Puntos creados',
    'profile.reviewsWritten': 'Reseñas escritas',
    'profile.myReviews': 'Mis reseñas',
    'profile.loadingReviews': 'Cargando reseñas...',
    'profile.noReviews': 'Todavía no has publicado ninguna reseña.',
    'profile.deleteReviewTitle': '¿Eliminar reseña?',
    'profile.deleteReviewConfirm':
        '¿Eliminar "{name}"? Esta acción no se puede deshacer.',
    'profile.myPublishedRoutes': 'Mis rutas publicadas',
    'profile.noPublishedRoutes': 'Todavía no has publicado ninguna ruta.',
    'routes.generalMap': 'Mapa general de rutas con zonas',
    'routes.hideZoneMap': 'Ocultar mapa de zonas',
    'routes.mapHelp':
        'Elige una zona para mostrar su polígono y buscar rutas dentro.',
    'routes.showingZone': 'Mostrando rutas dentro de {zone}.',
    'routes.seeAllZones': 'Ver todas las zonas',
    'routes.searchingZone': 'Buscando rutas dentro de la zona seleccionada...',
    'search.accessible': 'Accesible',
    'search.distanceAsc': 'Distancia ↑',
    'search.distanceDesc': 'Distancia ↓',
    'search.difficultyAsc': 'Dificultad ↑',
    'search.difficultyDesc': 'Dificultad ↓',
    'search.durationAsc': 'Duración ↑',
    'search.durationDesc': 'Duración ↓',
    'search.noResults': 'No se han encontrado rutas.',
    'search.perPage': 'por página',
    'search.placeholder': '¿Dónde quieres explorar hoy?',
    'search.results': 'Resultados de búsqueda',
    'search.show': 'Mostrar',
    'search.showing': 'Mostrando {start}-{end} de {total}',
  },
  AppLocale.ca: {
    'common.accessible': 'Accessible',
    'common.all': 'Totes',
    'common.back': 'Enrere',
    'common.cancel': 'Cancel·lar',
    'common.save': 'Desar',
    'common.saving': 'Desant...',
    'common.edit': 'Editar',
    'common.delete': 'Eliminar',
    'common.difficulty.easy': 'Fàcil',
    'common.difficulty.hard': 'Difícil',
    'common.difficulty.medium': 'Mitjana',
    'common.language': 'Idioma',
    'common.next': 'Següent',
    'common.no': 'No',
    'common.notSpecified': 'No especificat',
    'common.yes': 'Sí',
    'home.featuredDay': 'Ruta destacada del dia',
    'home.featuredMonth': 'Ruta destacada del mes',
    'home.featuredRoute': 'Ruta destacada',
    'home.featuredWeek': 'Ruta destacada de la setmana',
    'home.popularRoutes': 'Top 5 rutes populars',
    'home.searchIntro': 'Explora les rutes disponibles a Trip2Guide.',
    'home.visitedCities': 'Ciutats més visitades',
    'loading.subtitle': 'Preparant la teva pròxima ruta',
    'nav.favorites': 'Favorits',
    'nav.home': 'Inici',
    'nav.login': 'Login',
    'nav.logout': 'Tancar sessió',
    'nav.profile': 'Veure perfil',
    'nav.routes': 'Rutes',
    'nav.chats': 'Xats',
    'chat.newGroup': 'Nou grup',
    'chat.empty': 'No hi ha xats disponibles.',
    'profile.title': 'El meu perfil',
    'profile.subtitle':
        'Consulta i edita la informació del teu compte i les teves rutes.',
    'profile.userNotFound': 'No s’ha trobat la sessió d’usuari.',
    'profile.backHome': 'Tornar a l’inici',
    'profile.accountInfo': 'Informació del compte',
    'profile.name': 'Nom',
    'profile.surname': 'Cognoms',
    'profile.username': 'Usuari',
    'profile.email': 'Email',
    'profile.newPassword': 'Nova contrasenya',
    'profile.confirmNewPassword': 'Confirma la nova contrasenya',
    'profile.passwordMismatch': 'Les noves contrasenyes no coincideixen.',
    'profile.passwordMin':
        'La nova contrasenya ha de tenir almenys 6 caràcters.',
    'profile.updated': 'Perfil actualitzat correctament.',
    'profile.updatedPassword':
        'Perfil i contrasenya actualitzats correctament.',
    'profile.creatorStats': 'Estadístiques de creador',
    'profile.routesCreated': 'Rutes creades',
    'profile.pointsCreated': 'Punts creats',
    'profile.reviewsWritten': 'Ressenyes escrites',
    'profile.myReviews': 'Les meves ressenyes',
    'profile.loadingReviews': 'Carregant ressenyes...',
    'profile.noReviews': 'Encara no has publicat cap ressenya.',
    'profile.deleteReviewTitle': 'Eliminar ressenya?',
    'profile.deleteReviewConfirm':
        'Eliminar "{name}"? Aquesta acció no es pot desfer.',
    'profile.myPublishedRoutes': 'Les meves rutes publicades',
    'profile.noPublishedRoutes': 'Encara no has publicat cap ruta.',
    'routes.generalMap': 'Mapa general de rutes amb zones',
    'routes.hideZoneMap': 'Amagar mapa de zones',
    'routes.mapHelp':
        'Tria una zona per mostrar-ne el polígon i cercar rutes a dins.',
    'routes.showingZone': 'Mostrant rutes dins de {zone}.',
    'routes.seeAllZones': 'Veure totes les zones',
    'routes.searchingZone': 'Cercant rutes dins de la zona seleccionada...',
    'search.accessible': 'Accessible',
    'search.distanceAsc': 'Distància ↑',
    'search.distanceDesc': 'Distància ↓',
    'search.difficultyAsc': 'Dificultat ↑',
    'search.difficultyDesc': 'Dificultat ↓',
    'search.durationAsc': 'Durada ↑',
    'search.durationDesc': 'Durada ↓',
    'search.noResults': 'No s’han trobat rutes.',
    'search.perPage': 'per pàgina',
    'search.placeholder': 'On vols explorar avui?',
    'search.results': 'Resultats de cerca',
    'search.show': 'Mostrar',
    'search.showing': 'Mostrant {start}-{end} de {total}',
  },
};
