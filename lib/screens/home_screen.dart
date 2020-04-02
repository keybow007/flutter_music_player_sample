import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fft/flutter_fft.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPlaying = false;
  final _audioPlayer = AssetsAudioPlayer();

  //FFT
  double _tolerance;
  double _frequency;
  String _note;
  double _target;
  double _distance;
  int _octave;
  String _nearestNote;
  double _nearestTarget;
  double _nearestDistance;
  int _nearestOctave;
  bool _isOnPitch;

  bool _isRecording;

  FlutterFft flutterFft = FlutterFft();

  @override
  void initState() {
    super.initState();
    _audioPlayer.loop = false;
    //openで鳴ってしまうバグがあるようなので、解消されるまでこれをplayMusicメソッドに移動
    //_audioPlayer.open("assets/musics/intro.mp3");

    _initFft();
  }

  void _initFft() async {
    _isRecording = flutterFft.getIsRecording;

    _tolerance = flutterFft.getTolerance;
    _frequency = flutterFft.getFrequency;
    _note = flutterFft.getNote;
    _target = flutterFft.getTarget;
    _distance = flutterFft.getDistance;
    _octave = flutterFft.getOctave;
    _nearestNote = flutterFft.getNearestNote;
    _nearestTarget = flutterFft.getNearestTarget;
    _nearestDistance = flutterFft.getNearestDistance;
    _isOnPitch = flutterFft.getIsOnPitch;

    print("Start Recording");
    await flutterFft.startRecorder();
    setState(() => _isRecording = flutterFft.getIsRecording);

    flutterFft.onRecorderStateChanged.listen((data) => {
          print("data: $data"),
          setState(() {
            _tolerance = data[0];
            _frequency = data[1];
            _note = data[2];
            _target = data[3];
            _distance = data[4];
            _octave = data[5];
            _nearestNote = data[6];
            _nearestTarget = data[7];
            _nearestDistance = data[8];
            _nearestOctave = data[9];
            _isOnPitch = data[10];
          }),
          flutterFft
            ..setTolerance = _tolerance
            ..setFrequency = _frequency
            ..setNote = _note
            ..setTarget = _target
            ..setDistance = _distance
            ..setOctave = _octave
            ..setNearestNote = _nearestNote
            ..setNearestTarget = _nearestTarget
            ..setNearestDistance = _nearestDistance
            ..setNearestOctave = _nearestOctave
            ..setIsOnPitch = _isOnPitch,
          print("frequency: $_frequency"),
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    flutterFft.stopRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Music Player Sample"),
          centerTitle: true,
        ),
        floatingActionButton: _isPlaying
            ? FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => stopMusic(),
              )
            : FloatingActionButton(
                child: Icon(Icons.play_arrow),
                onPressed: () => playMusic(),
              ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Switch(
                value: _audioPlayer.loop,
                onChanged: (value) {
                  setState(() {
                    _audioPlayer.loop = value;
                    print("loop: ${_audioPlayer.loop}");
                  });
                },
              ),
              SizedBox(
                height: 20.0,
              ),
              _isRecording ? _fftResults() : Text("Nor Recording")
            ],
          ),
        ),
      ),
    );
  }

  playMusic() async {
    _isPlaying = true;
    _audioPlayer.open("assets/musics/intro.mp3");
    //playメソッドがワークしない（バグらしい）
    //_audioPlayer.play();
    print("_isPlaying: $_isPlaying");
  }

  stopMusic() {
    setState(() {
      _isPlaying = false;
      _audioPlayer.stop();
      print("_isPlaying: $_isPlaying");
    });
  }

  _fftResults() {
    return Center(
      child: Column(
        children: <Widget>[
          Text("Tolerance: ${_tolerance.toStringAsFixed(1)}"),
          Text("Frequency: ${_frequency.toStringAsFixed(2)}"),
          Text("Note: $_note"),
          Text("Target: ${_target.toStringAsFixed(2)}"),
          Text("Distance: ${_distance.toStringAsFixed(2)}"),
          Text("Octave: $_octave"),
          Text("NearestNote: $_nearestNote"),
          Text("NearestTarget: ${_nearestTarget.toStringAsFixed(2)}"),
          Text("NearestDistance: ${_nearestDistance.toStringAsFixed(2)}"),
          Text("NearestOctave: $_nearestOctave"),
          Text("IsOnPitch: ${_isOnPitch.toString()}"),
        ],
      ),
    );
  }
}
