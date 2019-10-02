import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:media_operations/media_operations.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  final _mediaOperations = MediaOperations();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _copyAssets();
  }

  _copyAssets() async {
    final Directory d = await getApplicationDocumentsDirectory();
    rootBundle.load('assets/videos/s.mp4').then((content) {
      File newFile = File('${d.path}/s.mp4');
      newFile.writeAsBytesSync(content.buffer.asUint8List());
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await MediaOperations.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Text('Running on: $_platformVersion\n'),
            RaisedButton(
              onPressed: () async {
                final Directory d = await getApplicationDocumentsDirectory();
                MediaInfo r = await _mediaOperations.getMediaInfo(d.path + '/s.mp4');
                print(r.toJson());
              },
              child: Text('getMediaInfo'),
            )
          ],
        ),
      ),
    );
  }
}
