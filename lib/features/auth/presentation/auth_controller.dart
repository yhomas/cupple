import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/debug/debug_log.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<UserModel?> build() {
    final repo = ref.watch(authRepositoryProvider);
    return repo.authStateChanges.asyncMap((fbUser) async {
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
