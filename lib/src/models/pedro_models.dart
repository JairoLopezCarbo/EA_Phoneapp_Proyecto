class PedroRoute {
  const PedroRoute({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.coverImage,
    this.description = '',
    this.difficulty,
    this.distance,
    this.duration,
    this.tags = const <String>[],
    this.score,
  });

  final String id;
  final String name;
  final String city;
  final String country;
  final String coverImage;
  final String description;
  final String? difficulty;
  final double? distance;
  final int? duration;
  final List<String> tags;
  final String? score;

  factory PedroRoute.fromJson(Map<String, dynamic> json) {
    final additional = json['_additional'];
    return PedroRoute(
      id:
          json['route_id']?.toString() ??
          json['routeId']?.toString() ??
          json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      coverImage:
          json['cover_image']?.toString() ??
          json['coverImage']?.toString() ??
          '',
      description: json['description']?.toString() ?? '',
      difficulty: json['difficulty']?.toString(),
      distance: (json['distance'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toInt(),
      tags: json['tags'] is List
          ? (json['tags'] as List)
                .map((item) => item.toString())
                .toList(growable: false)
          : const <String>[],
      score: additional is Map ? additional['score']?.toString() : null,
    );
  }
}

class PedroResponse {
  const PedroResponse({
    required this.answer,
    required this.routes,
    this.selectedRoute,
  });

  final String answer;
  final List<PedroRoute> routes;
  final PedroRoute? selectedRoute;

  factory PedroResponse.fromJson(Map<String, dynamic> json) {
    final answer = json['answer']?.toString().trim() ?? '';
    if (answer.isEmpty) {
      throw const FormatException('Pedro response does not contain an answer.');
    }

    final routes = json['routes'] is List
        ? (json['routes'] as List)
              .whereType<Map>()
              .map(
                (item) => PedroRoute.fromJson(Map<String, dynamic>.from(item)),
              )
              .where((route) => route.id.isNotEmpty)
              .toList(growable: false)
        : const <PedroRoute>[];

    final rawSelectedRoute = json['selectedRoute'];
    final selectedRoute = rawSelectedRoute is Map
        ? PedroRoute.fromJson(Map<String, dynamic>.from(rawSelectedRoute))
        : null;

    return PedroResponse(
      answer: answer,
      routes: routes,
      selectedRoute: selectedRoute?.id.isNotEmpty == true
          ? selectedRoute
          : null,
    );
  }
}

class PedroMessage {
  const PedroMessage.user(this.text)
    : isUser = true,
      response = null,
      isError = false;

  const PedroMessage.assistant(this.text, {this.response, this.isError = false})
    : isUser = false;

  final String text;
  final bool isUser;
  final PedroResponse? response;
  final bool isError;
}
