import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';
import '../utils/formatters.dart';
import '../utils/localization.dart';
import '../widgets/search_results_panel.dart';
import '../widgets/shared_widgets.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({
    super.key,
    required this.onOpenRoute,
    required this.onOpenAuth,
  });

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
    final user = appState.currentUser;
    final query = _searchController.text.trim().toLowerCase();
    final isSearchActive = _isSearchFocused || query.isNotEmpty;
    final hasActiveFilter =
        _sortOption != null || _accessibilityFilter != 'all';
    final accessibilityValue = _accessibilityFilter == 'all'
        ? null
        : _accessibilityFilter == 'yes';

    final favoriteRoutes = appState.favoriteRoutesForCurrentUser();
    final textFilteredRoutes = query.isEmpty
        ? favoriteRoutes
        : appState.searchRoutes(query, source: favoriteRoutes);
    final filteredRoutes = appState.filterRoutesByAccessibility(
      textFilteredRoutes,
      accessibilityValue,
    );
    final sortedRoutes = sortRoutes(filteredRoutes, _sortOption);
    final totalResults = sortedRoutes.length;
    final totalPages = math.max(1, (totalResults / _pageSize).ceil());
    final safeCurrentPage = math.min(_currentPage, totalPages);
    final visibleRoutes = sortedRoutes
        .skip((safeCurrentPage - 1) * _pageSize)
        .take(_pageSize)
        .toList(growable: false);

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
          if (user == null)
            _LoggedOutFavorites(onOpenAuth: widget.onOpenAuth)
          else
            SearchResultsPanel(
              title: context.l10n.favoriteRoutes,
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
              isFavorite: (routeId) =>
                  appState.currentUser?.favoriteRouteIds.contains(routeId) ??
                  false,
              emptyMessage: context.l10n.noFavoriteRoutes,
            ),
        ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.loginToViewFavorites,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => onOpenAuth(AuthMode.login),
            child: Text(context.l10n.login),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => onOpenAuth(AuthMode.register),
            child: Text(context.l10n.register),
          ),
        ],
      ),
    );
  }
}
