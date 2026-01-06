import 'package:brickbybrick/services/backend_providers.dart';
import 'package:brickbybrick/screens/homescreen.dart';
import 'package:brickbybrick/screens/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        } else {
          return const Homescreen();
        }
      },
    );
  }
}
