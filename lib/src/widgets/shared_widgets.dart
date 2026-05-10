import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

enum AppTab { home, routes, chats, favorites }

class AppTopNav extends StatelessWidget {
  const AppTopNav({
    super.key,
    required this.currentUser,
    required this.onLogin,
    required this.onProfile,
    required this.onLogout,
  });

  final AppUser? currentUser;
  final VoidCallback onLogin;
  final VoidCallback onProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = currentUser != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderSoft, width: 0.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Image.asset(
              'assets/resources/logos/logo.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 32, height: 32),
            ),
            const SizedBox(width: 8),
            const Text(
              'Trip2Guide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.text,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            if (!isLoggedIn)
              GestureDetector(
                onTap: onLogin,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              offset: const Offset(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'login':
                    onLogin();
                    break;
                  case 'profile':
                    onProfile();
                    break;
                  case 'logout':
                    onLogout();
                    break;
                }
              },
              itemBuilder: (context) {
                if (!isLoggedIn) {
                  return const [
                    PopupMenuItem(value: 'login', child: Text('Login')),
                  ];
                }

                return [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser!.username,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentUser!.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentUser!.name} ${currentUser!.surname}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('View profile'),
                  ),
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                ];
              },
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: _NavIcon(icon: 'user', selected: isLoggedIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  final AppTab activeTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderSoft, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BottomNavItem(
                icon: 'home',
                selected: activeTab == AppTab.home,
                onTap: () => onTabSelected(AppTab.home),
              ),
              _BottomNavItem(
                icon: 'routes',
                selected: activeTab == AppTab.routes,
                onTap: () => onTabSelected(AppTab.routes),
              ),
              _BottomNavItem(
                icon: 'chats',
                selected: activeTab == AppTab.chats,
                onTap: () => onTabSelected(AppTab.chats),
              ),
              _BottomNavItem(
                icon: 'favorites',
                selected: activeTab == AppTab.favorites,
                onTap: () => onTabSelected(AppTab.favorites),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Active indicator line on top
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2.5,
              width: selected ? 24 : 0,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Spacer(),
            _NavIcon(icon: icon, selected: selected),
            const Spacer(),
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
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 20,
                color: isSearchActive ? AppTheme.text : AppTheme.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Focus(
                  onFocusChange: onSearchFocusChanged,
                  child: TextField(
                    controller: controller,
                    onChanged: onSearchChanged,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Where do you want to explore today?',
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              if (controller.text.isNotEmpty || hasActiveFilter)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onToggleFilter,
                child: Icon(
                  Icons.tune,
                  size: 20,
                  color: hasActiveFilter ? AppTheme.primary : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (isFilterOpen)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderSoft),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SortGroup(
                    title: 'Difficulty',
                    options: const [SortOption.difficultyAsc, SortOption.difficultyDesc],
                    selected: sortOption,
                    onSelected: onSortSelected,
                  ),
                  const SizedBox(height: 8),
                  _SortGroup(
                    title: 'Duration',
                    options: const [SortOption.durationAsc, SortOption.durationDesc],
                    selected: sortOption,
                    onSelected: onSortSelected,
                  ),
                  const SizedBox(height: 8),
                  _SortGroup(
                    title: 'Distance',
                    options: const [SortOption.distanceAsc, SortOption.distanceDesc],
                    selected: sortOption,
                    onSelected: onSortSelected,
                  ),
                ],
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
          fontSize: 18,
          fontWeight: FontWeight.w700,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32;

    return SizedBox(
      width: cardWidth.clamp(200, 400).toDouble(),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.6,
                    child: _RouteImage(imageUrl: route.firstImage),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      overlayText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              route.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _DifficultyBadge(difficulty: route.difficulty),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${route.difficulty.title} · ${route.locationLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
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
    this.vertical = false,
  });

  final RouteModel route;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final bool compact;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return _buildVertical(context);
    }
    return _buildHorizontal(context);
  }

  Widget _buildVertical(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 0.85,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _RouteImage(imageUrl: route.firstImage),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onToggleFavorite,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            navAssetPath('favorites', isFavorite),
                            width: 16,
                            height: 16,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isFavorite ? const Color(0xFFE45A6D) : AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            route.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Color(0xFFFBBC05)),
              const SizedBox(width: 3),
              Text(
                route.locationLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: compact ? 100 : 120,
              height: compact ? 100 : 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _RouteImage(imageUrl: route.firstImage),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onToggleFavorite,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            navAssetPath('favorites', isFavorite),
                            width: 14,
                            height: 14,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 14,
                              color: isFavorite ? const Color(0xFFE45A6D) : AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      route.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _DifficultyBadge(difficulty: route.difficulty),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${route.difficulty.title} · ${route.locationLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      route.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppTheme.textMuted,
                      ),
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
  const CityCard({
    super.key,
    required this.city,
    required this.imageUrl,
    required this.onTap,
  });

  final String city;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _RouteImage(imageUrl: imageUrl),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              city,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class SortButton extends StatelessWidget {
  const SortButton({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

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
    return GestureDetector(
      onTap: () => onTap(option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              isSelected ? '☑' : '☐',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: AppTheme.text,
              ),
            ),
          ],
        ),
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
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 0.3,
            ),
          ),
        ),
        ...options.map(
          (option) =>
              SortButton(option: option, selected: selected, onTap: onSelected),
        ),
      ],
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
      width: 22,
      height: 22,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.circle,
        size: 18,
        color: selected ? AppTheme.primary : AppTheme.textMuted,
      ),
    );
  }
}

class RouteImage extends StatelessWidget {
  const RouteImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return _RouteImage(imageUrl: imageUrl);
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
            colors: [Color(0xFFF5F5F5), Color(0xFFEAEAEA)],
          ),
        ),
        child: const Center(
          child: Icon(Icons.landscape_outlined, color: AppTheme.textMuted, size: 28),
        ),
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
              colors: [Color(0xFFF5F5F5), Color(0xFFEAEAEA)],
            ),
          ),
          child: const Center(
            child: Icon(Icons.landscape_outlined, color: AppTheme.textMuted, size: 28),
          ),
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
        width: 16,
        height: 16,
        child: Image.asset(
          difficultyBadgePath(difficulty),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.fiber_manual_record, size: 10),
        ),
      ),
    );
  }
}
