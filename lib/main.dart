import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:phoneapp/src/app_localizations.dart';

import 'src/app_shell.dart';
import 'src/state/accessibility_state.dart';
import 'src/state/app_state.dart';
import 'src/state/locale_state.dart';
import 'src/theme/theme.dart';
import 'src/utils/localization.dart';
import 'src/widgets/accessibility_widgets.dart';
import 'src/widgets/pedro_assistant.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'src/services/push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeState = await LocaleState.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(Trip2GuideApp(localeState: localeState));
}

class Trip2GuideApp extends StatelessWidget {
  const Trip2GuideApp({super.key, this.localeState});

  final LocaleState? localeState;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<LocaleState>(
          create: (_) => localeState ?? LocaleState.forTest(),
        ),
        ChangeNotifierProvider<AccessibilityState>(
          create: (_) => AccessibilityState()..load(),
        ),
      ],
      child: Consumer<LocaleState>(
        builder: (context, localeState, _) => MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => context.l10n.appTitle,
          theme: AppTheme.light(),
          locale: localeState.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            final languageCode = locale?.languageCode.toLowerCase();
            return supportedLocales.firstWhere(
              (supported) => supported.languageCode == languageCode,
              orElse: () => const Locale('en'),
            );
          },
          builder: (context, child) {
            return AccessibilityAppWrapper(
              child: PedroAssistant(child: child ?? const SizedBox.shrink()),
            );
          },
          home: const AppBootstrap(),
        ),
      ),
    );
  }
}
