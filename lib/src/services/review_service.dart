import '../models/app_models.dart';
import 'api_client.dart';

class ReviewService {
  const ReviewService();

  Future<List<ReviewModel>> getReviewsByRoute(String routeId) async {
    final payload = await apiClient.getJson(
      '/reviews?routeId=${Uri.encodeQueryComponent(routeId)}',
    );

    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }

    if (payload is Map<String, dynamic> && payload['data'] is List) {
      return (payload['data'] as List)
          .whereType<Map>()
          .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }

    return const <ReviewModel>[];
  }

  Future<ReviewModel> createReview(ReviewCreateInput input) async {
    final payload = await apiClient.postJson(
      '/reviews',
      body: input.toJson(),
    );

    if (payload is Map<String, dynamic> && payload['data'] is Map<String, dynamic>) {
      return ReviewModel.fromJson(payload['data'] as Map<String, dynamic>);
    }

    if (payload is Map<String, dynamic>) {
      return ReviewModel.fromJson(payload);
    }

    throw StateError('Unable to read created review from the server.');
  }
}

const ReviewService reviewService = ReviewService();