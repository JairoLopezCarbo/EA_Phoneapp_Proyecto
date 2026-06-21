import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/accessibility_state.dart';
import '../state/localization_state.dart';
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
    this.emptyMessage,
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
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();
    final localization = context.watch<LocalizationState>();

    final startResult = totalResults == 0
        ? 0
        : (currentPage - 1) * pageSize + 1;
    final endResult = totalResults == 0
        ? 0
        : (currentPage * pageSize).clamp(1, totalResults);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: localization.t('search.results')),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: accessibility.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        if (totalResults > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accessibility.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accessibility.borderColor),
            ),
            child: Column(
              children: [
                Text(
                  localization.t('search.showing', {
                    'start': startResult,
                    'end': endResult,
                    'total': totalResults,
                  }),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: accessibility.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      localization.t('search.show'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: accessibility.textColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accessibility.borderColor),
                        color: accessibility.inputFillColor,
                      ),
                      child: DropdownButton<int>(
                        value: pageSize,
                        underline: const SizedBox.shrink(),
                        isDense: true,
                        dropdownColor: accessibility.surfaceColor,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accessibility.textColor,
                        ),
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
                    ),
                    const SizedBox(width: 6),
                    Text(
                      localization.t('search.perPage'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: accessibility.textColor,
                      ),
                    ),
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
                          foregroundColor: accessibility.textColor,
                          side: BorderSide(color: accessibility.borderColor),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: Text(localization.t('common.back')),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$currentPage / $totalPages',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: accessibility.secondaryTextColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: currentPage >= totalPages
                            ? null
                            : onNextPage,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          foregroundColor: accessibility.textColor,
                          side: BorderSide(color: accessibility.borderColor),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: Text(localization.t('common.next')),
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
              emptyMessage ?? localization.t('search.noResults'),
              style: TextStyle(
                fontSize: 14,
                color: accessibility.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
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
