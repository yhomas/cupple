




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/card_model.dart';

class CardsRepository {
  final FirebaseFirestore _db;
  CardsRepository(this._db);

  Future<void> createCard(CardModel card) async {
    await _db.collection('cards').doc(card.cardId).set(card.toJson());
  }

  Stream<List<CardModel>> getCardsStream(String coupleId) {
    return _db
        .collection('cards')
        .where('coupleId', isEqualTo: coupleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CardModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> acknowledgeCard(String cardId, String emoji) async {
    await _db.collection('cards').doc(cardId).update({
      'isAcknowledged': true,
      'acknowledgementEmoji': emoji,
    });
  }

  Future<List<CardModel>> getCardsByCouple(String coupleId) async {
    final snapshot = await _db
        .collection('cards')
        .where('coupleId', isEqualTo: coupleId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => CardModel.fromJson(doc.data())).toList();
  }
}

final cardsRepositoryProvider = Provider<CardsRepository>((ref) {
  return CardsRepository(FirebaseFirestore.instance);
});






