# Cupple 開発ガイド

## 概要

Cupple は Flutter で開発された夫婦向け感謝共有アプリです。Firebase（Auth / Firestore / Storage）をバックエンドとして使用し、Web ホスティングは Firebase Hosting で行います。

---

## 1. 必要なツール

| ツール | バージョン | 備考 |
|--------|-----------|------|
| Flutter SDK | 3.44.2 (stable) | Dart 3.12.2 を含む |
| Firebase CLI | 15.20.0+ | `npm install -g firebase-tools` |
| Node.js | v22.x | Firebase CLI の動作に必要 |
| Git | 任意 | ソース管理 |

---

## 2. 環境構築手順

### 2.1 Flutter SDK のインストール

```bash
# Flutter SDK をダウンロードして展開
# https://docs.flutter.dev/get-started/install

# パスを通す（/opt/flutter に配置した場合）
export PATH="/opt/flutter/bin:$PATH"

# 確認
flutter --version
# → Flutter 3.44.2 • channel stable • Dart 3.12.2
```

### 2.2 Firebase CLI のインストール

```bash
npm install -g firebase-tools

# 確認
firebase --version
# → 15.20.0
```

### 2.3 Firebase ログイン

```bash
firebase login
# ブラウザが開くので、プロジェクトにアクセス権限のある Google アカウントでログイン
```

### 2.4 リポジトリのクローン

```bash
git clone https://github.com/yhomas/cupple.git
cd cupple
```

### 2.5 Flutter 依存パッケージのインストール

```bash
export PATH="/opt/flutter/bin:$PATH"
flutter pub get
```

### 2.6 Firebase 設定ファイルの確認

以下のファイルがリポジトリに含まれていることを確認してください：

- `lib/firebase_options.dart` — Firebase プロジェクトの設定（`flutterfire configure` で生成）
- `.firebaserc` — デフォルトプロジェクトの指定
- `firebase.json` — Hosting / Firestore / Storage の設定

---

## 3. プロジェクト構成

```
cupple/
├── lib/
│   ├── main.dart                    # エントリポイント（Firebase 初期化）
│   ├── app.dart                     # CuppleApp（MaterialApp.router + DebugOverlay）
│   ├── firebase_options.dart        # Firebase 設定（自動生成）
│   ├── core/
│   │   ├── debug/                   # デバッグ用オーバーレイ
│   │   ├── router/                  # GoRouter ルーティング
│   │   ├── theme/                   # テーマ・ダークモード切替
│   │   └── ...
│   ├── features/
│   │   ├── auth/                    # 認証機能
│   │   ├── cards/                   # カード機能（タイムライン等）
│   │   ├── report/                  # レポート機能
│   │   └── ...
│   └── ...
├── web/                             # Web ビルド関連
│   ├── index.html
│   ├── flutter_bootstrap.js
│   └── ...
├── firebase.json                    # Firebase 設定
├── firestore.rules                  # Firestore セキュリティルール
├── firestore.indexes.json           # Firestore インデックス
├── storage.rules                    # Storage セキュリティルール
├── pubspec.yaml                     # Flutter 依存パッケージ
└── .firebaserc                      # Firebase プロジェクト紐付け
```

---

## 4. 主要な依存パッケージ

| パッケージ | 用途 |
|-----------|------|
| `flutter_riverpod` | 状態管理 |
| `firebase_core` | Firebase 初期化 |
| `firebase_auth` | 認証 |
| `cloud_firestore` | データベース |
| `firebase_storage` | ファイルストレージ |
| `go_router` | ルーティング |
| `google_fonts` | フォント |
| `image_picker` | 画像選択 |

---

## 5. 開発ワークフロー

### 5.1 ローカル開発サーバーの起動

```bash
export PATH="/opt/flutter/bin:$PATH"
flutter run -d chrome
```

### 5.2 コード変更後のホットリロード

ブラウザで `r` キーを押す（フルリロードは `R` キー）。

### 5.3 Riverpod コード生成

Provider のコード生成を行う場合：

```bash
export PATH="/opt/flutter/bin:$PATH"
dart run build_runner build --delete-conflicting-outputs
```

---

## 6. ビルド & デプロイ

### 6.1 Web ビルド

```bash
export PATH="/opt/flutter/bin:$PATH"

# ⚠️ 重要: ビルド前に古い main.dart.js を削除する
# 古いファイルが残っていると dart2js のコンパイルがスキップされる場合がある
rm -f web/main.dart.js

# リリースビルド
flutter build web

# → build/web/ に成果物が出力される
```

### 6.2 Firebase Hosting へデプロイ

```bash
firebase deploy --only hosting

# → https://cupple-app-a9194.web.app に公開される
```

### 6.3 デプロイ後の確認

- シークレットウィンドウ（プライベートブラウジング）で開くこと（キャッシュの影響を避ける）
- URL: https://cupple-app-a9194.web.app

---

## 7. 既知の問題と対処法

### 7.1 `web/main.dart.js` の stale ビルド問題

**症状**: コードを変更してもビルド結果に反映されない。

**原因**: `web/main.dart.js` が古いまま残っていると、Flutter のビルドシステムが dart2js のコンパイルをスキップすることがある。

**対処法**: ビルド前に必ず削除する。

```bash
rm -f web/main.dart.js
flutter build web
```

### 7.2 Firebase 初期化エラー

**症状**: `FirebaseException: duplicate-app`

**対処**: `main.dart` で `duplicate-app` エラーは無視して続行するようになっている。

### 7.3 キャッシュ問題

**症状**: デプロイ後に変更が反映されない。

**対処**:
- `firebase.json` に `Cache-Control: no-cache` ヘッダーを設定済み
- シークレットウィンドウで確認すること

---

## 8. Firebase 設定

### 8.1 プロジェクト情報

- **プロジェクト ID**: `cupple-app-a9194`
- **Hosting URL**: https://cupple-app-a9194.web.app

### 8.2 使用している Firebase サービス

| サービス | 用途 |
|---------|------|
| Firebase Authentication | ユーザー認証 |
| Cloud Firestore | データ保存（カード、カップル情報など） |
| Firebase Storage | アイコン画像などのファイル保存 |
| Firebase Hosting | Web アプリのホスティング |

### 8.3 セキュリティルール

- `firestore.rules` — Firestore のアクセス制御
- `storage.rules` — Storage のアクセス制御

ルールを変更した場合は以下でデプロイ：

```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
```

---

## 9. ブランチ戦略

- `main` ブランチが本番ブランチ
- 機能開発時は feature ブランチを作成し、PR でマージする
- デプロイは `main` ブランチの最新コミットに対して行われる

---

## 10. デバッグ

### 10.1 DebugOverlay

アプリ右上に「DEBUG」ボタンが表示されている（リリード時）。タップするとデバッグログのオーバーレイが表示される。

### 10.2 ブラウザコンソール

`DebugLog.add()` や `print()` の出力はブラウザの開発者ツール（F12）のコンソールで確認できる。

### 10.3 Firebase デバッグ

`lib/main.dart` の `dlog()` 呼び出しで Firebase 初期化のログを出力している。

---

## 11. 環境変数

このプロジェクトでは環境変数は使用していません。Firebase の設定は `lib/firebase_options.dart` にハードコードされています。

---

## 12. トラブルシューティング

### `flutter pub get` が失敗する場合

```bash
flutter clean
flutter pub get
```

### ビルドが失敗する場合

```bash
# キャッシュをクリアして再ビルド
flutter clean
rm -f web/main.dart.js
flutter pub get
flutter build web
```

### Firebase デプロイが失敗する場合

```bash
# 再ログイン
firebase login --reauth

# デプロイ再試行
firebase deploy --only hosting
```
