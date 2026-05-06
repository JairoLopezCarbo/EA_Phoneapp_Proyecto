import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

enum AppTab { home, routes, chats, favorites }

class AppTopNav extends StatelessWidget {
  const AppTopNav({
    super.key,
    required this.activeTab,
    required this.currentUser,
    required this.onTabSelected,
    required this.onLogin,
    required this.onRegister,
    required this.onProfile,
    required this.onLogout,
    required this.onChats,
    this.showBrandAction = true,
  });

  final AppTab activeTab;
  final AppUser? currentUser;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onProfile;
  final VoidCallback onLogout;
  final VoidCallback onChats;
  final bool showBrandAction;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = currentUser != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: const Border(bottom: BorderSide(color: AppTheme.borderSoft)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F1219),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: showBrandAction ? () => onTabSelected(AppTab.home) : null,
              child: SizedBox(
                height: 34,
                child: Image.asset(
                  'assets/resources/logos/logo_horizontal.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Trip2Guide',
                        style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _NavButton(
                      label: 'Home',
                      icon: 'home',
                      selected: activeTab == AppTab.home,
                      onTap: () => onTabSelected(AppTab.home),
                    ),
                    _NavButton(
                      label: 'Routes',
                      icon: 'routes',
                      selected: activeTab == AppTab.routes,
                      onTap: () => onTabSelected(AppTab.routes),
                    ),
                    _NavButton(
                      label: 'Chats',
                      icon: 'chats',
                      selected: activeTab == AppTab.chats,
                      onTap: onChats,
                    ),
                    _NavButton(
                      label: 'Favorites',
                      icon: 'favorites',
                      selected: activeTab == AppTab.favorites,
                      onTap: () => onTabSelected(AppTab.favorites),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (!isLoggedIn)
              Wrap(
                spacing: 8,
                children: [
                  _ActionButton(
                    label: 'Login',
                    filled: false,
                    onTap: onLogin,
                  ),
                  _ActionButton(
                    label: 'Register',
                    filled: true,
                    onTap: onRegister,
                  ),
                ],
              )
            else
              PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      onProfile();
                      break;
                    case 'logout':
                      onLogout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser!.username,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          currentUser!.email,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Text('View profile'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: activeTab == AppTab.home ? const Color(0xFFF0F2F7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavIcon(
                        icon: 'user',
                        selected: true,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentUser!.username,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SearchArea extends StatelessWidget {
  const SearchArea({
    super.key,
    required this.controller,
    required this.isSearchActive,
    required this.hasActiveFilter,
    required this.isFilterOpen,
    required this.sortOption,
    required this.onSearchChanged,
    required this.onSearchFocusChanged,
    required this.onToggleFilter,
    required this.onClear,
    required this.onSortSelected,
  });

  final TextEditingController controller;
  final bool isSearchActive;
  final bool hasActiveFilter;
  final bool isFilterOpen;
  final SortOption? sortOption;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onSearchFocusChanged;
  final VoidCallback onToggleFilter;
  final VoidCallback onClear;
  final ValueChanged<SortOption> onSortSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderSoft),
          ),
          child: Row(
            children: [
              _NavIcon(icon: 'search', selected: isSearchActive),
              const SizedBox(width: 10),
              Expanded(
                child: Focus(
                  onFocusChange: onSearchFocusChanged,
                  child: TextField(
                    controller: controller,
                    onChanged: onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Where do you want to explore today?',
                      isDense: true,
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleFilter,
                icon: _NavIcon(icon: 'filter', selected: hasActiveFilter),
                tooltip: 'Filter results',
              ),
              if (controller.text.isNotEmpty || hasActiveFilter)
                TextButton(
                  onPressed: onClear,
                  child: const Text('Clear'),
                ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(76, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Search'),
              ),
            ],
          ),
        ),
        if (isFilterOpen)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderSoft),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1D0F1219),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SortGroup(
                      title: 'Difficulty',
                      options: const [
                        SortOption.difficultyAsc,
                        SortOption.difficultyDesc,
                      ],
                      selected: sortOption,
                      onSelected: onSortSelected,
                    ),
                    const SizedBox(height: 10),
                    _SortGroup(
                      title: 'Duration',
                      options: const [
                        SortOption.durationAsc,
                        SortOption.durationDesc,
                      ],
                      selected: sortOption,
                      onSelected: onSortSelected,
                    ),
                    const SizedBox(height: 10),
                    _SortGroup(
                      title: 'Distance',
                      options: const [
                        SortOption.distanceAsc,
                        SortOption.distanceDesc,
                      ],
                      selected: sortOption,
                      onSelected: onSortSelected,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppTheme.text,
        ),
      ),
    );
  }
}

class FeaturedRouteCard extends StatelessWidget {
  const FeaturedRouteCard({
    super.key,
    required this.route,
    required this.overlayText,
    required this.onTap,
  });

  final RouteModel route;
  final String overlayText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.15,
                    child: _RouteImage(imageUrl: route.firstImage),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.16),
                            Colors.black.withValues(alpha: 0.72),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Text(
                      overlayText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              route.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _DifficultyBadge(difficulty: route.difficulty),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${route.difficulty.title} · ${route.locationLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF4A5770), fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RouteResultCard extends StatelessWidget {
  const RouteResultCard({
    super.key,
    required this.route,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.compact = false,
  });

  final RouteModel route;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: compact ? 120 : 136,
              height: compact ? 120 : 136,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _RouteImage(imageUrl: route.firstImage),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: IconButton(
                        onPressed: onToggleFavorite,
                        visualDensity: VisualDensity.compact,
                        icon: Image.asset(
                          navAssetPath('favorites', isFavorite),
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFavorite ? const Color(0xFFE45A6D) : AppTheme.primary,
                          ),
                        ),
                        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      route.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _DifficultyBadge(difficulty: route.difficulty),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${route.difficulty.title} · ${route.locationLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF4A5770), fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      route.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF39465F)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      route.locationLabel,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CityCard extends StatelessWidget {
  const CityCard({super.key, required this.city, required this.imageUrl, required this.onTap});

  final String city;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 1.15,
                child: _RouteImage(imageUrl: imageUrl),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              city,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class SortButton extends StatelessWidget {
  const SortButton({super.key, required this.option, required this.selected, required this.onTap});

  final SortOption option;
  final SortOption? selected;
  final ValueChanged<SortOption> onTap;

  String get label {
    switch (option) {
      case SortOption.difficultyAsc:
        return 'Difficulty ↑';
      case SortOption.difficultyDesc:
        return 'Difficulty ↓';
      case SortOption.durationAsc:
        return 'Duration ↑';
      case SortOption.durationDesc:
        return 'Duration ↓';
      case SortOption.distanceAsc:
        return 'Distance ↑';
      case SortOption.distanceDesc:
        return 'Distance ↓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == option;
    return TextButton(
      onPressed: () => onTap(option),
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFF0F2F7) : Colors.transparent,
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        children: [
          Text(isSelected ? '☑' : '☐'),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _SortGroup extends StatelessWidget {
  const _SortGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<SortOption> options;
  final SortOption? selected;
  final ValueChanged<SortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF6B7280)),
          ),
        ),
        ...options.map((option) => SortButton(option: option, selected: selected, onTap: onSelected)),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0F2F7) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavIcon(icon: icon, selected: selected),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppTheme.primary : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, required this.filled});

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minWidth: 92, minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: filled ? AppTheme.primary : AppTheme.border),
          boxShadow: filled
              ? const [
                  BoxShadow(
                    color: Color(0x140F1219),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: filled ? Colors.white : AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.selected});

  final String icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      navAssetPath(icon, selected),
      width: 20,
      height: 20,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.circle,
        size: 16,
        color: selected ? AppTheme.primary : AppTheme.textMuted,
      ),
    );
  }
}

class _RouteImage extends StatelessWidget {
  const _RouteImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFF4F7), Color(0xFFDDE7EE)],
          ),
        ),
        child: const Center(child: Icon(Icons.landscape, color: AppTheme.primary)),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEFF4F7), Color(0xFFDDE7EE)],
            ),
          ),
          child: const Center(child: Icon(Icons.landscape, color: AppTheme.primary)),
        );
      },
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final RouteDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 18,
        height: 18,
        child: Image.asset(
          difficultyBadgePath(difficulty),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.fiber_manual_record, size: 10),
        ),
      ),
    );
  }
}
