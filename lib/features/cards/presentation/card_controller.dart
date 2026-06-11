import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/debug/debug_log.dart';
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
    String? senderName,
  }) async {
    dlog("CardController.createCard: START, coupleId=$coupleId, senderId=$senderId, type=$type");
    try {
      final repo = ref.read(cardsRepositoryProvider);
      final card = CardModel(
        cardId: FirebaseFirestore.instance.collection('cards').doc().id,
        coupleId: coupleId,
        senderId: senderId,
        senderName: senderName,
        type: type,
        category: category,
        content: content,
        stamp: stamp,
        createdAt: DateTime.now(),
      );
      dlog("CardController.createCard: cardId=${card.cardId}");
      await repo.createCard(card);
      dlog("CardController.createCard: DONE");
    } catch (e, st) {
      dlog("CardController.createCard: ERROR: $e");
      dlog("CardController.createCard: STACK: $st");
      rethrow;
    }
  }

  Future<void> acknowledgeCard(String cardId, String emoji) async {
    dlog("CardController.acknowledgeCard: START, cardId=$cardId");
    final repo = ref.read(cardsRepositoryProvider);
    await repo.acknowledgeCard(cardId, emoji);
    dlog("CardController.acknowledgeCard: DONE");
  }
}

@riverpod
Stream<List<CardModel>> timelineCards(TimelineCardsRef ref, String coupleId) {
  dlog("timelineCards: START, coupleId=$coupleId");
  final repo = ref.watch(cardsRepositoryProvider);
  return repo.getCardsStream(coupleId);
}
