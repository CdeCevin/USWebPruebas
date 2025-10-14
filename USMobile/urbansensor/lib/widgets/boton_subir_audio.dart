import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'dart:async';

class SubirAudioButton extends StatefulWidget {
  //final Function(File) onAudioSelected;
  final Function(File, String) onAudioSelected;

  SubirAudioButton({required this.onAudioSelected});

  @override
  _SubirAudioButtonState createState() => _SubirAudioButtonState();
}

class _SubirAudioButtonState extends State<SubirAudioButton> {
  final recorder = Record();
  final player = AudioPlayer();
  bool isRecorderReady = false;
  String? recordedFilePath;
  bool isPlaying = false;
  bool isRecording = false;
  bool hasRecordedAudio = false;
  Duration recordingDuration = Duration.zero;
  Timer? timer;

  String? storedAudioFilePath;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    player.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> initRecorder() async {
    var statusMicrophone = await Permission.microphone.status;
    if (!statusMicrophone.isGranted) {
      statusMicrophone = await Permission.microphone.request();
      if (!statusMicrophone.isGranted) {
        throw "Permiso de micrófono no concedido";
      }
    }
    setState(() {
      isRecorderReady = true;
    });
  }

  String generateUniqueFileName() {
    final now = DateTime.now();
    final formattedDate =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    return 'audio_$formattedDate.m4a';
  }

  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = generateUniqueFileName();
    storedAudioFilePath =
        '${directory.path}/$fileName'; // guardas la ruta completa
    return storedAudioFilePath!;
    //return '${directory.path}/$fileName';
  }

  Future<void> record() async {
    if (!isRecorderReady) return;

    final path = await getFilePath();
    await recorder.start(path: path);

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        recordingDuration += Duration(seconds: 1);
      });
    });

    setState(() {
      isRecording = true;
      isPlaying = false;
      recordedFilePath = path;
    });

    print('Iniciando grabación: $path');
  }

  Future<void> stop() async {
    if (!isRecorderReady) return;

    final path = await recorder.stop();
    timer?.cancel();

    if (path != null) {
      final audioFile = File(path);

      setState(() {
        recordedFilePath = path;
        hasRecordedAudio = true;
        widget.onAudioSelected(audioFile, storedAudioFilePath!);
        isRecording = false;
        recordingDuration = Duration.zero;
      });

      print('Audio grabado: $audioFile');
    }
  }

  Future<void> play() async {
    if (recordedFilePath != null && !isRecording) {
      if (isPlaying) {
        await player.pause();
      } else {
        await player.play(DeviceFileSource(recordedFilePath!));

        player.onPlayerStateChanged.listen((PlayerState state) {
          if (state == PlayerState.completed) {
            setState(() {
              isPlaying = false;
            });
          }
        });
      }
      setState(() {
        isPlaying = !isPlaying;
      });
    }
  }

  void deleteAudio() {
    if (recordedFilePath != null && !isRecording) {
      File(recordedFilePath!).deleteSync();
      setState(() {
        recordedFilePath = null;
        isPlaying = false;
        hasRecordedAudio = false;
        recordingDuration = Duration.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Opacity(
              opacity: isRecording ? 1.0 : 0.0,
              child: Container(
                height: 15,
                child: Text(
                  formatDuration(recordingDuration),
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 5),
            GestureDetector(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color.fromARGB(255, 234, 236, 240),
                    width: 2.0,
                  ),
                  color: const Color.fromARGB(255, 29, 53, 91),
                ),
                child: IconButton(
                  onPressed: () async {
                    if (isRecording) {
                      await stop();
                    } else {
                      await record();
                    }
                    setState(() {});
                  },
                  icon: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    color: const Color.fromARGB(255, 230, 233, 236),
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasRecordedAudio) ...[
          SizedBox(width: 20),
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(right: 20),
                height: 20,
                child: StreamBuilder<Duration>(
                  stream: player.onPositionChanged,
                  builder: (context, snapshot) {
                    final duration =
                        snapshot.hasData ? snapshot.data! : Duration.zero;
                    return Text(
                      formatDuration(duration),
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    );
                  },
                ),
              ),
              GestureDetector(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.fromARGB(255, 234, 236, 240),
                      width: 2.0,
                    ),
                    color: const Color.fromARGB(255, 29, 53, 91),
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: const Color.fromARGB(255, 230, 233, 236),
                    size: 30,
                  ),
                ),
                onTap: () {
                  play();
                },
              ),
            ],
          ),
          SizedBox(width: 20),
          Column(
            children: [
              SizedBox(height: 20),
              GestureDetector(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.fromARGB(255, 234, 236, 240),
                      width: 2.0,
                    ),
                    color: Colors.red,
                  ),
                  child: Icon(Icons.clear, color: Colors.white, size: 30),
                ),
                onTap: () {
                  player.stop();
                  deleteAudio();
                },
              ),
              SizedBox(width: 20),
            ],
          ),
        ],
      ],
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
