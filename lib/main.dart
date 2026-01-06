import 'package:brickbybrick/screens/approot.dart';
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
      title: 'Low Budget',
      theme: AppTheme.darkTheme,
      home: AppRoot(),
      debugShowCheckedModeBanner: false,
    );
  }
}
