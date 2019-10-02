part of media_operations;

class MediaOperations {
  static const MethodChannel _channel = const MethodChannel('media_operations');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<MediaInfo> getMediaInfo(String path) async {
    assert(path != null);
    final jsonStr = await _invoke<String>(
      'getMediaInfo',
      {'path': path},
    );
    final jsonMap = json.decode(jsonStr);
    return MediaInfo.fromJson(jsonMap);
  }

  Future<T> _invoke<T>(String name, [Map<String, dynamic> params]) async {
    T result;
    try {
      result = params != null
          ? await _channel.invokeMethod(name, params)
          : await _channel.invokeMethod(name);
    } on PlatformException catch (e) {
      debugPrint('''
      MediaOperations Error: 
      Method: $name
      $e
      ''');
    }
    return result;
  }
}
