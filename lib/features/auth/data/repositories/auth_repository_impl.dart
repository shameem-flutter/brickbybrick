import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return remote.signUpWithEmail(email: email, password: password);
  }

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return remote.signInWithEmail(email: email, password: password);
  }

  @override
  Future<UserCredential> signInWithGoogle() {
    return remote.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return remote.signOut();
  }
}
