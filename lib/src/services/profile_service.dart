import '../models/app_models.dart';
import 'api_client.dart';

class UpdateUserPayload {
  const UpdateUserPayload({
    required this.name,
    required this.surname,
    required this.username,
    required this.email,
    this.password,
    required this.enabled,
    required this.role,
  });

  final String name;
  final String surname;
  final String username;
  final String email;
  final String? password;
  final bool enabled;
  final String role;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'surname': surname,
        'username': username,
        'email': email,
        if (password != null && password!.trim().isNotEmpty) 'password': password,
        'enabled': enabled,
        'role': role,
      };
}

class UpdateRoutePayload {
  const UpdateRoutePayload({
    required this.name,
    required this.description,
    required this.coverImage,
    required this.images,
    required this.userId,
    required this.difficulty,
    required this.city,
    required this.country,
    required this.tags,
    this.distance,
    this.duration,
  });

  final String name;
  final String description;
  final String coverImage;
  final List<String> images;
  final String userId;
  final RouteDifficulty difficulty;
  final String city;
  final String country;
  final List<String> tags;
  final double? distance;
  final int? duration;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'description': description,
        'cover_image': coverImage,
        'images': images,
        'userId': userId,
        'difficulty': difficulty.value,
        'city': city,
        'country': country,
        if (distance != null) 'distance': distance,
        if (duration != null) 'duration': duration,
        'tags': tags,
      };
}

class ProfileService {
  const ProfileService();

  Future<AppUser> getUserById(String userId, {String? token}) async {
    final payload = await apiClient.getJson('/users/${Uri.encodeComponent(userId)}', token: token);
    return _parseUser(payload);
  }

  Future<AppUser> updateUserById(String userId, UpdateUserPayload payload, {String? token}) async {
    final response = await apiClient.putJson('/users/${Uri.encodeComponent(userId)}', token: token, body: payload.toJson());
    return _parseUser(response);
  }

  Future<List<RouteModel>> getRoutesByUserId(String userId, {String? token}) async {
    final payload = await apiClient.getJson('/routes?filter[userId]=${Uri.encodeComponent(userId)}', token: token);
    return _parseRoutes(payload);
  }

  Future<RouteModel> updateRouteById(String routeId, UpdateRoutePayload payload, {String? token}) async {
    final response = await apiClient.putJson('/routes/${Uri.encodeComponent(routeId)}', token: token, body: payload.toJson());
    final route = _parseRoute(response);
    if (route == null) {
      throw ApiException('Invalid route response from server.');
    }

    return route;
  }

  Future<List<RouteModel>> getFavoriteRoutesByUserId(String userId, {String? token}) async {
    final payload = await apiClient.getJson('/users/${Uri.encodeComponent(userId)}/favorites', token: token);
    return _parseRoutes(payload);
  }

  Future<List<RouteModel>> addFavoriteRouteByUserId(String userId, String routeId, {String? token}) async {
    final payload = await apiClient.postJson('/users/${Uri.encodeComponent(userId)}/favorites/${Uri.encodeComponent(routeId)}', token: token);
    return _parseRoutes(payload);
  }

  Future<List<RouteModel>> removeFavoriteRouteByUserId(String userId, String routeId, {String? token}) async {
    final payload = await apiClient.deleteJson('/users/${Uri.encodeComponent(userId)}/favorites/${Uri.encodeComponent(routeId)}', token: token);
    return _parseRoutes(payload);
  }

  AppUser _parseUser(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['data'] is Map<String, dynamic>) {
      return AppUser.fromApiJson(payload['data'] as Map<String, dynamic>);
    }

    if (payload is Map<String, dynamic>) {
      return AppUser.fromApiJson(payload);
    }

    throw ApiException('Unable to load the user.');
  }

  RouteModel? _parseRoute(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['data'] is Map<String, dynamic>) {
      return RouteModel.fromApiJson(payload['data'] as Map<String, dynamic>);
    }

    if (payload is Map<String, dynamic>) {
      return RouteModel.fromApiJson(payload);
    }

    return null;
  }

  List<RouteModel> _parseRoutes(dynamic payload) {
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().map(RouteModel.fromApiJson).toList(growable: false);
    }

    if (payload is Map<String, dynamic>) {
      final routes = payload['routes'] ?? payload['data'];
      if (routes is List) {
        return routes.whereType<Map<String, dynamic>>().map(RouteModel.fromApiJson).toList(growable: false);
      }
    }

    return const <RouteModel>[];
  }
}

const ProfileService profileService = ProfileService();