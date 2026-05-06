import 'dart:convert';

enum AuthMode { login, register }

enum RouteDifficulty { easy, medium, hard }

extension RouteDifficultyX on RouteDifficulty {
  String get value => switch (this) {
        RouteDifficulty.easy => 'easy',
        RouteDifficulty.medium => 'medium',
        RouteDifficulty.hard => 'hard',
      };

  String get title => value[0].toUpperCase() + value.substring(1);

  int get rank => switch (this) {
        RouteDifficulty.easy => 1,
        RouteDifficulty.medium => 2,
        RouteDifficulty.hard => 3,
      };

  static RouteDifficulty fromValue(String? value) {
    switch (value) {
      case 'easy':
        return RouteDifficulty.easy;
      case 'hard':
        return RouteDifficulty.hard;
      case 'medium':
      default:
        return RouteDifficulty.medium;
    }
  }
}

class RouteModel {
  const RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.images,
    required this.userId,
    required this.difficulty,
    required this.city,
    required this.country,
    required this.tags,
    this.cityImage,
    this.distance,
    this.duration,
  });

  final String id;
  final String name;
  final String description;
  final String coverImage;
  final List<String> images;
  final String userId;
  final RouteDifficulty difficulty;
  final String city;
  final String country;
  final double? distance;
  final int? duration;
  final String? cityImage;
  final List<String> tags;

  String get locationLabel => '$city, $country';

  String get firstImage => images.isNotEmpty ? images.first : coverImage;

  RouteModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImage,
    List<String>? images,
    String? userId,
    RouteDifficulty? difficulty,
    String? city,
    String? country,
    double? distance,
    int? duration,
    String? cityImage,
    List<String>? tags,
  }) {
    return RouteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      images: images ?? this.images,
      userId: userId ?? this.userId,
      difficulty: difficulty ?? this.difficulty,
      city: city ?? this.city,
      country: country ?? this.country,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      cityImage: cityImage ?? this.cityImage,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
        'coverImage': coverImage,
        'images': images,
        'userId': userId,
        'difficulty': difficulty.value,
        'city': city,
        'country': country,
        'distance': distance,
        'duration': duration,
        'cityImage': cityImage,
        'tags': tags,
      };

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toList(growable: false);

    return RouteModel(
      id: (json['id'] as String?) ?? (json['_id'] as String?) ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coverImage: (json['coverImage'] as String?) ?? (json['cover_image'] as String?) ?? (images.isNotEmpty ? images.first : ''),
      images: images,
      userId: (json['userId'] as String?) ?? (json['user_id'] as String?) ?? '',
      difficulty: RouteDifficultyX.fromValue(json['difficulty'] as String?),
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      distance: (json['distance'] as num?)?.toDouble(),
      duration: json['duration'] as int?,
      cityImage: (json['cityImage'] as String?) ?? (json['city_image'] as String?),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(growable: false),
    );
  }

  factory RouteModel.fromApiJson(Map<String, dynamic> json) {
    return RouteModel.fromJson(<String, dynamic>{
      'id': json['_id'] ?? json['id'],
      'name': json['name'],
      'description': json['description'],
      'cover_image': json['cover_image'] ?? json['coverImage'],
      'images': json['images'] ?? const [],
      'userId': json['userId'] ?? json['user_id'],
      'difficulty': json['difficulty'],
      'city': json['city'],
      'country': json['country'],
      'distance': json['distance'],
      'duration': json['duration'],
      'city_image': json['city_image'] ?? json['cityImage'],
      'tags': json['tags'],
    });
  }

  static List<RouteModel> decodeList(String value) {
    final decoded = jsonDecode(value) as List<dynamic>;
    return decoded
        .map((item) => RouteModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static String encodeList(List<RouteModel> routes) {
    return jsonEncode(routes.map((route) => route.toJson()).toList(growable: false));
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.surname,
    required this.username,
    required this.email,
    required this.password,
    required this.favoriteRouteIds,
    this.enabled = true,
    this.role = 'user',
  });

  final String id;
  final String name;
  final String surname;
  final String username;
  final String email;
  final String password;
  final List<String> favoriteRouteIds;
  final bool enabled;
  final String role;

  AppUser copyWith({
    String? id,
    String? name,
    String? surname,
    String? username,
    String? email,
    String? password,
    List<String>? favoriteRouteIds,
    bool? enabled,
    String? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      favoriteRouteIds: favoriteRouteIds ?? this.favoriteRouteIds,
      enabled: enabled ?? this.enabled,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'surname': surname,
        'username': username,
        'email': email,
        'password': password,
        'favoriteRouteIds': favoriteRouteIds,
        'enabled': enabled,
        'role': role,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final favoriteRoutes = (json['favoriteRouteIds'] as List<dynamic>? ?? json['favoriteRoutes'] as List<dynamic>? ?? const []);

    return AppUser(
      id: (json['id'] as String?) ?? (json['_id'] as String?) ?? '',
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      favoriteRouteIds: favoriteRoutes
          .map((value) => value.toString())
          .toList(growable: false),
      enabled: json['enabled'] as bool? ?? true,
      role: json['role'] as String? ?? 'user',
    );
  }

  factory AppUser.fromApiJson(Map<String, dynamic> json) {
    final favoriteRoutes = json['favoriteRoutes'] ?? json['favoriteRouteIds'];
    final favoriteRouteIds = <String>[];

    if (favoriteRoutes is List) {
      for (final item in favoriteRoutes) {
        if (item is String) {
          if (item.trim().isNotEmpty) {
            favoriteRouteIds.add(item.trim());
          }
          continue;
        }

        if (item is Map<String, dynamic>) {
          final id = (item['_id'] as String?) ?? (item['id'] as String?) ?? '';
          if (id.trim().isNotEmpty) {
            favoriteRouteIds.add(id.trim());
          }
        }
      }
    }

    return AppUser(
      id: (json['id'] as String?) ?? (json['_id'] as String?) ?? '',
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      favoriteRouteIds: favoriteRouteIds,
      enabled: json['enabled'] as bool? ?? true,
      role: json['role'] as String? ?? 'user',
    );
  }

  static List<AppUser> decodeList(String value) {
    final decoded = jsonDecode(value) as List<dynamic>;
    return decoded
        .map((item) => AppUser.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static String encodeList(List<AppUser> users) {
    return jsonEncode(users.map((user) => user.toJson()).toList(growable: false));
  }
}

class HomeRoutesData {
  const HomeRoutesData({required this.routes, required this.popularRouteIds});

  final List<RouteModel> routes;
  final List<String> popularRouteIds;
}
