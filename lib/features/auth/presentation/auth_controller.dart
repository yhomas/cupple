import 'dart:async';
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
  StreamSubscription<dynamic>? _userSub;

  @override
  Stream<UserModel?> build() {
    dlog("AuthController.build: starting stream");
    final controller = StreamController<UserModel?>();

    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((fbUser) async {
      dlog("AuthController.build: authStateChanges fbUser=${fbUser?.uid}");
      await _userSub?.cancel();
      if (fbUser == null) {
        controller.add(null);
        return;
      }
      // Listen to Firestore document snapshots
      _userSub = FirebaseFirestore.instance
          .collection('users')
          .doc(fbUser.uid)
          .snapshots()
          .listen((snap) {
        dlog("AuthController.build: snapshot received, exists=${snap.exists}");
        if (snap.exists && snap.data() != null) {
          final user = UserModel.fromJson(snap.data()!);
          controller.add(user);
        } else {
          controller.add(null);
        }
      }, onError: (e) {
        dlog("AuthController.build: snapshot error: $e");
        controller.add(null);
      });
    });

    controller.onCancel = () {
      _userSub?.cancel();
    };

    return controller.stream;
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
    try {
      final repo = ref.read(authRepositoryProvider);
      dlog("AuthController.updateAvatar: calling uploadAvatar...");
      final photoUrl = await repo.uploadAvatar(uid, imageBytes);
      dlog("AuthController.updateAvatar: photoUrl=$photoUrl");
      dlog("AuthController.updateAvatar: calling updatePhotoUrl...");
      await repo.updatePhotoUrl(uid, photoUrl);
      dlog("AuthController.updateAvatar: DONE - Firestore updated, stream will auto-refresh");
    } catch (e, st) {
      dlog("AuthController.updateAvatar: ERROR: $e");
      dlog("AuthController.updateAvatar: STACK: $st");
      rethrow;
    }
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
