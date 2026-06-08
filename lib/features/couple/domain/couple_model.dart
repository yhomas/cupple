

import 'package:cloud_firestore/cloud_firestore.dart';

class CoupleModel {
  final String coupleId;
  final List<String> userIds;
  final String inviteCode;
  final DateTime createdAt;

  const CoupleModel({
    required this.coupleId,
    required this.userIds,
    required this.inviteCode,
    required this.createdAt,
  });

  factory CoupleModel.fromJson(Map<String, dynamic> json) {
    return CoupleModel(
      coupleId: json['coupleId'] as String,
      userIds: (json['userIds'] as List<dynamic>).cast<String>(),
      inviteCode: json['inviteCode'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupleId': coupleId,
      'userIds': userIds,
      'inviteCode': inviteCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CoupleModel copyWith({
    String? coupleId,
    List<String>? userIds,
    String? inviteCode,
    DateTime? createdAt,
  }) {
    return CoupleModel(
      coupleId: coupleId ?? this.coupleId,
      userIds: userIds ?? this.userIds,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


