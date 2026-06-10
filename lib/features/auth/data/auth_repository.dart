
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/debug/debug_log.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;
  AuthRepository(this._auth, this._db);

  fb.User? get currentUser => _auth.currentUser;
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signInWithEmail(String email, String password) async {
    dlog("signInWithEmail: START, email=$email");
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;
      dlog("signInWithEmail: auth SUCCESS, uid=${user.uid}");
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      dlog("signInWithEmail: user doc set OK");
      return UserModel(
        uid: user.uid,
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
    } catch (e, st) {
      dlog("signInWithEmail: ERROR: $e");
      dlog("signInWithEmail: STACK: $st");
      rethrow;
    }
  }

  Future<UserModel> signUpWithEmail(String email, String password, String displayName) async {
    dlog("signUpWithEmail: START, email=$email");
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;
      dlog("signUpWithEmail: auth SUCCESS, uid=${user.uid}");
      await user.updateDisplayName(displayName);
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'displayName': displayName,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
      dlog("signUpWithEmail: user doc set OK");
      return UserModel(
        uid: user.uid,
        displayName: displayName,
        createdAt: DateTime.now(),
      );
    } catch (e, st) {
      dlog("signUpWithEmail: ERROR: $e");
      dlog("signUpWithEmail: STACK: $st");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(fb.FirebaseAuth.instance, FirebaseFirestore.instance);
});

