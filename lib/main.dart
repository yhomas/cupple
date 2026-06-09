import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // firebase_options.dart が存在する場合（flutterfire configure 済み）
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    // firebase_options.dart が存在しない場合（テンプレート未設定）
    await Firebase.initializeApp();
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // Web で firebase-config.js から既に初期化済み
    }
    // その他のFirebaseエラーは無視してアプリを起動
  } catch (_) {
    // Firebase config not available — continue without Firebase
  }
  runApp(
    const ProviderScope(
      child: CuppleApp(),
    ),
  );
}
