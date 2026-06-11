import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/debug/debug_log.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<UserModel?> build() {
    dlog("AuthController.build: starting stream");
    return FirebaseAuth.instance.authStateChanges().asyncMap((fbUser) async {
      dlog("AuthController.build: fbUser=${fbUser?.uid}");
      if (fbUser == null) return null;
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).get();
        dlog("AuthController.build: doc.exists=${doc.exists}, data=${doc.data()}");
        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data()!);
        }
      } catch (e) {
        dlog("AuthController.build: Firestore read error: $e");
      }
      dlog("AuthController.build: returning fallback UserModel (no coupleId)");
      return UserModel(
        uid: fbUser.uid,
        displayName: fbUser.displayName ?? '',
        photoUrl: fbUser.photoURL,
        createdAt: DateTime.now(),
      );
    });
  }

  Future<void> signIn(String email, String password) async {
    dlog("AuthController.signIn: START");
    final repo = ref.read(authRepositoryProvider);
    await repo.signInWithEmail(email, password);
    dlog("AuthController.signIn: DONE");
  }

  Future<void> signUp(String email, String password, String displayName) async {
    dlog("AuthController.signUp: START");
    final repo = ref.read(authRepositoryProvider);
    await repo.signUpWithEmail(email, password, displayName);
    dlog("AuthController.signUp: DONE");
  }

  Future<void> signOut() async {
    dlog("AuthController.signOut: START");
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    dlog("AuthController.signOut: DONE");
  }

  Future<void> updateDisplayName(String uid, String displayName) async {
    dlog("AuthController.updateDisplayName: START");
    final repo = ref.read(authRepositoryProvider);
    await repo.updateDisplayName(uid, displayName);
    dlog("AuthController.updateDisplayName: DONE");
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    dlog("AuthController.updatePassword: START");
    final repo = ref.read(authRepositoryProvider);
    await repo.updatePassword(currentPassword, newPassword);
    dlog("AuthController.updatePassword: DONE");
  }

  Future<void> updateAvatar(String uid, Uint8List imageBytes) async {
    dlog("AuthController.updateAvatar: START");
    final repo = ref.read(authRepositoryProvider);
    final photoUrl = await repo.uploadAvatar(uid, imageBytes);
    await repo.updatePhotoUrl(uid, photoUrl);
    dlog("AuthController.updateAvatar: DONE");
  }
}

@riverpod
UserModel? currentUser(CurrentUserRef ref) {
  final asyncUser = ref.watch(authControllerProvider);
  return asyncUser.when(
    data: (user) => user,
    loading: () => null,
    error: (_, _) => null,
  );
}
