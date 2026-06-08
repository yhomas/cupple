



import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user_model.dart';
import '../domain/couple_model.dart';

class CoupleRepository {
  final FirebaseFirestore _db;
  CoupleRepository(this._db);

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<CoupleModel> createCouple(String userId) async {
    final coupleId = _db.collection('couples').doc().id;
    final inviteCode = _generateInviteCode();
    final couple = CoupleModel(
      coupleId: coupleId,
      userIds: [userId],
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );
    await _db.collection('couples').doc(coupleId).set(couple.toJson());
    await _db.collection('users').doc(userId).update({
      'coupleId': coupleId,
    });
    return couple;
  }

  Future<CoupleModel?> joinCouple(String inviteCode, String userId) async {
    final query = await _db
        .collection('couples')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    final couple = CoupleModel.fromJson(doc.data());
    if (couple.userIds.length >= 2) return null;
    final updatedUserIds = [...couple.userIds, userId];
    await doc.reference.update({'userIds': updatedUserIds});
    await _db.collection('users').doc(userId).update({
      'coupleId': couple.coupleId,
      'partnerUid': couple.userIds.first,
    });
    await _db.collection('users').doc(couple.userIds.first).update({
      'partnerUid': userId,
    });
    return couple.copyWith(userIds: updatedUserIds);
  }

  Future<CoupleModel?> getCouple(String coupleId) async {
    final doc = await _db.collection('couples').doc(coupleId).get();
    if (!doc.exists) return null;
    return CoupleModel.fromJson(doc.data()!);
  }

  Future<UserModel?> getPartner(String coupleId, String myUid) async {
    final couple = await getCouple(coupleId);
    if (couple == null) return null;
    final partnerId = couple.userIds.firstWhere((id) => id != myUid, orElse: () => '');
    if (partnerId.isEmpty) return null;
    final doc = await _db.collection('users').doc(partnerId).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }
}

final coupleRepositoryProvider = Provider<CoupleRepository>((ref) {
  return CoupleRepository(FirebaseFirestore.instance);
});





