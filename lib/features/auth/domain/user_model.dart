
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final String? partnerUid;
  final String? coupleId;
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    this.partnerUid,
    this.coupleId,
    this.fcmToken,
    required this.createdAt,
  });

  bool get isLinked => partnerUid != null && coupleId != null;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      partnerUid: json['partnerUid'] as String?,
      coupleId: json['coupleId'] as String?,
      fcmToken: json['fcmToken'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'partnerUid': partnerUid,
      'coupleId': coupleId,
      if (fcmToken != null) 'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? photoUrl,
    String? partnerUid,
    String? coupleId,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      partnerUid: partnerUid ?? this.partnerUid,
      coupleId: coupleId ?? this.coupleId,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

