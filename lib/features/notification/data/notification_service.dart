

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/debug/debug_log.dart';
import '../../cards/domain/card_model.dart';

class NotificationService {
  final FirebaseFirestore _db;
  NotificationService(this._db);

  Future<void> sendCardNotification({
    required String coupleId,
    required String senderId,
    required String senderName,
    required CardModel card,
  }) async {
    dlog("NotificationService.sendCardNotification: START");
    try {
      final coupleDoc = await _db.collection('couples').doc(coupleId).get();
      if (!coupleDoc.exists) return;
      final userIds = List<String>.from(coupleDoc.data()?['userIds'] ?? []);
      final partnerId = userIds.firstWhere((id) => id != senderId, orElse: () => '');
      if (partnerId.isEmpty) return;

      final partnerDoc = await _db.collection('users').doc(partnerId).get();
      if (!partnerDoc.exists) return;
      final token = partnerDoc.data()?['fcmToken'] as String?;
      if (token == null || token.isEmpty) {
        dlog("NotificationService.sendCardNotification: partner has no FCM token");
        return;
      }

      final typeLabel = CardModel.typeLabel(card.type);
      final title = '$senderName さんが投稿しました';
      final body = '$typeLabel: ${card.content}';

      await _db.collection('notifications').add({
        'to': partnerId,
        'fcmToken': token,
        'title': title,
        'body': body,
        'data': {
          'cardId': card.cardId,
          'type': card.type == CardType.thankYou ? 'thank_you' : 'did_it',
          'senderName': senderName,
        },
        'sent': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      dlog("NotificationService.sendCardNotification: notification doc created");
    } catch (e) {
      dlog("NotificationService.sendCardNotification: ERROR: $e");
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FirebaseFirestore.instance);
});


