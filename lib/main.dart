import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app_shell.dart';
import 'src/state/accessibility_state.dart';
import 'src/state/app_state.dart';
import 'src/theme/theme.dart';
import 'src/widgets/accessibility_widgets.dart';

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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const Trip2GuideApp());
}

class Trip2GuideApp extends StatelessWidget {
  const Trip2GuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<AccessibilityState>(
          create: (_) => AccessibilityState()..load(),
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Trip2Guide',
        theme: AppTheme.light(),
        builder: (context, child) {
          return AccessibilityAppWrapper(
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const AppBootstrap(),
      ),
    );
  }
}
