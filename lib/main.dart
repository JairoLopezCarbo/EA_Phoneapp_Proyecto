import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app_shell.dart';
import 'src/state/app_state.dart';
import 'src/theme/app_theme.dart';

void main() {
  runApp(const Trip2GuideApp());
}

class Trip2GuideApp extends StatelessWidget {
  const Trip2GuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trip2Guide',
        theme: AppTheme.light(),
        home: const AppBootstrap(),
      ),
    );
  }
}
