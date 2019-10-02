part of media_operations;

class MediaOperations {
  static const MethodChannel _channel = const MethodChannel('media_operations');

  factory MediaOperations() => MediaOperations._();

  final compressProgress$ = ObservableBuilder<double>();

  bool get isCompressing => _isCompressing;

  bool _isCompressing = false;

  MediaOperations._() {
    _channel.setMethodCallHandler(_handleCallback);
  }

  Future<void> _handleCallback(MethodCall call) async {
    switch (call.method) {
      case 'updateProgress':
        final progress = double.tryParse(call.arguments);
        _updateProgressState(progress);
        break;
    }
  }

  void _updateProgressState(double state) {
    if (state != null) {
      compressProgress$.next(state);
    }
  }

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

  Future<String> splitVideo(List<String> commands, String path) async {
    assert(commands.length != null);
    assert(path != null);
    String res;
    res = await _invoke<String>(
      'getMediaInfo',
      {
        'commands': commands,
        'path': path,
      },
    );
    return res;
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
