




import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<UserModel?> build() {
    final repo = ref.watch(authRepositoryProvider);
    return repo.authStateChanges.asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return UserModel(
        uid: fbUser.uid,
        displayName: fbUser.displayName ?? '',
        photoUrl: fbUser.photoURL,
        createdAt: DateTime.now(),
      );
    });
  }

  Future<void> signIn(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signInWithEmail(email, password);
  }

  Future<void> signUp(String email, String password, String displayName) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signUpWithEmail(email, password, displayName);
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
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






