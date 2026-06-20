import '../models/app_models.dart';
import 'api_client.dart';

class RoutePageData {
  const RoutePageData({required this.routes, required this.pagination});

  final List<RouteModel> routes;
  final PaginationMeta pagination;
}

class HomeRoutesData {
  const HomeRoutesData({required this.routes, required this.popularRouteIds});

  final List<RouteModel> routes;
  final List<String> popularRouteIds;
}

class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;
}

class RouteService {
  const RouteService();

  Future<HomeRoutesData> getHomeData() async {
    final payload = await apiClient.getJson('/routes');
    return _parseHomeData(payload);
  }

  Future<RoutePageData> getRoutePage({
    required int page,
    required int limit,
  }) async {
    final payload = await apiClient.getJson('/routes?page=$page&limit=$limit');
    return _parseRoutePageData(payload, page: page, limit: limit);
  }

  Future<RouteModel?> getRouteById(String routeId) async {
    try {
      final payload = await apiClient.getJson(
        '/routes/${Uri.encodeComponent(routeId)}',
      );

      if (payload is Map<String, dynamic> &&
          payload['data'] is Map<String, dynamic>) {
        return RouteModel.fromApiJson(payload['data'] as Map<String, dynamic>);
      }

      if (payload is Map<String, dynamic>) {
        return RouteModel.fromApiJson(payload);
      }

      return null;
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }

  Future<List<RouteModel>> getRoutesInsidePolygon(
    List<List<double>> coordinates,
  ) async {
    final payload = await apiClient.postJson(
      '/routes/inside-polygon',
      body: <String, dynamic>{
        'coordinates': coordinates,
      },
    );

    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(RouteModel.fromApiJson)
          .toList(growable: false);
    }

    if (payload is Map<String, dynamic>) {
      final routes = payload['routes'] ?? payload['data'];

      if (routes is List) {
        return routes
            .whereType<Map<String, dynamic>>()
            .map(RouteModel.fromApiJson)
            .toList(growable: false);
      }
    }

    return const <RouteModel>[];
  }

  HomeRoutesData _parseHomeData(dynamic payload) {
    if (payload is List) {
      return HomeRoutesData(
        routes: payload
            .whereType<Map<String, dynamic>>()
            .map(RouteModel.fromApiJson)
            .toList(growable: false),
        popularRouteIds: const <String>[],
      );
    }

    if (payload is Map<String, dynamic>) {
      final routes = payload['routes'] ?? payload['data'];
      final popular = payload['popularRouteIds'];

      if (routes is List) {
        return HomeRoutesData(
          routes: routes
              .whereType<Map<String, dynamic>>()
              .map(RouteModel.fromApiJson)
              .toList(growable: false),
          popularRouteIds: popular is List
              ? popular
                  .map((item) => item.toString())
                  .where((item) => item.trim().isNotEmpty)
                  .toList(growable: false)
              : const <String>[],
        );
      }
    }

    return const HomeRoutesData(
      routes: <RouteModel>[],
      popularRouteIds: <String>[],
    );
  }

  RoutePageData _parseRoutePageData(
    dynamic payload, {
    required int page,
    required int limit,
  }) {
    if (payload is List) {
      final routes = payload
          .whereType<Map<String, dynamic>>()
          .map(RouteModel.fromApiJson)
          .toList(growable: false);

      return RoutePageData(
        routes: routes,
        pagination: PaginationMeta(
          page: page,
          limit: limit,
          total: routes.length,
          totalPages: 1,
        ),
      );
    }

    if (payload is Map<String, dynamic>) {
      final routes = payload['routes'] ?? payload['data'];
      final pagination = payload['pagination'];

      if (routes is List) {
        final parsedRoutes = routes
            .whereType<Map<String, dynamic>>()
            .map(RouteModel.fromApiJson)
            .toList(growable: false);

        final parsedPagination = pagination is Map<String, dynamic>
            ? PaginationMeta(
                page: pagination['page'] is num
                    ? (pagination['page'] as num).toInt()
                    : page,
                limit: pagination['limit'] is num
                    ? (pagination['limit'] as num).toInt()
                    : limit,
                total: pagination['total'] is num
                    ? (pagination['total'] as num).toInt()
                    : parsedRoutes.length,
                totalPages: pagination['totalPages'] is num
                    ? (pagination['totalPages'] as num).toInt()
                    : ((pagination['total'] is num
                              ? (pagination['total'] as num).toInt()
                              : parsedRoutes.length) /
                          limit)
                        .ceil()
                        .clamp(1, 999999),
              )
            : PaginationMeta(
                page: page,
                limit: limit,
                total: parsedRoutes.length,
                totalPages: 1,
              );

        return RoutePageData(
          routes: parsedRoutes,
          pagination: parsedPagination,
        );
      }
    }

    return RoutePageData(
      routes: const <RouteModel>[],
      pagination: PaginationMeta(
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
      ),
    );
  }

  Future<RouteModel> createRoute(RouteCreateInput input) async {
    final payload = await apiClient.postJson(
      '/routes',
      body: input.toJson(),
    );

    if (payload is Map<String, dynamic> &&
        payload['data'] is Map<String, dynamic>) {
      return RouteModel.fromApiJson(payload['data'] as Map<String, dynamic>);
    }

    if (payload is Map<String, dynamic>) {
      return RouteModel.fromApiJson(payload);
    }

    throw StateError('Unable to read created route from the server.');
  }

  Future<RouteModel> updateRoute(RouteModel route) async {
    final body = <String, dynamic>{
      'name': route.name.trim(),
      'description': route.description.trim(),
      'cover_image': route.coverImage.trim(),
      'images': route.images,
      'difficulty': route.difficulty.value,
      'city': route.city.trim(),
      'country': route.country.trim(),
      'distance': route.distance,
      'duration': route.duration,
      'tags': route.tags,
    };

    final payload = await apiClient.putJson(
      '/routes/${Uri.encodeComponent(route.id)}',
      body: body,
    );

    if (payload is Map<String, dynamic> &&
        payload['data'] is Map<String, dynamic>) {
      return RouteModel.fromApiJson(payload['data'] as Map<String, dynamic>);
    }

    if (payload is Map<String, dynamic>) {
      return RouteModel.fromApiJson(payload);
    }

    throw StateError('Unable to read updated route from the server.');
  }

  Future<RoutePointModel> createPoint({
    required String routeId,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String image,
    required int index,
  }) async {
    final payload = await apiClient.postJson(
      '/points',
      body: <String, dynamic>{
        'routeId': routeId,
        'name': name.trim(),
        'description': description.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'image': image.trim(),
        'index': index,
      },
    );

    if (payload is Map<String, dynamic> &&
        payload['data'] is Map<String, dynamic>) {
      return RoutePointModel.fromJson(payload['data'] as Map<String, dynamic>);
    }

    if (payload is Map<String, dynamic>) {
      return RoutePointModel.fromJson(payload);
    }

    throw StateError('Unable to read created point from the server.');
  }

  Future<RoutePointModel> updatePoint(RoutePointModel point) async {
    final payload = await apiClient.putJson(
      '/points/${Uri.encodeComponent(point.id)}',
      body: point.toApiJson(),
    );

    if (payload is Map<String, dynamic> &&
        payload['data'] is Map<String, dynamic>) {
      return RoutePointModel.fromJson(payload['data'] as Map<String, dynamic>);
    }

    if (payload is Map<String, dynamic>) {
      return RoutePointModel.fromJson(payload);
    }

    throw StateError('Unable to read updated point from the server.');
  }

  Future<void> deletePoint(String pointId) async {
    await apiClient.deleteJson('/points/${Uri.encodeComponent(pointId)}');
  }
}

const RouteService routeService = RouteService();