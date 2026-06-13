import 'package:flutter/foundation.dart';
import 'dart:collection';

class DebugLog {
  static final Queue<String> _logs = Queue<String>();
  static final List<VoidCallback> _listeners = [];
  static const int maxLogs = 200;

  static void add(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    _logs.addLast('[$timestamp] $message');
    if (_logs.length > maxLogs) _logs.removeFirst();
    for (final listener in _listeners) {
      listener();
    }
  }

  static void addListener(VoidCallback listener) => _listeners.add(listener);
  static void removeListener(VoidCallback listener) => _listeners.remove(listener);
  static List<String> get logs => _logs.toList();
  static void clear() {
    _logs.clear();
    for (final listener in _listeners) {
      listener();
    }
  }
}

void dlog(String message) {
  DebugLog.add(message);
  if (kDebugMode) {
    debugPrint(message);
  }
}
