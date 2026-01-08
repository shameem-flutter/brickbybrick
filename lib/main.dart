import 'package:brickbybrick/screens/approot.dart';
import 'package:brickbybrick/screens/profile_screen.dart';
import 'package:brickbybrick/screens/savings_goals_screen.dart';
import 'package:brickbybrick/screens/growth_screen.dart';
import 'package:brickbybrick/utilities/app_theme.dart';
import 'package:brickbybrick/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrickByBrick',
      theme: AppTheme.lightTheme,
      home: const AppRoot(),
      routes: {
          '/profile': (context) => const ProfileScreen(),
          '/savings-goals': (context) => const SavingsGoalsScreen(),
          '/growth': (context) => const GrowthScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
