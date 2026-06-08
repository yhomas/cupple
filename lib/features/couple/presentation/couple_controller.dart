






import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/couple_repository.dart';
import '../domain/couple_model.dart';

part 'couple_controller.g.dart';

@riverpod
class CoupleController extends _$CoupleController {
  @override
  FutureOr<CoupleModel?> build() async {
    return null;
  }

  Future<CoupleModel> createCouple(String userId) async {
    final repo = ref.read(coupleRepositoryProvider);
    final couple = await repo.createCouple(userId);
    state = AsyncValue.data(couple);
    return couple;
  }

  Future<CoupleModel?> joinCouple(String inviteCode, String userId) async {
    final repo = ref.read(coupleRepositoryProvider);
    final couple = await repo.joinCouple(inviteCode, userId);
    state = AsyncValue.data(couple);
    return couple;
  }
}








