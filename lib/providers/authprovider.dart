import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/controller/auth_controller.dart';

final firebaseAuthProvider = Provider((_) => FirebaseAuth.instance);

final googleSignInProvider = Provider<GoogleSignIn>(
  (_) => GoogleSignIn.instance,
);

final authRemoteDataSourceProvider = Provider(
  (ref) => AuthRemoteDataSourceImpl(
    ref.read(firebaseAuthProvider),
    ref.read(googleSignInProvider),
  ),
);

final authRepositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider)),
);

final authControllerProvider = Provider(
  (ref) => AuthController(ref.read(authRepositoryProvider)),
);
