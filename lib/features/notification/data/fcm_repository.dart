
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/debug/debug_log.dart';

class FcmRepository {
  final FirebaseFirestore _db;
  final FirebaseMessaging _messaging;

  FcmRepository(this._db, this._messaging);

  Future<String?> getToken() async {
    try {
      dlog("FcmRepository.getToken: requesting permission...");
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      dlog("FcmRepository.getToken: permission=${settings.authorizationStatus}");
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await _messaging.getToken();
        dlog("FcmRepository.getToken: token=$token");
        return token;
      }
      dlog("FcmRepository.getToken: permission denied");
      return null;
    } catch (e) {
      dlog("FcmRepository.getToken: ERROR: $e");
      return null;
    }
  }

  Future<void> saveToken(String uid) async {
    dlog("FcmRepository.saveToken: START, uid=$uid");
    final token = await getToken();
    if (token != null) {
      await _db.collection('users').doc(uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      dlog("FcmRepository.saveToken: token saved");
    }
  }

  Future<String?> getPartnerToken(String coupleId, String myUid) async {
    dlog("FcmRepository.getPartnerToken: START, coupleId=$coupleId");
    try {
      final coupleDoc = await _db.collection('couples').doc(coupleId).get();
      if (!coupleDoc.exists) return null;
      final userIds = List<String>.from(coupleDoc.data()?['userIds'] ?? []);
      final partnerId = userIds.firstWhere((id) => id != myUid, orElse: () => '');
      if (partnerId.isEmpty) return null;
      final partnerDoc = await _db.collection('users').doc(partnerId).get();
      if (!partnerDoc.exists) return null;
      final token = partnerDoc.data()?['fcmToken'] as String?;
      dlog("FcmRepository.getPartnerToken: partnerId=$partnerId, hasToken=${token != null}");
      return token;
    } catch (e) {
      dlog("FcmRepository.getPartnerToken: ERROR: $e");
      return null;
    }
  }
}

final fcmRepositoryProvider = Provider<FcmRepository>((ref) {
  return FcmRepository(FirebaseFirestore.instance, FirebaseMessaging.instance);
});

