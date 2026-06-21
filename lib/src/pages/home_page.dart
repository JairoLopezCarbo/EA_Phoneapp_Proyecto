import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/search_results_panel.dart';
import '../widgets/shared_widgets.dart';
import '../state/accessibility_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onOpenRoute,
    required this.onOpenAuth,
  });

  final ValueChanged<RouteModel> onOpenRoute;
  final void Function(AuthMode mode) onOpenAuth;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _defaultPageSize = 10;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  bool _isFilterOpen = false;
  int _currentPage = 1;
  int _pageSize = _defaultPageSize;
  SortOption? _sortOption;
  String _accessibilityFilter = 'all';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isSearchFocused = _searchFocusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final query = _searchController.text.trim().toLowerCase();
    final isSearchActive = _isSearchFocused || query.isNotEmpty;
    final hasActiveFilter =
        _sortOption != null || _accessibilityFilter != 'all';
    final accessibilityValue = _accessibilityFilter == 'all'
        ? null
        : _accessibilityFilter == 'yes';

    final shouldShowSearchResults =
        query.isNotEmpty || _accessibilityFilter != 'all';
    final textFilteredRoutes = query.isEmpty
        ? (shouldShowSearchResults ? appState.routes : <RouteModel>[])
        : appState.searchRoutes(query);
    final searchResults = sortRoutes(
      appState.filterRoutesByAccessibility(
        textFilteredRoutes,
        accessibilityValue,
      ),
      _sortOption,
    );

    final totalResults = searchResults.length;
    final totalPages = math.max(1, (totalResults / _pageSize).ceil());
    final safeCurrentPage = math.min(_currentPage, totalPages);
    final visibleResults = !shouldShowSearchResults
        ? <RouteModel>[]
        : searchResults
              .skip((safeCurrentPage - 1) * _pageSize)
              .take(_pageSize)
              .toList(growable: false);
    final featuredRoutes = appState.featuredRoutes;
    final popularRoutes = appState.popularRoutes;
    final visitedCities = appState.visitedCityKeys();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchArea(
            controller: _searchController,
            isSearchActive: isSearchActive,
            hasActiveFilter: hasActiveFilter,
            isFilterOpen: _isFilterOpen,
            sortOption: _sortOption,
            accessibilityFilter: _accessibilityFilter,
            onSearchChanged: (value) {
              setState(() {
                _currentPage = 1;
              });
            },
            onSearchFocusChanged: (focused) {
              setState(() {
                _isSearchFocused = focused;
              });
            },
            onToggleFilter: () {
              setState(() {
                _isFilterOpen = !_isFilterOpen;
              });
            },
            onClear: () {
              setState(() {
                _searchController.clear();
                _sortOption = null;
                _accessibilityFilter = 'all';
                _isFilterOpen = false;
                _currentPage = 1;
                _pageSize = _defaultPageSize;
              });
            },
            onSortSelected: (option) {
              setState(() {
                _sortOption = option;
                _isFilterOpen = false;
                _currentPage = 1;
              });
            },
            onAccessibilityFilterChanged: (value) {
              setState(() {
                _accessibilityFilter = value;
                _currentPage = 1;
              });
            },
          ),
          const SizedBox(height: 16),
          if (shouldShowSearchResults)
            SearchResultsPanel(
              title: 'Explore the routes available in Trip2Guide.',
              routes: visibleResults,
              totalResults: totalResults,
              currentPage: safeCurrentPage,
              pageSize: _pageSize,
              totalPages: totalPages,
              onPreviousPage: () {
                setState(() {
                  _currentPage = math.max(1, _currentPage - 1);
                });
              },
              onNextPage: () {
                setState(() {
                  _currentPage = math.min(totalPages, _currentPage + 1);
                });
              },
              onPageSizeChange: (nextPageSize) {
                setState(() {
                  _pageSize = nextPageSize;
                  _currentPage = 1;
                });
              },
              onOpenRoute: widget.onOpenRoute,
              onToggleFavorite: (routeId) {
                final appState = context.read<AppState>();
                if (!appState.isAuthenticated) {
                  widget.onOpenAuth(AuthMode.login);
                  return;
                }

                appState.toggleFavorite(routeId);
              },
              isFavorite: (routeId) =>
                  appState.currentUser?.favoriteRouteIds.contains(routeId) ??
                  false,
            )
          else ...[
            // Featured routes section - full width banner style
            if (featuredRoutes.isNotEmpty) ...[
              SizedBox(
                height: 150,
                child: PageView.builder(
                  itemCount: featuredRoutes.length,
                  controller: PageController(viewportFraction: 0.92),
                  itemBuilder: (context, index) {
                    final route = featuredRoutes[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => widget.onOpenRoute(route),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              RouteImage(imageUrl: route.firstImage),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.05),
                                      Colors.black.withValues(alpha: 0.55),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: Text(
                                  featuredOverlayText(index),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Nearby routes / Cities - circular thumbnails
            if (visitedCities.isNotEmpty) ...[
              _SectionTitle(title: 'Top most visited cities'),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: visitedCities.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cityKey = visitedCities[index];
                    final routes = appState.routesInCityKey(cityKey);
                    final route = routes.first;
                    return CityCard(
                      city: route.city,
                      imageUrl: route.firstImage,
                      onTap: () {
                        _searchFocusNode.unfocus();
                        setState(() {
                          _searchController.text = route.city;
                          _currentPage = 1;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Popular routes - horizontal scroll
            if (popularRoutes.isNotEmpty) ...[
              _SectionTitle(title: 'Top 5 popular routes'),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularRoutes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final route = popularRoutes[index];
                    final isFavorite =
                        appState.currentUser?.favoriteRouteIds.contains(
                          route.id,
                        ) ??
                        false;
                    return SizedBox(
                      width: 170,
                      child: RouteResultCard(
                        route: route,
                        isFavorite: isFavorite,
                        vertical: true,
                        onTap: () => widget.onOpenRoute(route),
                        onToggleFavorite: () async {
                          if (!appState.isAuthenticated) {
                            widget.onOpenAuth(AuthMode.login);
                            return;
                          }
                          await appState.toggleFavorite(route.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: accessibility.textColor,
            height: accessibility.lineHeight,
            wordSpacing: accessibility.wordSpacingValue,
            letterSpacing: accessibility.letterSpacingValue,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right,
          size: 20,
          color: accessibility.secondaryTextColor,
        ),
      ],
    );
  }
}
