import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app_shell.dart';
import 'src/state/accessibility_state.dart';
import 'src/state/app_state.dart';
import 'src/theme/theme.dart';
import 'src/widgets/accessibility_widgets.dart';

void main() {
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
