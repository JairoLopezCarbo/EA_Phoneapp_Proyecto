import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/search_results_panel.dart';
import '../widgets/shared_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onOpenRoute, required this.onOpenAuth});

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
    final hasActiveFilter = _sortOption != null;

    final searchResults = query.isEmpty
        ? <RouteModel>[]
        : sortRoutes(appState.searchRoutes(query), _sortOption);

    final totalResults = searchResults.length;
    final totalPages = math.max(1, (totalResults / _pageSize).ceil());
    final safeCurrentPage = math.min(_currentPage, totalPages);
    final visibleResults = query.isEmpty
        ? <RouteModel>[]
        : searchResults.skip((safeCurrentPage - 1) * _pageSize).take(_pageSize).toList(growable: false);
    final featuredRoutes = appState.featuredRoutes;
    final popularRoutes = appState.popularRoutes;
    final visitedCities = appState.visitedCityKeys();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchArea(
                controller: _searchController,
                isSearchActive: isSearchActive,
                hasActiveFilter: hasActiveFilter,
                isFilterOpen: _isFilterOpen,
                sortOption: _sortOption,
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
              ),
              const SizedBox(height: 18),
              if (query.isNotEmpty)
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
                  isFavorite: (routeId) => appState.currentUser?.favoriteRouteIds.contains(routeId) ?? false,
                )
              else ...[
                _SectionBlock(
                  title: 'Featured routes',
                  child: SizedBox(
                    height: 330,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredRoutes.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final route = featuredRoutes[index];
                        return FeaturedRouteCard(
                          route: route,
                          overlayText: featuredOverlayText(index),
                          onTap: () => widget.onOpenRoute(route),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _SectionBlock(
                  title: 'Top 5 popular routes',
                  child: SizedBox(
                    height: 285,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularRoutes.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final route = popularRoutes[index];
                        final isFavorite = appState.currentUser?.favoriteRouteIds.contains(route.id) ?? false;
                        return SizedBox(
                          width: 240,
                          child: RouteResultCard(
                            route: route,
                            isFavorite: isFavorite,
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
                ),
                const SizedBox(height: 18),
                _SectionBlock(
                  title: 'Top most visited cities',
                  child: SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: visitedCities.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        child,
      ],
    );
  }
}
