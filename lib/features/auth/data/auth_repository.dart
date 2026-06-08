

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final fb.FirebaseAuth _auth;
  AuthRepository(this._auth);

  fb.User? get currentUser => _auth.currentUser;
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    return UserModel(
      uid: user.uid,
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
  }

  Future<UserModel> signUpWithEmail(String email, String password, String displayName) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(displayName);
    return UserModel(
      uid: user.uid,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(fb.FirebaseAuth.instance);
});



