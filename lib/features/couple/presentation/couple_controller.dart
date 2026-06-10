




import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/debug/debug_log.dart';
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
    dlog("CoupleController.createCouple: START, userId=$userId");
    final repo = ref.read(coupleRepositoryProvider);
    final couple = await repo.createCouple(userId);
    dlog("CoupleController.createCouple: SUCCESS, code=${couple.inviteCode}");
    state = AsyncValue.data(couple);
    return couple;
  }

  Future<CoupleModel?> joinCouple(String inviteCode, String userId) async {
    dlog("CoupleController.joinCouple: START, code=$inviteCode, userId=$userId");
    final repo = ref.read(coupleRepositoryProvider);
    final couple = await repo.joinCouple(inviteCode, userId);
    dlog("CoupleController.joinCouple: result=${couple?.coupleId ?? "null"}");
    state = AsyncValue.data(couple);
    return couple;
  }
}





