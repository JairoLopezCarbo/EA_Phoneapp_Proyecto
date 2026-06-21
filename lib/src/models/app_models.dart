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

class RoutePointModel {
  const RoutePointModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.routeId,
    required this.index,
    this.description,
    this.image,
  });

  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? image;
  final String routeId;
  final int index;

  RoutePointModel copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? image,
    String? routeId,
    int? index,
  }) {
    return RoutePointModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      image: image ?? this.image,
      routeId: routeId ?? this.routeId,
      index: index ?? this.index,
    );
  }

  factory RoutePointModel.fromJson(Map<String, dynamic> json) {
    return RoutePointModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      image: json['image']?.toString(),
      routeId: json['routeId']?.toString() ?? '',
      index: (json['index'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toApiJson() {
    return <String, dynamic>{
      'name': name.trim(),
      'description': description?.trim() ?? '',
      'latitude': latitude,
      'longitude': longitude,
      'image': image?.trim() ?? '',
      'routeId': routeId,
      'index': index,
    };
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
    required this.wheelchairAccessible,
    required this.tags,
    required this.points,
    this.cityImage,
    this.distance,
    this.duration,
    this.ratingAverage,
    this.reviewsCount,
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
  final bool wheelchairAccessible;
  final double? distance;
  final int? duration;
  final double? ratingAverage;
  final int? reviewsCount;
  final String? cityImage;
  final List<String> tags;
  final List<RoutePointModel> points;

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
    bool? wheelchairAccessible,
    double? distance,
    int? duration,
    double? ratingAverage,
    int? reviewsCount,
    String? cityImage,
    List<String>? tags,
    List<RoutePointModel>? points,
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
      wheelchairAccessible: wheelchairAccessible ?? this.wheelchairAccessible,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      cityImage: cityImage ?? this.cityImage,
      tags: tags ?? this.tags,
      points: points ?? this.points,
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
    'wheelchairAccessible': wheelchairAccessible,
    'distance': distance,
    'duration': duration,
    'ratingAverage': ratingAverage,
    'reviewsCount': reviewsCount,
    'cityImage': cityImage,
    'tags': tags,
    'points': points.map((point) => point.toApiJson()).toList(),
  };

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toList(growable: false);

    final points =
        (json['points'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) =>
                  RoutePointModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false)
          ..sort((a, b) => a.index.compareTo(b.index));

    return RouteModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverImage:
          json['coverImage']?.toString() ??
          json['cover_image']?.toString() ??
          (images.isNotEmpty ? images.first : ''),
      images: images,
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      difficulty: RouteDifficultyX.fromValue(json['difficulty']?.toString()),
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      wheelchairAccessible: json['wheelchairAccessible'] == true,
      distance: (json['distance'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toInt(),
      ratingAverage: (json['ratingAverage'] as num?)?.toDouble(),
      reviewsCount: (json['reviewsCount'] as num?)?.toInt(),
      cityImage:
          json['cityImage']?.toString() ?? json['city_image']?.toString(),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(growable: false),
      points: points,
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
      'wheelchairAccessible': json['wheelchairAccessible'],
      'distance': json['distance'],
      'duration': json['duration'],
      'ratingAverage': json['ratingAverage'],
      'reviewsCount': json['reviewsCount'],
      'city_image': json['city_image'] ?? json['cityImage'],
      'tags': json['tags'],
      'points': json['points'] ?? const [],
    });
  }

  static List<RouteModel> decodeList(String value) {
    final decoded = jsonDecode(value) as List<dynamic>;
    return decoded
        .map((item) => RouteModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static String encodeList(List<RouteModel> routes) {
    return jsonEncode(
      routes.map((route) => route.toJson()).toList(growable: false),
    );
  }
}

class RoutePointCreateInput {
  const RoutePointCreateInput({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.index,
    this.description,
    this.image,
  });

  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? image;
  final int index;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name.trim(),
    if (description != null && description!.trim().isNotEmpty)
      'description': description!.trim(),
    'latitude': latitude,
    'longitude': longitude,
    if (image != null && image!.trim().isNotEmpty) 'image': image!.trim(),
    'index': index,
  };
}

class RouteCreateInput {
  const RouteCreateInput({
    required this.name,
    required this.description,
    required this.coverImage,
    required this.city,
    required this.country,
    required this.distance,
    required this.duration,
    required this.difficulty,
    required this.wheelchairAccessible,
    required this.tags,
    required this.points,
  });

  final String name;
  final String description;
  final String coverImage;
  final String city;
  final String country;
  final double distance;
  final int duration;
  final RouteDifficulty difficulty;
  final bool wheelchairAccessible;
  final List<String> tags;
  final List<RoutePointCreateInput> points;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name.trim(),
    'description': description.trim(),
    'cover_image': coverImage.trim(),
    'city': city.trim(),
    'country': country.trim(),
    'distance': distance,
    'duration': duration,
    'difficulty': difficulty.value,
    'wheelchairAccessible': wheelchairAccessible,
    'tags': tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(),
    'points': points.map((point) => point.toJson()).toList(),
  };
}

class ReviewRating {
  const ReviewRating({required this.label, required this.score});

  final String label;
  final double score;

  factory ReviewRating.fromJson(Map<String, dynamic> json) {
    return ReviewRating(
      label: json['label']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'score': score};
  }
}

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.title,
    required this.ratings,
    required this.averageRating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String routeId;
  final String userId;
  final String title;
  final String? comment;
  final List<ReviewRating> ratings;
  final double averageRating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final ratings = (json['ratings'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => ReviewRating.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final ratingsAverage = ratings.isEmpty
        ? 0.0
        : ratings.fold<double>(0, (sum, rating) => sum + rating.score) /
              ratings.length;
    final apiAverage = (json['averageRating'] as num?)?.toDouble();

    return ReviewModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      routeId: json['routeId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      comment: json['comment']?.toString(),
      ratings: ratings,
      averageRating:
          apiAverage != null && (apiAverage > 0 || ratingsAverage == 0)
          ? apiAverage
          : ratingsAverage,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

class ReviewCreateInput {
  const ReviewCreateInput({
    required this.routeId,
    required this.title,
    required this.ratings,
    this.comment,
  });

  final String routeId;
  final String title;
  final String? comment;
  final List<ReviewRating> ratings;

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'title': title.trim(),
      if (comment != null && comment!.trim().isNotEmpty)
        'comment': comment!.trim(),
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
    };
  }
}

class ReviewUpdateInput {
  const ReviewUpdateInput({
    required this.title,
    required this.ratings,
    this.comment,
  });

  final String title;
  final String? comment;
  final List<ReviewRating> ratings;

  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'comment': comment?.trim() ?? '',
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
    };
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
    final favoriteRoutes =
        (json['favoriteRouteIds'] as List<dynamic>? ??
        json['favoriteRoutes'] as List<dynamic>? ??
        const []);

    return AppUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      surname: json['surname']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      favoriteRouteIds: favoriteRoutes
          .map((value) => value.toString())
          .toList(growable: false),
      enabled: json['enabled'] as bool? ?? true,
      role: json['role']?.toString() ?? 'user',
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
          final id = item['_id']?.toString() ?? item['id']?.toString() ?? '';
          if (id.trim().isNotEmpty) {
            favoriteRouteIds.add(id.trim());
          }
        }
      }
    }

    return AppUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      surname: json['surname']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      favoriteRouteIds: favoriteRouteIds,
      enabled: json['enabled'] as bool? ?? true,
      role: json['role']?.toString() ?? 'user',
    );
  }

  static List<AppUser> decodeList(String value) {
    final decoded = jsonDecode(value) as List<dynamic>;
    return decoded
        .map((item) => AppUser.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static String encodeList(List<AppUser> users) {
    return jsonEncode(
      users.map((user) => user.toJson()).toList(growable: false),
    );
  }
}

class HomeRoutesData {
  const HomeRoutesData({required this.routes, required this.popularRouteIds});

  final List<RouteModel> routes;
  final List<String> popularRouteIds;
}

class ChatSummary {
  const ChatSummary({
    required this.id,
    required this.name,
    required this.hasPassword,
  });

  final String id;
  final String name;
  final bool hasPassword;

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Chat',
      hasPassword:
          (json['hasPassword'] as bool?) ??
          (json['passwordProtected'] as bool?) ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'hasPassword': hasPassword};
  }
}

class ChatParticipant {
  const ChatParticipant({
    required this.id,
    required this.name,
    required this.username,
    this.email = '',
  });

  final String id;
  final String name;
  final String username;
  final String email;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username:
          json['username']?.toString() ?? json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'username': username, 'email': email};
  }
}

class ChatHistoryMessage {
  const ChatHistoryMessage({
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  final dynamic userId;
  final String message;
  final String timestamp;

  factory ChatHistoryMessage.fromJson(Map<String, dynamic> json) {
    return ChatHistoryMessage(
      userId: json['userId'] ?? json['user'] ?? json['author'],
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  factory ChatHistoryMessage.fromSocket(Map<String, dynamic> json) {
    return ChatHistoryMessage(
      userId: json['username']?.toString() ?? 'Unknown',
      message: json['message']?.toString() ?? '',
      timestamp:
          json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'message': message, 'timestamp': timestamp};
  }

  ChatParticipant get author {
    final raw = userId;

    if (raw is ChatParticipant) {
      return raw;
    }

    if (raw is Map<String, dynamic>) {
      return ChatParticipant.fromJson(raw);
    }

    if (raw is Map) {
      return ChatParticipant.fromJson(Map<String, dynamic>.from(raw));
    }

    final value = raw?.toString() ?? 'Unknown';

    return ChatParticipant(id: value, name: value, username: value);
  }
}

class ChatDetail {
  const ChatDetail({
    required this.id,
    required this.name,
    required this.participants,
    required this.chatHistory,
    this.hasPassword = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final bool hasPassword;
  final List<ChatParticipant> participants;
  final List<ChatHistoryMessage> chatHistory;
  final String? createdAt;
  final String? updatedAt;

  factory ChatDetail.fromJson(Map<String, dynamic> json) {
    final participants = (json['participants'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => ChatParticipant.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    final chatHistory = (json['chatHistory'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              ChatHistoryMessage.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return ChatDetail(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Chat',
      hasPassword:
          (json['hasPassword'] as bool?) ??
          (json['passwordProtected'] as bool?) ??
          false,
      participants: participants,
      chatHistory: chatHistory,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'hasPassword': hasPassword,
      'participants': participants.map((p) => p.toJson()).toList(),
      'chatHistory': chatHistory.map((m) => m.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ChatMessageEvent {
  const ChatMessageEvent({
    required this.chatId,
    required this.username,
    required this.message,
    required this.timestamp,
  });

  final String chatId;
  final String username;
  final String message;
  final String timestamp;

  factory ChatMessageEvent.fromJson(Map<String, dynamic> json) {
    return ChatMessageEvent(
      chatId: json['chat_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timestamp:
          json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

class ChatParticipantsEvent {
  const ChatParticipantsEvent({
    required this.chatId,
    required this.participants,
    required this.count,
    required this.timestamp,
  });

  final String chatId;
  final List<String> participants;
  final int count;
  final String timestamp;

  factory ChatParticipantsEvent.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'];

    return ChatParticipantsEvent(
      chatId: json['chat_id']?.toString() ?? '',
      participants: rawParticipants is List
          ? rawParticipants
                .map((item) => item.toString())
                .toList(growable: false)
          : const [],
      count: json['count'] is int ? json['count'] as int : 0,
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }
}

class Achievement {
  const Achievement({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedAt,
  });

  final String id;
  final String code;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedAt;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['_id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      unlocked: json['unlocked'] == true,
      unlockedAt: json['unlockedAt'] is String
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
    );
  }
}
