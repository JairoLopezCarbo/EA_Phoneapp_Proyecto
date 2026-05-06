import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';

const String sessionKey = 'trip2guide_session';

class StoredSession {
  const StoredSession({required this.token, required this.user});

  final String token;
  final AppUser user;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'token': token,
        'user': user.toJson(),
      };

  factory StoredSession.fromJson(Map<String, dynamic> json) {
    return StoredSession(
      token: json['token'] as String? ?? '',
      user: AppUser.fromJson((json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
    );
  }
}

Future<StoredSession?> getStoredSession() async {
  final preferences = await SharedPreferences.getInstance();
  final rawSession = preferences.getString(sessionKey);

  if (rawSession == null || rawSession.trim().isEmpty) {
    return null;
  }

  try {
    final decoded = jsonDecode(rawSession);
    if (decoded is Map<String, dynamic>) {
      return StoredSession.fromJson(decoded);
    }
  } catch (_) {
    return null;
  }

  return null;
}

Future<void> storeSession({required String token, required AppUser user}) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(sessionKey, jsonEncode(StoredSession(token: token, user: user).toJson()));
}

Future<void> clearStoredSession() async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.remove(sessionKey);
}

Future<void> saveStoredSessionUser(AppUser user) async {
  final session = await getStoredSession();
  if (session == null) {
    return;
  }

  await storeSession(token: session.token, user: user);
}

Future<String?> getStoredToken() async {
  return (await getStoredSession())?.token;
}

Future<AppUser?> getStoredUser() async {
  return (await getStoredSession())?.user;
}

Future<bool> isAuthenticated() async {
  return (await getStoredToken()) != null;
}