import 'package:flutter/widgets.dart';
import 'package:phoneapp/src/app_localizations.dart';

import '../models/app_models.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

String localizedDifficulty(BuildContext context, RouteDifficulty difficulty) {
  return switch (difficulty) {
    RouteDifficulty.easy => context.l10n.difficultyEasy,
    RouteDifficulty.medium => context.l10n.difficultyMedium,
    RouteDifficulty.hard => context.l10n.difficultyHard,
  };
}

String localizedRatingLabel(BuildContext context, String key) {
  return switch (key.toLowerCase()) {
    'scenery' => context.l10n.scenery,
    'signage' => context.l10n.signage,
    'accessibility' => context.l10n.accessibility,
    'safety' => context.l10n.safety,
    _ => key,
  };
}

String localizedError(BuildContext context, Object error) {
  final l10n = context.l10n;
  final message = error.toString().replaceFirst(
    RegExp(r'^(Exception|StateError|FormatException):\s*'),
    '',
  );

  return switch (message) {
    'Invalid credentials.' => l10n.errorInvalidCredentials,
    'Google login failed.' => l10n.errorGoogleLoginFailed,
    'Unable to register the user.' => l10n.errorRegistrationFailed,
    'User session not found.' => l10n.errorUserSessionNotFound,
    'Route not found.' => l10n.errorRouteNotFound,
    'You need to log in to create routes.' => l10n.errorLoginToCreateRoutes,
    'You need to log in to save favorites.' => l10n.errorLoginToSaveFavorites,
    'Request failed.' => l10n.errorRequestFailed,
    'Pedro returned invalid JSON.' => l10n.pedroError,
    _ => message.isEmpty ? l10n.errorUnknown : message,
  };
}
