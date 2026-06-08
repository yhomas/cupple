


import 'package:cloud_firestore/cloud_firestore.dart';

enum CardType { thankYou, didIt }

enum CardCategory { housework, childcare, work, kindness, other }

class CardModel {
  final String cardId;
  final String coupleId;
  final String senderId;
  final CardType type;
  final CardCategory category;
  final String content;
  final String? stamp;
  final bool isAcknowledged;
  final String? acknowledgementEmoji;
  final DateTime createdAt;

  const CardModel({
    required this.cardId,
    required this.coupleId,
    required this.senderId,
    required this.type,
    required this.category,
    required this.content,
    this.stamp,
    this.isAcknowledged = false,
    this.acknowledgementEmoji,
    required this.createdAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cardId: json['cardId'] as String,
      coupleId: json['coupleId'] as String,
      senderId: json['senderId'] as String,
      type: json['type'] == 'thank_you' ? CardType.thankYou : CardType.didIt,
      category: _parseCategory(json['category'] as String?),
      content: json['content'] as String? ?? '',
      stamp: json['stamp'] as String?,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      acknowledgementEmoji: json['acknowledgementEmoji'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  static CardCategory _parseCategory(String? value) {
    switch (value) {
      case 'housework':
        return CardCategory.housework;
      case 'childcare':
        return CardCategory.childcare;
      case 'work':
        return CardCategory.work;
      case 'kindness':
        return CardCategory.kindness;
      default:
        return CardCategory.other;
    }
  }

  static String categoryToString(CardCategory cat) {
    switch (cat) {
      case CardCategory.housework:
        return 'housework';
      case CardCategory.childcare:
        return 'childcare';
      case CardCategory.work:
        return 'work';
      case CardCategory.kindness:
        return 'kindness';
      case CardCategory.other:
        return 'other';
    }
  }

  static String categoryLabel(CardCategory cat) {
    switch (cat) {
      case CardCategory.housework:
        return '家事';
      case CardCategory.childcare:
        return '育児';
      case CardCategory.work:
        return '仕事';
      case CardCategory.kindness:
        return '気配り';
      case CardCategory.other:
        return 'その他';
    }
  }

  static String typeLabel(CardType type) {
    return type == CardType.thankYou ? 'ありがとう' : 'やったよ';
  }

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'coupleId': coupleId,
      'senderId': senderId,
      'type': type == CardType.thankYou ? 'thank_you' : 'did_it',
      'category': categoryToString(category),
      'content': content,
      'stamp': stamp,
      'isAcknowledged': isAcknowledged,
      'acknowledgementEmoji': acknowledgementEmoji,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CardModel copyWith({
    String? cardId,
    String? coupleId,
    String? senderId,
    CardType? type,
    CardCategory? category,
    String? content,
    String? stamp,
    bool? isAcknowledged,
    String? acknowledgementEmoji,
    DateTime? createdAt,
  }) {
    return CardModel(
      cardId: cardId ?? this.cardId,
      coupleId: coupleId ?? this.coupleId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      category: category ?? this.category,
      content: content ?? this.content,
      stamp: stamp ?? this.stamp,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgementEmoji: acknowledgementEmoji ?? this.acknowledgementEmoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}



