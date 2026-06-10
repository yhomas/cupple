import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/debug/debug_log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dlog('main: WidgetsFlutterBinding.ensureInitialized done');

  String? firebaseError;
  try {
    dlog('main: Firebase.initializeApp starting...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    dlog('main: Firebase.initializeApp SUCCESS');
    dlog('main: Firebase.app().name = ${Firebase.app().name}');
    dlog('main: FirebaseAuth.instance.currentUser = ${FirebaseAuth.instance.currentUser?.uid ?? "null"}');
    dlog('main: Firestore.instance = ${FirebaseFirestore.instance.app.name}');
  } on FirebaseException catch (e) {
    dlog('main: FirebaseException: ${e.code} - ${e.message}');
    if (e.code == 'duplicate-app') {
      dlog('main: duplicate-app, continuing...');
    } else {
      firebaseError = 'Firebase init error: ${e.code} - ${e.message}';
    }
  } catch (e) {
    dlog('main: Exception: $e');
    firebaseError = 'Firebase init error: $e';
  }
  runApp(
    ProviderScope(
      child: CuppleApp(firebaseError: firebaseError),
    ),
  );
}
