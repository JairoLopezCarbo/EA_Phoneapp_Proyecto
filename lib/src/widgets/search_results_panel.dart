import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

class SearchResultsPanel extends StatelessWidget {
  const SearchResultsPanel({
    super.key,
    required this.title,
    required this.routes,
    required this.totalResults,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onPageSizeChange,
    required this.onOpenRoute,
    required this.onToggleFavorite,
    required this.isFavorite,
    this.emptyMessage = 'No matching routes found.',
  });

  final String title;
  final List<RouteModel> routes;
  final int totalResults;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final ValueChanged<int> onPageSizeChange;
  final ValueChanged<RouteModel> onOpenRoute;
  final ValueChanged<String> onToggleFavorite;
  final bool Function(String routeId) isFavorite;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final startResult = totalResults == 0 ? 0 : (currentPage - 1) * pageSize + 1;
    final endResult = totalResults == 0 ? 0 : (currentPage * pageSize).clamp(1, totalResults);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Search results'),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 12),
        if (totalResults > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  'Showing $startResult-$endResult of $totalResults',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Show', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border),
                        color: Colors.white,
                      ),
                      child: DropdownButton<int>(
                        value: pageSize,
                        underline: const SizedBox.shrink(),
                        isDense: true,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text),
                        items: const [10, 25, 50]
                            .map((value) => DropdownMenuItem<int>(value: value, child: Text('$value')))
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            onPageSizeChange(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('per page', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: currentPage <= 1 ? null : onPreviousPage,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$currentPage / $totalPages',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: currentPage >= totalPages ? null : onNextPage,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (routes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              emptyMessage,
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
            ),
          )
        else
          Column(
            children: [
              for (final route in routes) ...[
                RouteResultCard(
                  route: route,
                  isFavorite: isFavorite(route.id),
                  onTap: () => onOpenRoute(route),
                  onToggleFavorite: () => onToggleFavorite(route.id),
                  compact: true,
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}
