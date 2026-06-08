import '../models/app_models.dart';
import 'api_client.dart';

class AchievementService {
  Future<List<Achievement>> getMyAchievements() async {
    final response = await apiClient.getJson('/achievements/me');

    final dynamic data = response is Map<String, dynamic>
        ? response['data']
        : response;

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map((item) => Achievement.fromJson(Map<String, dynamic>.from(item)))
        .where((achievement) => achievement.code.isNotEmpty)
        .toList();
  }
}

final achievementService = AchievementService();
