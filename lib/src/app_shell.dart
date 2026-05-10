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
import 'state/app_state.dart';
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

  void _setTab(AppTab tab) {
    setState(() {
      _activeTab = tab;
      _showProfile = false;
      _selectedRouteId = null;
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
    });
  }

  void _openRoute(RouteModel route) {
    setState(() {
      _selectedRouteId = route.id;
      _showProfile = false;
    });
  }

  void _goBackToCurrentTab() {
    setState(() {
      _showProfile = false;
      _selectedRouteId = null;
    });
  }

  Widget _buildCurrentPage() {
    if (_showProfile) {
      return ProfilePage(onBack: _goBackToCurrentTab);
    }

    if (_selectedRouteId != null) {
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
        ChatPage(isActive: _activeTab.index == 2),
        FavoritesPage(onOpenRoute: _openRoute, onOpenAuth: _openAuth),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Column(
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
              });
            },
          ),
          Expanded(child: _buildCurrentPage()),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        activeTab: _activeTab,
        onTabSelected: _setTab,
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F8FB), Color(0xFFF1F3F7)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading Trip2Guide...',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
