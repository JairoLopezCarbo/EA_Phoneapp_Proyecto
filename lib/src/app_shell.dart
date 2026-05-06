import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_models.dart';
import 'pages/auth_page.dart';
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

  void _setTab(AppTab tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  void _openAuth(AuthMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AuthPage(mode: mode),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProfilePage(),
      ),
    );
  }

  void _openRoute(RouteModel route) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RouteDetailPage(routeId: route.id),
      ),
    );
  }

  void _openChats() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chats are not available in this mobile build yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Column(
        children: [
          AppTopNav(
            activeTab: _activeTab,
            currentUser: appState.currentUser,
            onTabSelected: _setTab,
            onLogin: () => _openAuth(AuthMode.login),
            onRegister: () => _openAuth(AuthMode.register),
            onProfile: _openProfile,
            onLogout: () async {
              await appState.logout();
              if (mounted) {
                setState(() {
                  _activeTab = AppTab.home;
                });
              }
            },
            onChats: _openChats,
          ),
          Expanded(
            child: IndexedStack(
              index: _activeTab.index,
              children: [
                HomePage(
                  onOpenRoute: _openRoute,
                  onOpenAuth: _openAuth,
                ),
                RoutesPage(onOpenRoute: _openRoute),
                FavoritesPage(
                  onOpenRoute: _openRoute,
                  onOpenAuth: _openAuth,
                ),
                const SizedBox.shrink(),
              ],
            ),
          ),
        ],
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
