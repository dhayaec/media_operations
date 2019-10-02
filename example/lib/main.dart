import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:media_operations/media_operations.dart';
import 'package:path_provider/path_provider.dart';

import 'VideoPlayer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  final _mediaOperations = MediaOperations();

  Subscription _subscription;

  final _loadingStreamCtrl = StreamController<bool>.broadcast();

  MediaInfo _m;
  String _mediaResult = '';

  List<MediaInfo> _spittedVideos = List();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _copyAssets();
    _subscription = _mediaOperations.compressProgress$.subscribe((progress) {
      debugPrint('[Compressing Progress] $progress %');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
    _loadingStreamCtrl.close();
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
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              RaisedButton(
                onPressed: () async {
                  var d = await getApplicationDocumentsDirectory();
                  MediaInfo r =
                      await _mediaOperations.getMediaInfo(d.path + '/s.mp4');
                  setState(() {
                    _m = r;
                  });
                },
                child: Text('getMediaInfo'),
              ),
              if (_m != null && _m.path.length > 0)
                Column(
                  children: <Widget>[
                    Text('Title ${_m.title}'),
                    Text('Duration ${_m.duration}'),
                    Text('fileSize ${_m.fileSize}'),
                    Text('Width ${_m.width}'),
                  ],
                ),
              RaisedButton(
                child: Text('Split'),
                onPressed: () async {
                  _loadingStreamCtrl.sink.add(true);
                  spitVideos();
                  _loadingStreamCtrl.sink.add(false);
                },
              ),
              if (_mediaResult.length > 0) Text(_mediaResult),
              if (_spittedVideos.length > 0)
                Column(
                  children:
                      _spittedVideos.map<Widget>((i) => Text(i.path)).toList(),
                ),
              if (_spittedVideos.length > 0)
                VideoApp(
                  path: _spittedVideos[_spittedVideos.length - 2].path,
                )
            ],
          ),
        ),
      ),
    );
  }

  Future spitVideos() async {
    var d = await getApplicationDocumentsDirectory();
    _mediaOperations.getMediaInfo(d.path + '/s.mp4').then((v) async {
      Duration videoDuration = Duration(milliseconds: v.duration.toInt());
      Duration splitSeconds = Duration(seconds: 30);
      double len = videoDuration.inSeconds / splitSeconds.inSeconds;
      String docDirectory = d.path;
      List<String> commands = List<String>.generate(len.toInt() + 1, (i) {
        var d = Duration(seconds: 30 * i);
        return "-y -i $docDirectory/s.mp4 -vcodec copy -acodec copy -ss $d -t 00:00:30 -sn $docDirectory/video$i.mp4";
      });

      List<Future> fs = List();
      commands.asMap().forEach((i, t) {
        var command = t.split(' ');
        fs.add(
            _mediaOperations.splitVideo(command, "$docDirectory/video$i.mp4"));
      });

      try {
        var res = await Future.wait(fs);
        List<MediaInfo> mediaItems = List();
        if (res.length > 0) {
          res.forEach((f) {
            var item = MediaInfo.fromJson(json.decode(f));
            mediaItems.add(item);
          });
        }
        setState(() {
          _spittedVideos = mediaItems;
        });
      } catch (e) {
        print(e);
      }
    });
  }

  String formatTime(double time) {
    Duration duration = Duration(milliseconds: time.round());
    return [duration.inHours, duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }
}
