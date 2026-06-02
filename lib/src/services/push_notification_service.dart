import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'api_client.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

enum PushNavigationType { chat, route }

class PushNavigationTarget {
  const PushNavigationTarget._({required this.type, required this.id});

  factory PushNavigationTarget.chat(String chatId) {
    return PushNavigationTarget._(type: PushNavigationType.chat, id: chatId);
  }

  factory PushNavigationTarget.route(String routeId) {
    return PushNavigationTarget._(type: PushNavigationType.route, id: routeId);
  }

  final PushNavigationType type;
  final String id;
}

class PushNotificationService {
  final ValueNotifier<PushNavigationTarget?> navigationTarget =
      ValueNotifier<PushNavigationTarget?>(null);

  bool _listenersConfigured = false;

  Future<void> configureForUser(String userId, {required String? token}) async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      return;
    }

    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null && fcmToken.trim().isNotEmpty) {
      await _sendTokenToBackend(userId, fcmToken, token: token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      if (newToken.trim().isEmpty) return;

      _sendTokenToBackend(userId, newToken, token: token);
    });

    if (_listenersConfigured) return;

    _listenersConfigured = true;

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNavigationMessage);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleNavigationMessage(initialMessage);
    }
  }

  Future<void> unregisterForUser(
    String userId, {
    required String? token,
  }) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null || fcmToken.trim().isEmpty) {
      return;
    }

    await apiClient.deleteJson(
      '/users/${Uri.encodeComponent(userId)}/fcm-token',
      token: token,
      body: {'token': fcmToken},
    );
  }

  Future<void> _sendTokenToBackend(
    String userId,
    String fcmToken, {
    required String? token,
  }) async {
    await apiClient.postJson(
      '/users/${Uri.encodeComponent(userId)}/fcm-token',
      token: token,
      body: {'token': fcmToken, 'platform': _platform},
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notificación';
    final body = message.notification?.body ?? '';

    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(body.isEmpty ? title : '$title\n$body'),
        action: SnackBarAction(
          label: 'Abrir',
          onPressed: () => _handleNavigationMessage(message),
        ),
      ),
    );
  }

  void _handleNavigationMessage(RemoteMessage message) {
    final type = message.data['type'];

    if (type == 'chat') {
      final chatId = message.data['chatId'];

      if (chatId is String && chatId.trim().isNotEmpty) {
        navigationTarget.value = PushNavigationTarget.chat(chatId);
      }

      return;
    }

    if (type == 'route') {
      final routeId = message.data['routeId'];

      if (routeId is String && routeId.trim().isNotEmpty) {
        navigationTarget.value = PushNavigationTarget.route(routeId);
      }
    }
  }

  String get _platform {
    if (kIsWeb) return 'web';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'android';
    }
  }
}

final pushNotificationService = PushNotificationService();
