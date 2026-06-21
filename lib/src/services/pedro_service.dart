import '../models/pedro_models.dart';
import 'api_client.dart';

class PedroService {
  const PedroService({required this.apiClient});

  final ApiClient apiClient;

  Future<PedroResponse> recommend(String question) async {
    final payload = await apiClient.postJson(
      '/ia/recommend',
      includeStoredAuth: false,
      body: <String, dynamic>{'question': question.trim(), 'limit': 5},
    );

    if (payload is! Map) {
      throw const FormatException('Pedro returned invalid JSON.');
    }

    return PedroResponse.fromJson(Map<String, dynamic>.from(payload));
  }
}

final PedroService pedroService = PedroService(apiClient: apiClient);
