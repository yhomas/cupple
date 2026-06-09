

# Firestore セットアップガイド

## インデックス設定

タイムラインのリアルタイム同期には複合インデックスが必要です。

### 方法1: Firebase CLI でデプロイ
```bash
firebase deploy --only firestore:indexes
```

### 方法2: 手動作成
1. Firebase Console → Firestore → インデックス → 複合インデックスを作成
2. コレクション: `cards`
3. フィールド: `coupleId` (昇順) + `createdAt` (降順)

## セキュリティルール

```bash
firebase deploy --only firestore:rules
```

## ルール概要

| コレクション | 作成 | 読み取り | 更新 | 削除 |
|-------------|------|---------|------|------|
| users | 本人のみ | 認証済み | 本人のみ | ✗ |
| couples | 認証済み | メンバーのみ | メンバーのみ | ✗ |
| cards | メンバーのみ | メンバーのみ | 承認のみ | ✗ |

## データ構造

```
users/{userId}
  - uid: string
  - displayName: string
  - photoUrl: string?
  - partnerUid: string?
  - coupleId: string?
  - createdAt: timestamp

couples/{coupleId}
  - coupleId: string
  - userIds: string[]
  - inviteCode: string
  - createdAt: timestamp

cards/{cardId}
  - cardId: string
  - coupleId: string
  - senderId: string
  - type: "thank_you" | "did_it"
  - category: "housework" | "childcare" | "work" | "kindness" | "other"
  - content: string
  - stamp: string?
  - isAcknowledged: bool
  - acknowledgementEmoji: string?
  - createdAt: timestamp

