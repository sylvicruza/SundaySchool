import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';

import 'services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataService().init();
  runApp(const OpenedHeavensApp());
}

class OpenedHeavensApp extends StatelessWidget {
  const OpenedHeavensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Opened Heavens',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}
