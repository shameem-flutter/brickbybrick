import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController {
  final AuthRepository repo;

  AuthController(this.repo);

  Future<void> signUp({required String email, required String password}) {
    return repo.signUpWithEmail(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) {
    return repo.signInWithEmail(email: email, password: password);
  }

  Future<void> signInWithGoogle() {
    return repo.signInWithGoogle();
  }

  Future<void> signOut() {
    return repo.signOut();
  }
}
