import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/accessibility_state.dart';
import '../theme/theme.dart';
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
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: accessibility.surfaceColor,
        border: Border(
          bottom: BorderSide(color: accessibility.borderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Image.asset(
              'assets/resources/logos/logo.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(width: 32, height: 32),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Trip2Guide',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: accessibility.textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (!isLoggedIn)
              GestureDetector(
                onTap: onLogin,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accessibility.secondarySurfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accessibility.borderColor),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accessibility.textColor,
                    ),
                  ),
                ),
              ),
            if (!isLoggedIn) const SizedBox(width: 8),
            PopupMenuButton<String>(
              offset: const Offset(0, 44),
              color: accessibility.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                side: BorderSide(color: accessibility.borderColor),
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
                  return [
                    PopupMenuItem(
                      value: 'login',
                      child: Text(
                        'Login',
                        style: TextStyle(color: accessibility.textColor),
                      ),
                    ),
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
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: accessibility.textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentUser!.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: accessibility.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentUser!.name} ${currentUser!.surname}',
                          style: TextStyle(
                            fontSize: 12,
                            color: accessibility.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'profile',
                    child: Text(
                      'View profile',
                      style: TextStyle(color: accessibility.textColor),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Text(
                      'Logout',
                      style: TextStyle(color: accessibility.textColor),
                    ),
                  ),
                ];
              },
              child: isLoggedIn
                  ? Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: accessibility.surfaceColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: accessibility.borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_circle_outlined,
                            color: accessibility.textColor,
                            size: 24,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              currentUser!.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: accessibility.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accessibility.secondarySurfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: accessibility.borderColor),
                      ),
                      child: Icon(
                        Icons.person,
                        color: accessibility.textColor,
                        size: 22,
                      ),
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
    this.chatUnreadCount = 0,
  });

  final AppTab activeTab;
  final int chatUnreadCount;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      decoration: BoxDecoration(
        color: accessibility.surfaceColor,
        border: Border(
          top: BorderSide(color: accessibility.borderColor, width: 0.5),
        ),
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
                unreadCount: chatUnreadCount,
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
    this.unreadCount = 0,
  });

  final String icon;
  final bool selected;
  final int unreadCount;
  final VoidCallback onTap;

  IconData get iconData {
    switch (icon) {
      case 'home':
        return Icons.home_rounded;
      case 'routes':
        return Icons.route_rounded;
      case 'chats':
        return Icons.chat_bubble_outline_rounded;
      case 'favorites':
        return Icons.star_border_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2.5,
              width: selected ? 24 : 0,
              decoration: BoxDecoration(
                color: accessibility.textColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  iconData,
                  size: 28,
                  color: selected
                      ? accessibility.textColor
                      : accessibility.secondaryTextColor,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -10,
                    top: -8,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
    required this.accessibilityFilter,
    required this.onSearchChanged,
    required this.onSearchFocusChanged,
    required this.onToggleFilter,
    required this.onClear,
    required this.onSortSelected,
    required this.onAccessibilityFilterChanged,
  });

  final TextEditingController controller;
  final bool isSearchActive;
  final bool hasActiveFilter;
  final bool isFilterOpen;
  final SortOption? sortOption;
  final String accessibilityFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onSearchFocusChanged;
  final VoidCallback onToggleFilter;
  final VoidCallback onClear;
  final ValueChanged<SortOption> onSortSelected;
  final ValueChanged<String> onAccessibilityFilterChanged;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: accessibility.inputFillColor,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: accessibility.borderColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 20,
                color: isSearchActive
                    ? accessibility.textColor
                    : accessibility.secondaryTextColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Focus(
                  onFocusChange: onSearchFocusChanged,
                  child: TextField(
                    controller: controller,
                    onChanged: onSearchChanged,
                    style: TextStyle(
                      fontSize: 15,
                      color: accessibility.textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Where do you want to explore today?',
                      hintStyle: TextStyle(
                        color: accessibility.secondaryTextColor,
                      ),
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
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: accessibility.secondaryTextColor,
                  ),
                ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onToggleFilter,
                child: Icon(
                  Icons.tune,
                  size: 20,
                  color: hasActiveFilter
                      ? accessibility.textColor
                      : accessibility.secondaryTextColor,
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
                color: accessibility.surfaceColor,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: accessibility.borderColor),
                boxShadow: const [AppShadows.panel],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: accessibilityFilter,
                    decoration: const InputDecoration(
                      labelText: 'Accessible',
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('All'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'yes',
                        child: Text('Yes'),
                      ),
                      DropdownMenuItem<String>(value: 'no', child: Text('No')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onAccessibilityFilterChanged(value);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _SortGroup(
                    title: 'Difficulty',
                    options: const [
                      SortOption.difficultyAsc,
                      SortOption.difficultyDesc,
                    ],
                    selected: sortOption,
                    onSelected: onSortSelected,
                  ),
                  const SizedBox(height: 8),
                  _SortGroup(
                    title: 'Duration',
                    options: const [
                      SortOption.durationAsc,
                      SortOption.durationDesc,
                    ],
                    selected: sortOption,
                    onSelected: onSortSelected,
                  ),
                  const SizedBox(height: 8),
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
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: accessibility.textColor,
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
              borderRadius: BorderRadius.circular(AppRadii.xl),
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
                Text(
                  route.difficulty.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                _RouteRating(ratingAverage: route.ratingAverage),
                if (route.wheelchairAccessible) ...[
                  const SizedBox(width: 6),
                  const _AccessibleBadge(),
                ],
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    route.locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
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
    final accessibility = context.watch<AccessibilityState>();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
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
                          color: accessibility.surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: accessibility.borderColor),
                        ),
                        child: Center(
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 17,
                            color: isFavorite
                                ? const Color(0xFFE45A6D)
                                : accessibility.textColor,
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accessibility.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _RouteRating(ratingAverage: route.ratingAverage),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  route.locationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: accessibility.secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Card(
      margin: EdgeInsets.zero,
      color: accessibility.surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        side: BorderSide(color: accessibility.borderColor),
      ),
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
                          color: accessibility.surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: accessibility.borderColor),
                        ),
                        child: Center(
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFavorite
                                ? const Color(0xFFE45A6D)
                                : accessibility.textColor,
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: accessibility.textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _DifficultyBadge(difficulty: route.difficulty),
                        const SizedBox(width: 6),
                        Text(
                          route.difficulty.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: accessibility.secondaryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _RouteRating(ratingAverage: route.ratingAverage),
                        if (route.wheelchairAccessible) ...[
                          const SizedBox(width: 6),
                          const _AccessibleBadge(),
                        ],
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            route.locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: accessibility.secondaryTextColor,
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
                      style: TextStyle(
                        fontSize: 12,
                        height: accessibility.lineHeight ?? 1.4,
                        color: accessibility.secondaryTextColor,
                        wordSpacing: accessibility.wordSpacingValue,
                        letterSpacing: accessibility.letterSpacingValue,
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
    final accessibility = context.watch<AccessibilityState>();

    return GestureDetector(
      onTap: () => onTap(option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accessibility.secondarySurfaceColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: isSelected
              ? Border.all(color: accessibility.borderColor)
              : null,
        ),
        child: Row(
          children: [
            Text(
              isSelected ? '☑' : '☐',
              style: TextStyle(fontSize: 14, color: accessibility.textColor),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: accessibility.textColor,
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
    final accessibility = context.watch<AccessibilityState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accessibility.secondaryTextColor,
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
    final accessibility = context.watch<AccessibilityState>();

    Widget placeholder() {
      return Container(
        decoration: BoxDecoration(
          color: accessibility.secondarySurfaceColor,
          border: Border.all(color: accessibility.borderColor),
        ),
        child: Center(
          child: Icon(
            Icons.landscape_outlined,
            color: accessibility.secondaryTextColor,
            size: 28,
          ),
        ),
      );
    }

    if (imageUrl.trim().isEmpty) {
      return placeholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return placeholder();
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
      borderRadius: BorderRadius.circular(AppRadii.pill),
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

class _AccessibleBadge extends StatelessWidget {
  const _AccessibleBadge();

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Tooltip(
      message: 'Accessible',
      child: Icon(
        Icons.accessible_rounded,
        size: 14,
        color: accessibility.textColor,
      ),
    );
  }
}

class _RouteRating extends StatelessWidget {
  const _RouteRating({required this.ratingAverage});

  final double? ratingAverage;

  @override
  Widget build(BuildContext context) {
    final label = ratingAverage?.toStringAsFixed(1) ?? '-';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 14, color: Color(0xFFFBBC05)),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
