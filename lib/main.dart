import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound/public/tau.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String path;

  @override
  void initState() {
    _player.openAudioSession();

    _recorder.openAudioSession();
    super.initState();
  }

  // FlutterAudioRecorder _recorder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
            future: getApplicationDocumentsDirectory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              else {
                Directory dir = snapshot.data;
                // print(dir.path);
                path ??=
                    '${dir.path}/record${DateTime.now().millisecondsSinceEpoch}.wav';
                print(path);
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        onPressed: () async {
                          await Permission.microphone.request();
                          File file = await File(path).create();
                          if (_recorder.isRecording) {
                            _recorder.stopRecorder();

                            setState(() {});
                          } else {
                            _recorder.startRecorder(
                              toFile: path,
                              codec: Codec.pcm16WAV,
                            );

                            setState(() {});
                          }
                        },
                        child: Icon(
                            _recorder.isRecording ? Icons.stop : Icons.mic),
                      ),
                      FloatingActionButton(
                        onPressed: () async {
                          // await Permission.microphone.request();
                          File file = File(path);
                          print(file.uri.toString());
                          print("Open");
                          if (_player.isOpen()) {
                            if (_player.isPlaying) {
                              _player.stopPlayer();

                              setState(() {});
                            } else {
                              _player
                                  .startPlayer(
                                fromURI: "file://$path",
                                // codec: Codec.pcm16WAV,
                              )
                                  .whenComplete(() {
                                setState(() {});
                              });

                              setState(() {});
                            }
                          } else {
                            print("NOT Open");
                          }
                        },
                        child: Icon(_player.isPlaying ? Icons.stop : Icons.mic),
                      ),
                    ],
                  ),
                );
              }
            }));
  }
}
