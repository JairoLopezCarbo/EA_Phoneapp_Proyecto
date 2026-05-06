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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 12),
        if (totalResults > 0)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSoft),
            ),
            child: Wrap(
              runSpacing: 12,
              spacing: 14,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  'Showing $startResult-$endResult of $totalResults',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF20304A)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Show', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: pageSize,
                      items: const [10, 25, 50]
                          .map(
                            (value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value != null) {
                          onPageSizeChange(value);
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    const Text('per page', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: currentPage <= 1 ? null : onPreviousPage,
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Page $currentPage of $totalPages',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4A5770)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: currentPage >= totalPages ? null : onNextPage,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (routes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              emptyMessage,
              style: const TextStyle(fontSize: 15, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
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
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}
