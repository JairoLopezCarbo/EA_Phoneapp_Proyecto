import 'package:flutter/foundation.dart';

import '../models/app_models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/route_service.dart';
import '../services/push_notification_service.dart';
import '../utils/formatters.dart';

class AppState extends ChangeNotifier {
  bool _initialized = false;
  List<RouteModel> _routes = <RouteModel>[];
  List<String> _popularRouteIds = <String>[];
  AppUser? _currentUser;
  String? _sessionToken;

  bool get initialized => _initialized;
  bool get isAuthenticated => currentUser != null;

  List<RouteModel> get routes => List<RouteModel>.unmodifiable(_routes);

  List<RouteModel> get popularRoutes {
    final routeById = {for (final route in _routes) route.id: route};
    final preferred = _popularRouteIds
        .map((routeId) => routeById[routeId])
        .whereType<RouteModel>()
        .toList(growable: false);

    if (preferred.isNotEmpty) {
      return preferred.take(5).toList(growable: false);
    }

    return _routes.take(5).toList(growable: false);
  }

  List<RouteModel> get featuredRoutes {
    if (_routes.length <= 3) {
      return List<RouteModel>.from(_routes);
    }

    return _routes.sublist(_routes.length - 3);
  }

  List<String> get popularRouteIds =>
      List<String>.unmodifiable(_popularRouteIds);

  AppUser? get currentUser => _currentUser;

  String? get sessionToken => _sessionToken;

  List<RouteModel> favoriteRoutesForCurrentUser() {
    final user = currentUser;
    if (user == null) {
      return <RouteModel>[];
    }

    final routeById = {for (final route in _routes) route.id: route};
    return user.favoriteRouteIds
        .map((routeId) => routeById[routeId])
        .whereType<RouteModel>()
        .toList(growable: false);
  }

  List<RouteModel> routesByUser(String userId) {
    return _routes.where((route) => route.userId == userId).toList(growable: false);
  }

  RouteModel? routeById(String id) {
    for (final route in _routes) {
      if (route.id == id) {
        return route;
      }
    }

    return null;
  }

  List<RouteModel> searchRoutes(String query, {List<RouteModel>? source}) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return <RouteModel>[];
    }

    final items = source ?? _routes;
    return items.where((route) {
      final tags = route.tags.join(' ').toLowerCase();
      return route.city.toLowerCase().contains(normalized) ||
          route.name.toLowerCase().contains(normalized) ||
          route.description.toLowerCase().contains(normalized) ||
          tags.contains(normalized);
    }).toList(growable: false);
  }

  List<String> visitedCityKeys() {
    final seen = <String>{};
    final result = <String>[];

    for (final route in _routes) {
      final key = '${route.city}-${route.country}';
      if (seen.add(key)) {
        result.add(key);
      }
    }

    return result;
  }

  List<RouteModel> routesInCityKey(String cityKey) {
    return _routes
        .where((route) => '${route.city}-${route.country}' == cityKey)
        .toList(growable: false);
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final session = await getStoredSession();
    _sessionToken = session?.token;
    _currentUser = session?.user;

    await _loadRoutes();
    await _refreshCurrentUserFromApi();

    if (_currentUser != null && _sessionToken != null) {
      try {
        await pushNotificationService.configureForUser(
          _currentUser!.id,
          token: _sessionToken,
        );
      } catch (e) {
        debugPrint('No se pudo configurar FCM: $e');
      }
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final payload = await apiClient.postJson(
      '/auth/login',
      body: <String, dynamic>{'email': email.trim(), 'password': password},
    );

    if (payload is! Map<String, dynamic>) {
      throw StateError('Invalid credentials.');
    }

    final token =
        (payload['accessToken'] as String?) ?? (payload['token'] as String?);
    final rawUser = payload['user'];

    if (token == null ||
        token.trim().isEmpty ||
        rawUser is! Map<String, dynamic>) {
      throw StateError('Invalid credentials.');
    }

    _sessionToken = token;
    _currentUser = AppUser.fromApiJson(rawUser);
    await storeSession(token: token, user: _currentUser!);
    await _loadRoutes();

    try {
      final favoriteRoutes = await profileService.getFavoriteRoutesByUserId(
        _currentUser!.id,
        token: token,
      );
      _currentUser = _currentUser!.copyWith(
        favoriteRouteIds: favoriteRoutes.map((route) => route.id).toList(growable: false),
      );
      await storeSession(token: token, user: _currentUser!);
    } catch (_) {
      // Keep the session user returned by the login endpoint when favorites cannot be fetched.
    }
    try {
      await pushNotificationService.configureForUser(
        _currentUser!.id,
        token: _sessionToken,
      );
    } catch (e) {
      debugPrint('No se pudo configurar FCM: $e');
    }
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String surname,
    required String username,
    required String email,
    required String password,
  }) async {
    final payload = await apiClient.postJson(
      '/users',
      body: <String, dynamic>{
        'name': name.trim(),
        'surname': surname.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
      },
    );

    if (payload is! Map<String, dynamic>) {
      throw StateError('Unable to register the user.');
    }

    notifyListeners();
  }

  Future<void> logout() async {
    final user = _currentUser;
    final token = _sessionToken;

    if (user != null && token != null) {
      try {
        await pushNotificationService.unregisterForUser(user.id, token: token);
      } catch (_) {}
    }

    try {
      await apiClient.postJson('/auth/logout', token: _sessionToken);
    } catch (_) {}

    _currentUser = null;
    _sessionToken = null;
    await clearStoredSession();
    notifyListeners();
  }

  Future<void> updateCurrentUser({
    required String name,
    required String surname,
    required String username,
    required String email,
    String? newPassword,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('User session not found.');
    }

    final updatedUser = await profileService.updateUserById(
      user.id,
      UpdateUserPayload(
        name: name.trim(),
        surname: surname.trim(),
        username: username.trim(),
        email: email.trim(),
        password: newPassword,
        enabled: user.enabled,
        role: user.role,
      ),
      token: _sessionToken,
    );

    _currentUser = updatedUser.copyWith(
      favoriteRouteIds: user.favoriteRouteIds,
    );

    await saveStoredSessionUser(_currentUser!);
    notifyListeners();
  }

  Future<void> updateRoute({
    required String routeId,
    required String name,
    required String description,
    required String coverImage,
    required List<String> images,
    required RouteDifficulty difficulty,
    required String city,
    required String country,
    required List<String> tags,
    double? distance,
    int? duration,
  }) async {
    final routeIndex = _routes.indexWhere((route) => route.id == routeId);
    if (routeIndex == -1) {
      throw StateError('Route not found.');
    }

    final currentRoute = _routes[routeIndex];

    final routeToUpdate = currentRoute.copyWith(
      name: name.trim(),
      description: description.trim(),
      coverImage: coverImage.trim(),
      images: images,
      difficulty: difficulty,
      city: city.trim(),
      country: country.trim(),
      tags: tags,
      distance: distance,
      duration: duration,
    );

    final updatedRoute = await routeService.updateRoute(routeToUpdate);

    _routes = _routes
        .map((route) => route.id == routeId ? updatedRoute : route)
        .toList(growable: false);

    notifyListeners();
  }

  Future<void> createPointForRoute({
    required String routeId,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String image,
  }) async {
    final route = routeById(routeId);

    if (route == null) {
      throw StateError('Route not found.');
    }

    final createdPoint = await routeService.createPoint(
      routeId: routeId,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      image: image,
      index: route.points.length,
    );

    _routes = _routes.map((item) {
      if (item.id != routeId) return item;

      final points = [...item.points, createdPoint]
        ..sort((a, b) => a.index.compareTo(b.index));

      return item.copyWith(points: points);
    }).toList(growable: false);

    notifyListeners();
  }

  Future<void> updatePointForRoute({
    required String routeId,
    required RoutePointModel point,
  }) async {
    final updatedPoint = await routeService.updatePoint(point);

    _routes = _routes.map((route) {
      if (route.id != routeId) return route;

      final points = route.points
          .map((item) => item.id == updatedPoint.id ? updatedPoint : item)
          .toList(growable: false)
        ..sort((a, b) => a.index.compareTo(b.index));

      return route.copyWith(points: points);
    }).toList(growable: false);

    notifyListeners();
  }

  Future<void> deletePointFromRoute({
    required String routeId,
    required String pointId,
  }) async {
    await routeService.deletePoint(pointId);

    _routes = _routes.map((route) {
      if (route.id != routeId) return route;

      final points = route.points
          .where((point) => point.id != pointId)
          .toList(growable: false);

      return route.copyWith(points: points);
    }).toList(growable: false);

    notifyListeners();
  }

  Future<RouteModel> createRoute({
    required String name,
    required String description,
    required String coverImage,
    required RouteDifficulty difficulty,
    required String city,
    required String country,
    required List<String> tags,
    required double distance,
    required int duration,
    required List<RoutePointCreateInput> points,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw StateError('You need to log in to create routes.');
    }

    final createdRoute = await routeService.createRoute(
      RouteCreateInput(
        name: name,
        description: description,
        coverImage: coverImage,
        city: city,
        country: country,
        distance: distance,
        duration: duration,
        difficulty: difficulty,
        tags: tags,
        points: points,
      ),
    );

    _routes = <RouteModel>[createdRoute, ..._routes];
    notifyListeners();

    return createdRoute;
  }

  Future<void> toggleFavorite(String routeId) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('You need to log in to save favorites.');
    }

    final favoriteRoutes = user.favoriteRouteIds.contains(routeId)
        ? await profileService.removeFavoriteRouteByUserId(
            user.id,
            routeId,
            token: _sessionToken,
          )
        : await profileService.addFavoriteRouteByUserId(
            user.id,
            routeId,
            token: _sessionToken,
          );

    _currentUser = user.copyWith(
      favoriteRouteIds: favoriteRoutes.map((route) => route.id).toList(growable: false),
    );

    await saveStoredSessionUser(_currentUser!);
    notifyListeners();
  }

  Future<void> _loadRoutes() async {
    try {
      final homeData = await routeService.getHomeData();
      _routes = homeData.routes;
      _popularRouteIds = homeData.popularRouteIds;
    } catch (_) {
      _routes = <RouteModel>[];
      _popularRouteIds = <String>[];
    }
  }

  Future<void> _refreshCurrentUserFromApi() async {
    final user = _currentUser;
    final token = _sessionToken;

    if (user == null || token == null || token.trim().isEmpty) {
      return;
    }

    try {
      final refreshed = await profileService.getUserById(user.id, token: token);
      _currentUser = refreshed.copyWith(
        favoriteRouteIds: refreshed.favoriteRouteIds.isNotEmpty
            ? refreshed.favoriteRouteIds
            : user.favoriteRouteIds,
      );

      try {
        final favoriteRoutes = await profileService.getFavoriteRoutesByUserId(
          user.id,
          token: token,
        );
        _currentUser = _currentUser!.copyWith(
          favoriteRouteIds:
              favoriteRoutes.map((route) => route.id).toList(growable: false),
        );
      } catch (_) {}

      await saveStoredSessionUser(_currentUser!);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await logout();
      }
    } catch (_) {}
  }
}

extension RouteListX on List<RouteModel> {
  List<RouteModel> sortedBy(SortOption? option) => sortRoutes(this, option);
}