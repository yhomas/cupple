import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/debug/debug_log.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  dlog('Background notification received: ${message.messageId}');
}

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

  // FCM setup
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dlog('Foreground notification received: ${message.notification?.title}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dlog('Notification tapped: ${message.data}');
    });
  } catch (e) {
    dlog('main: FCM setup error: $e');
  }

  runApp(
    ProviderScope(
      child: CuppleApp(firebaseError: firebaseError),
    ),
  );
}
