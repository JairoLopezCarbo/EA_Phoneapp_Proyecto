import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/search_results_panel.dart';
import '../widgets/shared_widgets.dart';
import 'create_route_page.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key, required this.onOpenRoute});

  final ValueChanged<RouteModel> onOpenRoute;

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
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

    final filteredRoutes =
        query.isEmpty ? appState.routes : appState.searchRoutes(query);

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
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateRoutePage(
                      onCreated: (route) {
                        Navigator.of(context).pop();
                        widget.onOpenRoute(route);
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create route'),
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          SearchResultsPanel(
            title: 'Routes',
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
              if (!appState.isAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Log in to save favorites.')),
                );
                return;
              }

              await appState.toggleFavorite(routeId);
            },
            isFavorite: (routeId) =>
                appState.currentUser?.favoriteRouteIds.contains(routeId) ??
                false,
          ),
        ],
      ),
    );
  }
}