import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_models.dart';
import 'pages/auth_page.dart';
import 'pages/chat_page.dart';
import 'pages/favorites_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/route_detail_page.dart';
import 'pages/routes_page.dart';
import 'services/push_notification_service.dart';
import 'state/accessibility_state.dart';
import 'state/app_state.dart';
import 'theme/theme.dart';
import 'widgets/accessibility_widgets.dart';
import 'widgets/shared_widgets.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = context.read<AppState>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen();
        }

        return const ShellPage();
      },
    );
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  AppTab _activeTab = AppTab.home;
  bool _showProfile = false;
  String? _selectedRouteId;
  String? _initialChatId;

  @override
  void initState() {
    super.initState();
    pushNotificationService.navigationTarget.addListener(_handlePushNavigation);
  }

  @override
  void dispose() {
    pushNotificationService.navigationTarget.removeListener(
      _handlePushNavigation,
    );
    super.dispose();
  }

  void _handlePushNavigation() {
    final target = pushNotificationService.navigationTarget.value;

    if (target == null || !mounted) {
      return;
    }

    setState(() {
      _showProfile = false;

      if (target.type == PushNavigationType.chat) {
        _selectedRouteId = null;
        _initialChatId = target.id;
        _activeTab = AppTab.chats;
      }

      if (target.type == PushNavigationType.route) {
        _initialChatId = null;
        _selectedRouteId = target.id;
        _activeTab = AppTab.home;
      }
    });

    pushNotificationService.navigationTarget.value = null;
  }

  void _setTab(AppTab tab) {
    setState(() {
      _activeTab = tab;
      _showProfile = false;
      _selectedRouteId = null;
      _initialChatId = null;
    });
  }

  void _openAuth(AuthMode mode) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => AuthPage(mode: mode)));
  }

  void _openProfile() {
    setState(() {
      _showProfile = true;
      _selectedRouteId = null;
      _initialChatId = null;
    });
  }

  void _openRoute(RouteModel route) {
    final appState = context.read<AppState>();

    if (!appState.isAuthenticated) {
      setState(() {
        _activeTab = AppTab.home;
        _showProfile = false;
        _selectedRouteId = null;
        _initialChatId = null;
      });

      _openAuth(AuthMode.login);
      return;
    }

    setState(() {
      _selectedRouteId = route.id;
      _showProfile = false;
      _initialChatId = null;
    });
  }

  void _goBackToCurrentTab() {
    setState(() {
      _showProfile = false;
      _selectedRouteId = null;
      _initialChatId = null;
    });
  }

  Widget _buildCurrentPage() {
    if (_showProfile) {
      return ProfilePage(onBack: _goBackToCurrentTab);
    }

    final appState = context.watch<AppState>();

    if (_selectedRouteId != null && !appState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _activeTab = AppTab.home;
          _showProfile = false;
          _selectedRouteId = null;
          _initialChatId = null;
        });

        _openAuth(AuthMode.login);
      });
    }

    if (_selectedRouteId != null && appState.isAuthenticated) {
      return RouteDetailPage(
        routeId: _selectedRouteId!,
        onBack: _goBackToCurrentTab,
        onOpenAuth: _openAuth,
      );
    }

    return IndexedStack(
      index: _activeTab.index,
      children: [
        HomePage(onOpenRoute: _openRoute, onOpenAuth: _openAuth),
        RoutesPage(onOpenRoute: _openRoute),
        ChatPage(
          key: ValueKey(_initialChatId ?? 'chat'),
          isActive: _activeTab.index == 2,
          initialChatId: _initialChatId,
        ),
        FavoritesPage(onOpenRoute: _openRoute, onOpenAuth: _openAuth),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppTopNav(
                currentUser: appState.currentUser,
                onLogin: () => _openAuth(AuthMode.login),
                onProfile: _openProfile,
                onLogout: () async {
                  await appState.logout();

                  if (!mounted) return;

                  setState(() {
                    _activeTab = AppTab.home;
                    _showProfile = false;
                    _selectedRouteId = null;
                    _initialChatId = null;
                  });
                },
              ),
              Expanded(child: _buildCurrentPage()),
            ],
          ),
          const AccessibilityFloatingButton(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        activeTab: _activeTab,
        onTabSelected: _setTab,
      ),
    );
  }
}

class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();
    final isHighContrast =
        accessibility.colorMode == AccessibilityColorMode.highContrast ||
        accessibility.colorMode == AccessibilityColorMode.darkContrast;
    final backgroundColor = isHighContrast
        ? accessibility.pageBackgroundColor
        : AppColors.backgroundSoft;
    final textColor = accessibility.textColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final wave = math.sin(_controller.value * math.pi * 2);
          final logoScale = 0.96 + (wave * 0.035);

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isHighContrast
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF4F7FB),
                        Color(0xFFFFF4EF),
                      ],
                    ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 210,
                          height: 210,
                          child: CustomPaint(
                            painter: _SplashOrbitPainter(
                              progress: _controller.value,
                              isHighContrast: isHighContrast,
                              foregroundColor: textColor,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: logoScale,
                          child: Container(
                            width: 132,
                            height: 132,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isHighContrast
                                  ? accessibility.surfaceColor
                                  : Colors.white.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                              boxShadow: isHighContrast
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: AppColors.shadowSoft,
                                        blurRadius: 28,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                            ),
                            child: Image.asset(
                              'assets/resources/logos/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Trip2Guide',
                      style: TextStyle(
                        color: textColor,
                        fontFamily: AppFonts.sans,
                        fontFamilyFallback: AppFonts.sansFallback,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preparing your next route',
                      style: TextStyle(
                        color: accessibility.secondaryTextColor,
                        fontFamily: AppFonts.sansAlt,
                        fontFamilyFallback: AppFonts.sansAltFallback,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          backgroundColor: isHighContrast
                              ? accessibility.borderColor
                              : AppColors.borderSoft,
                          color: isHighContrast
                              ? accessibility.textColor
                              : AppColors.positive,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SplashOrbitPainter extends CustomPainter {
  const _SplashOrbitPainter({
    required this.progress,
    required this.isHighContrast,
    required this.foregroundColor,
  });

  final double progress;
  final bool isHighContrast;
  final Color foregroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isHighContrast
          ? foregroundColor.withValues(alpha: 0.08)
          : const Color(0xFFFF7B72).withValues(alpha: 0.10);

    canvas.drawCircle(center, radius * 0.78, glowPaint);

    final colors = isHighContrast
        ? [foregroundColor, foregroundColor, foregroundColor]
        : const [Color(0xFFF3B72F), Color(0xFF63BDE8), Color(0xFFFF766F)];

    for (var i = 0; i < colors.length; i += 1) {
      ringPaint.color = colors[i].withValues(alpha: isHighContrast ? 1 : 0.76);
      final start = (progress * math.pi * 2) + (i * math.pi * 2 / 3);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * (0.64 + i * 0.09)),
        start,
        math.pi * 0.55,
        false,
        ringPaint,
      );
    }

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isHighContrast ? foregroundColor : const Color(0xFF0F1219);
    final dotAngle = progress * math.pi * 2;
    final dotOffset =
        Offset(math.cos(dotAngle), math.sin(dotAngle)) * radius * 0.88;
    canvas.drawCircle(center + dotOffset, 4.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SplashOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isHighContrast != isHighContrast ||
        oldDelegate.foregroundColor != foregroundColor;
  }
}
