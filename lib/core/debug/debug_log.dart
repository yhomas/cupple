

import 'package:flutter/foundation.dart';
import 'debug_overlay.dart';

void dlog(String message) {
  DebugLog.add(message);
  if (kDebugMode) {
    debugPrint(message);
  }
}


