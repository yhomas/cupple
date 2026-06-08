









import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/cards_repository.dart';
import '../domain/card_model.dart';

part 'card_controller.g.dart';

@riverpod
class CardController extends _$CardController {
  @override
  FutureOr<void> build() {}

  Future<void> createCard({
    required String coupleId,
    required String senderId,
    required CardType type,
    required CardCategory category,
    required String content,
    String? stamp,
  }) async {
    final repo = ref.read(cardsRepositoryProvider);
    final card = CardModel(
      cardId: FirebaseFirestore.instance.collection('cards').doc().id,
      coupleId: coupleId,
      senderId: senderId,
      type: type,
      category: category,
      content: content,
      stamp: stamp,
      createdAt: DateTime.now(),
    );
    await repo.createCard(card);
  }

  Future<void> acknowledgeCard(String cardId, String emoji) async {
    final repo = ref.read(cardsRepositoryProvider);
    await repo.acknowledgeCard(cardId, emoji);
  }
}

@riverpod
Stream<List<CardModel>> timelineCards(TimelineCardsRef ref, String coupleId) {
  final repo = ref.watch(cardsRepositoryProvider);
  return repo.getCardsStream(coupleId);
}












