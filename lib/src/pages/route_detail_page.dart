import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../services/review_service.dart';
import '../state/accessibility_state.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';
import '../utils/formatters.dart';

class RouteDetailPage extends StatelessWidget {
  const RouteDetailPage({
    super.key,
    required this.routeId,
    required this.onBack,
    required this.onOpenAuth,
  });

  final String routeId;
  final VoidCallback onBack;
  final ValueChanged<AuthMode> onOpenAuth;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final route = appState.routeById(routeId);

    return route == null
        ? Center(
            child: Text(
              'Route not found.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RouteHero(route: route),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DifficultyChip(difficulty: route.difficulty),
                      const SizedBox(height: 14),
                      _QuickFacts(
                        distance: route.distance,
                        duration: route.duration,
                      ),
                      const SizedBox(height: 14),
                      _PanelCard(
                        title: 'About this route',
                        child: Text(
                          route.description,
                          style: TextStyle(
                            height: context
                                    .watch<AccessibilityState>()
                                    .lineHeight ??
                                1.55,
                            fontSize: 14,
                            color: context
                                .watch<AccessibilityState>()
                                .secondaryTextColor,
                            wordSpacing: context
                                .watch<AccessibilityState>()
                                .wordSpacingValue,
                            letterSpacing: context
                                .watch<AccessibilityState>()
                                .letterSpacingValue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (route.tags.isNotEmpty) ...[
                        _PanelCard(
                          title: 'Route tags',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (
                                var index = 0;
                                index < route.tags.length;
                                index++
                              )
                                _TagPill(
                                  index: index + 1,
                                  label: route.tags[index],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _PanelCard(
                        title: 'Reviews',
                        child: _ReviewsSection(
                          routeId: route.id,
                          isAuthenticated: appState.isAuthenticated,
                          onOpenAuth: onOpenAuth,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PanelCard(
                        title: 'Route gallery',
                        child: _Gallery(
                          routeName: route.name,
                          images: [route.coverImage, ...route.images],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PanelCard(
                        title: 'Quick actions',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (!appState.isAuthenticated) {
                                  onOpenAuth(AuthMode.login);
                                  return;
                                }

                                await appState.toggleFavorite(route.id);
                              },
                              icon: Icon(
                                appState.currentUser?.favoriteRouteIds.contains(
                                          route.id,
                                        ) ??
                                        false
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                              ),
                              label: Text(
                                appState.currentUser?.favoriteRouteIds.contains(
                                          route.id,
                                        ) ??
                                        false
                                    ? 'Saved to favorites'
                                    : 'Save to favorites',
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: onBack,
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('Back'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

class _RouteHero extends StatelessWidget {
  const _RouteHero({required this.route});

  final RouteModel route;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: Image.network(
            route.coverImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F1E30), Color(0xFF1B2330)],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                route.locationLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF0FAFF),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (route.distance != null)
                    _MetaPill(label: '${route.distance} km'),
                  if (route.duration != null)
                    _MetaPill(label: '${route.duration} min'),
                  ...route.tags.map((tag) => _MetaPill(label: tag)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.difficulty});

  final RouteDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accessibility.surfaceColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accessibility.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: accessibility.textColor),
            const SizedBox(width: 6),
            Text(
              difficulty.title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: accessibility.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFacts extends StatelessWidget {
  const _QuickFacts({this.distance, this.duration});

  final double? distance;
  final int? duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FactCard(label: 'Distance', value: formatDistance(distance)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FactCard(label: 'Duration', value: formatDuration(duration)),
        ),
      ],
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accessibility.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accessibility.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accessibility.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: accessibility.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accessibility.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accessibility.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: accessibility.textColor,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.index, required this.label});

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accessibility.secondarySurfaceColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accessibility.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accessibility.buttonColor,
            ),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: TextStyle(
                color: accessibility.buttonTextColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: accessibility.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.routeName, required this.images});

  final String routeName;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final uniqueImages = <String>[];

    for (final image in images) {
      if (image.isEmpty || uniqueImages.contains(image)) {
        continue;
      }

      uniqueImages.add(image);
    }

    if (uniqueImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: uniqueImages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 180,
              height: 140,
              child: Image.network(
                uniqueImages[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.surfaceMuted,
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReviewsSection extends StatefulWidget {
  const _ReviewsSection({
    required this.routeId,
    required this.isAuthenticated,
    required this.onOpenAuth,
  });

  final String routeId;
  final bool isAuthenticated;
  final ValueChanged<AuthMode> onOpenAuth;

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  final Map<String, double> _ratings = {
    'scenery': 5,
    'signage': 5,
    'accessibility': 5,
    'safety': 5,
  };

  List<ReviewModel> _reviews = const <ReviewModel>[];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _error = '';
  String _success = '';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void didUpdateWidget(covariant _ReviewsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.routeId != widget.routeId) {
      _loadReviews();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _success = '';
    });

    try {
      final reviews = await reviewService.getReviewsByRoute(widget.routeId);

      if (!mounted) {
        return;
      }

      setState(() {
        _reviews = reviews;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double get _averageRating {
    final allRatings = _reviews.expand((review) => review.ratings).toList();

    if (allRatings.isEmpty) {
      return 0;
    }

    final total = allRatings.fold<double>(
      0,
      (sum, rating) => sum + rating.score,
    );

    return total / allRatings.length;
  }

  Future<void> _submitReview() async {
    final title = _titleController.text.trim();
    final comment = _commentController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _error = 'Please add a review title.';
        _success = '';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = '';
      _success = '';
    });

    try {
      final createdReview = await reviewService.createReview(
        ReviewCreateInput(
          routeId: widget.routeId,
          title: title,
          comment: comment.isEmpty ? null : comment,
          ratings: _ratings.entries
              .map(
                (entry) => ReviewRating(
                  label: entry.key,
                  score: entry.value,
                ),
              )
              .toList(growable: false),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _reviews = [createdReview, ..._reviews];
        _titleController.clear();
        _commentController.clear();
        _ratings.updateAll((key, value) => 5);
        _success = 'Review published successfully.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    if (_isLoading) {
      return Text(
        'Loading reviews...',
        style: TextStyle(color: accessibility.secondaryTextColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_reviews.isEmpty)
          Text(
            'No reviews yet.',
            style: TextStyle(color: accessibility.secondaryTextColor),
          )
        else
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFB020), size: 20),
              const SizedBox(width: 6),
              Text(
                '${_averageRating.toStringAsFixed(1)} / 5',
                style: TextStyle(
                  color: accessibility.textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_reviews.length} reviews)',
                style: TextStyle(color: accessibility.secondaryTextColor),
              ),
            ],
          ),
        const SizedBox(height: 14),
        if (widget.isAuthenticated)
          _ReviewForm(
            titleController: _titleController,
            commentController: _commentController,
            ratings: _ratings,
            isSubmitting: _isSubmitting,
            onRatingChanged: (label, value) {
              setState(() {
                _ratings[label] = value;
              });
            },
            onSubmit: _submitReview,
          )
        else
          OutlinedButton.icon(
            onPressed: () => widget.onOpenAuth(AuthMode.login),
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Log in to publish a review'),
          ),
        if (_success.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            _success,
            style: const TextStyle(
              color: Color(0xFF1F8C77),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            _error,
            style: const TextStyle(
              color: Color(0xFFB42318),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (_reviews.isNotEmpty) ...[
          const SizedBox(height: 14),
          ..._reviews.map((review) => _ReviewCard(review: review)),
        ],
      ],
    );
  }
}

class _ReviewForm extends StatelessWidget {
  const _ReviewForm({
    required this.titleController,
    required this.commentController,
    required this.ratings,
    required this.isSubmitting,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final TextEditingController titleController;
  final TextEditingController commentController;
  final Map<String, double> ratings;
  final bool isSubmitting;
  final void Function(String label, double value) onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accessibility.secondarySurfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accessibility.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add your review',
            style: TextStyle(
              color: accessibility.textColor,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            enabled: !isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            maxLength: 80,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: commentController,
            enabled: !isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Comment',
              border: OutlineInputBorder(),
            ),
            minLines: 3,
            maxLines: 5,
            maxLength: 600,
          ),
          const SizedBox(height: 10),
          ...ratings.keys.map(
            (label) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButtonFormField<double>(
                value: ratings[label],
                decoration: InputDecoration(
                  labelText: label[0].toUpperCase() + label.substring(1),
                  border: const OutlineInputBorder(),
                ),
                items: const [0, 1, 2, 3, 4, 5]
                    .map(
                      (score) => DropdownMenuItem<double>(
                        value: score.toDouble(),
                        child: Text('$score / 5'),
                      ),
                    )
                    .toList(growable: false),
                onChanged: isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          onRatingChanged(label, value);
                        }
                      },
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: isSubmitting ? null : onSubmit,
            icon: const Icon(Icons.rate_review, size: 18),
            label: Text(isSubmitting ? 'Publishing...' : 'Publish review'),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accessibility.secondarySurfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accessibility.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.title,
                  style: TextStyle(
                    color: accessibility.textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const Icon(Icons.star, size: 17, color: Color(0xFFFFB020)),
              const SizedBox(width: 4),
              Text(
                review.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  color: accessibility.textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(
                color: accessibility.secondaryTextColor,
                height: accessibility.lineHeight ?? 1.45,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: review.ratings
                .map(
                  (rating) => Chip(
                    label: Text(
                      '${rating.label}: ${rating.score.toStringAsFixed(0)}/5',
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}