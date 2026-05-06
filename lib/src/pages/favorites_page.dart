import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/search_results_panel.dart';
import '../widgets/shared_widgets.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.onOpenRoute, required this.onOpenAuth});

  final ValueChanged<RouteModel> onOpenRoute;
  final void Function(AuthMode mode) onOpenAuth;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
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
    final user = appState.currentUser;
    final query = _searchController.text.trim().toLowerCase();
    final isSearchActive = _isSearchFocused || query.isNotEmpty;
    final hasActiveFilter = _sortOption != null;

    final favoriteRoutes = appState.favoriteRoutesForCurrentUser();
    final filteredRoutes = query.isEmpty ? favoriteRoutes : appState.searchRoutes(query, source: favoriteRoutes);
    final sortedRoutes = sortRoutes(filteredRoutes, _sortOption);
    final totalResults = sortedRoutes.length;
    final totalPages = math.max(1, (totalResults / _pageSize).ceil());
    final safeCurrentPage = math.min(_currentPage, totalPages);
    final visibleRoutes = sortedRoutes
        .skip((safeCurrentPage - 1) * _pageSize)
        .take(_pageSize)
        .toList(growable: false);

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
              if (user == null)
                _LoggedOutFavorites(onOpenAuth: widget.onOpenAuth)
              else
                SearchResultsPanel(
                  title: 'Favorite routes',
                  routes: visibleRoutes,
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
                  onToggleFavorite: (routeId) async {
                    await appState.toggleFavorite(routeId);
                  },
                  isFavorite: (routeId) => appState.currentUser?.favoriteRouteIds.contains(routeId) ?? false,
                  emptyMessage: 'You do not have favorite routes yet.',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoggedOutFavorites extends StatelessWidget {
  const _LoggedOutFavorites({required this.onOpenAuth});

  final void Function(AuthMode mode) onOpenAuth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E8EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You need to log in to view favorite routes.',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton(
                onPressed: () => onOpenAuth(AuthMode.login),
                child: const Text('Login'),
              ),
              OutlinedButton(
                onPressed: () => onOpenAuth(AuthMode.register),
                child: const Text('Register'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
