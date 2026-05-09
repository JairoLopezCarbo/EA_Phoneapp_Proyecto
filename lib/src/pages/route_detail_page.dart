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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _RouteHero(route: route),
                          const SizedBox(height: 12),
                          _DifficultyChip(difficulty: route.difficulty),
                          const SizedBox(height: 12),
                          _QuickFacts(
                            distance: route.distance,
                            duration: route.duration,
                          ),
                          const SizedBox(height: 12),
                          _PanelCard(
                            title: 'About this route',
                            child: Text(
                              route.description,
                              style: const TextStyle(
                                height: 1.55,
                                color: Color(0xFF39465F),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (route.tags.isNotEmpty)
                            _PanelCard(
                              title: 'Route tags',
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
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
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
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
                                  ),
                                  label: Text(
                                    appState.currentUser?.favoriteRouteIds
                                                .contains(route.id) ??
                                            false
                                        ? 'Saved to favorites'
                                        : 'Save to favorites',
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: onBack,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Back'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          SizedBox(
            height: 320,
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
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.name,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  route.locationLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF0FAFF),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (route.distance != null)
                      _MetaPill(label: '${route.distance} km'),
                    if (route.duration != null)
                      _MetaPill(label: '${route.duration} min'),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: route.tags
                      .map((tag) => _MetaPill(label: tag))
                      .toList(growable: false),
                ),
              ],
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.borderSoft),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F1219),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 10),
            const SizedBox(width: 8),
            Text(
              difficulty.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _FactCard(label: 'Distance', value: formatDistance(distance)),
        _FactCard(label: 'Duration', value: formatDuration(duration)),
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
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6A7385),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD5E6E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D3F65), Color(0xFF1F8C77)],
              ),
            ),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1D2B).withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x3DE4F5FF)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
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

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final image in uniqueImages)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 220,
              height: 160,
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF9FBFD), Color(0xFFF0F5F9)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
