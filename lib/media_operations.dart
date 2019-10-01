import 'dart:async';

import 'package:flutter/services.dart';

class MediaOperations {
  static const MethodChannel _channel =
      const MethodChannel('media_operations');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
