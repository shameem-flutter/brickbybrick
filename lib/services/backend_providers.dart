import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brickbybrick/services/auth_service.dart';
import 'package:brickbybrick/services/firestore_service.dart';
import 'package:brickbybrick/services/storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Stream of authentication state
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Current User ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.value?.uid;
});
