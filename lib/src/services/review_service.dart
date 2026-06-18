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

  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    final payload = await apiClient.getJson(
      '/reviews?userId=${Uri.encodeQueryComponent(userId)}',
    );

    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item)))
          .where((review) => review.userId == userId)
          .toList(growable: false);
    }

    if (payload is Map<String, dynamic> && payload['data'] is List) {
      return (payload['data'] as List)
          .whereType<Map>()
          .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item)))
          .where((review) => review.userId == userId)
          .toList(growable: false);
    }

    return const <ReviewModel>[];
  }

  Future<ReviewModel> createReview(ReviewCreateInput input) async {
    final payload = await apiClient.postJson('/reviews', body: input.toJson());

    if (payload is Map<String, dynamic> &&
        payload['data'] is Map<String, dynamic>) {
      return ReviewModel.fromJson(payload['data'] as Map<String, dynamic>);
    }

    if (payload is Map<String, dynamic>) {
      return ReviewModel.fromJson(payload);
    }

    throw StateError('Unable to read created review from the server.');
  }

  Future<ReviewModel> updateReview(
    String reviewId,
    ReviewUpdateInput input,
  ) async {
    final payload = await apiClient.putJson(
      '/reviews/${Uri.encodeComponent(reviewId)}',
      body: input.toJson(),
    );

    if (payload is Map<String, dynamic> &&
        payload['data'] is Map<String, dynamic>) {
      return ReviewModel.fromJson(payload['data'] as Map<String, dynamic>);
    }

    if (payload is Map<String, dynamic>) {
      return ReviewModel.fromJson(payload);
    }

    throw StateError('Unable to read updated review from the server.');
  }

  Future<void> deleteReview(String reviewId) async {
    await apiClient.deleteJson('/reviews/${Uri.encodeComponent(reviewId)}');
  }
}

const ReviewService reviewService = ReviewService();
