import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
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
                          style: const TextStyle(
                            height: 1.55,
                            fontSize: 14,
                            color: AppTheme.textMuted,
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
                              for (var index = 0; index < route.tags.length; index++)
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
                                appState.currentUser?.favoriteRouteIds
                                            .contains(route.id) ??
                                        false
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                              ),
                              label: Text(
                                appState.currentUser?.favoriteRouteIds
                                            .contains(route.id) ??
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.borderSoft),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 8),
            const SizedBox(width: 6),
            Text(
              difficulty.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
        Expanded(child: _FactCard(label: 'Distance', value: formatDistance(distance))),
        const SizedBox(width: 10),
        Expanded(child: _FactCard(label: 'Duration', value: formatDuration(duration))),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
            ),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                    child: Icon(Icons.image_outlined, color: AppTheme.textMuted),
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
