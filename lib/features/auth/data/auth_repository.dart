
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/debug/debug_log.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  AuthRepository(this._auth, this._db, [FirebaseStorage? storage])
      : _storage = storage ?? FirebaseStorage.instance;

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

  Future<void> updateDisplayName(String uid, String displayName) async {
    dlog("updateDisplayName: uid=$uid, name=$displayName");
    await _auth.currentUser?.updateDisplayName(displayName);
    await _db.collection('users').doc(uid).set({
      'displayName': displayName,
    }, SetOptions(merge: true));
    dlog("updateDisplayName: DONE");
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    dlog("updatePassword: START");
    final user = _auth.currentUser;
    if (user == null) throw Exception('ログインしていません');
    final email = user.email;
    if (email == null) throw Exception('メールアドレスが設定されていません');
    final credential = fb.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
    dlog("updatePassword: DONE");
  }

  Future<String> uploadAvatar(String uid, Uint8List imageBytes) async {
    dlog("uploadAvatar: uid=$uid, bytes=${imageBytes.length}");
    try {
      final ref = _storage.ref().child('avatars/$uid.jpg');
      dlog("uploadAvatar: ref=${ref.fullPath}");
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      dlog("uploadAvatar: putting data...");
      final uploadTask = ref.putData(imageBytes, metadata);
      final snapshot = await uploadTask;
      dlog("uploadAvatar: upload complete, state=${snapshot.state}");
      final url = await ref.getDownloadURL();
      dlog("uploadAvatar: url=$url");
      return url;
    } catch (e, st) {
      dlog("uploadAvatar: ERROR: $e");
      dlog("uploadAvatar: STACK: $st");
      rethrow;
    }
  }

  Future<void> updatePhotoUrl(String uid, String photoUrl) async {
    dlog("updatePhotoUrl: uid=$uid");
    await _db.collection('users').doc(uid).set({
      'photoUrl': photoUrl,
    }, SetOptions(merge: true));
    dlog("updatePhotoUrl: DONE");
  }

  bool get isEmailUser => _auth.currentUser?.email != null;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(fb.FirebaseAuth.instance, FirebaseFirestore.instance, FirebaseStorage.instance);
});

