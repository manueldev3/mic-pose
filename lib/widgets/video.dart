import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player_win/video_player_win.dart';

/// Video
class Video extends ConsumerStatefulWidget {
  const Video({
    super.key,
    required this.file,
  });

  /// Props
  final File file;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoState();
}

class _VideoState extends ConsumerState<Video> {
  /// Variables
  bool isPlaying = true;
  double speed = 1;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  int hoursDuration = 0;
  int minutesDuration = 0;
  int secondsDuration = 0;
  int currentSeconds = 0;
  int totalSeconds = 0;

  /// Late
  late WinVideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = WinVideoPlayerController.file(widget.file);
    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.isCompleted) {
        log("El video ha inciado");
      }
      setState(() {
        isPlaying = _videoPlayerController.value.isPlaying;
        speed = _videoPlayerController.value.playbackSpeed;
        hours = _videoPlayerController.value.position.inHours;
        minutes = _videoPlayerController.value.position.inMinutes % 60;
        seconds = _videoPlayerController.value.position.inSeconds % 60;
        hoursDuration = _videoPlayerController.value.duration.inHours;
        minutesDuration = _videoPlayerController.value.duration.inMinutes % 60;
        secondsDuration = _videoPlayerController.value.duration.inSeconds % 60;
        currentSeconds = _videoPlayerController.value.position.inSeconds;
        totalSeconds = _videoPlayerController.value.duration.inSeconds;
      });
    });
    initialized();
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }

  /// Started
  Future<void> initialized() async {
    try {
      await _videoPlayerController.initialize();
      if (isPlaying) {
        await _videoPlayerController.play();
      }

      log("iniciamos");
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 640,
        maxWidth: 840,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: WinVideoPlayer(_videoPlayerController),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (isPlaying) {
                        _videoPlayerController.pause();
                      } else {
                        _videoPlayerController.play();
                      }
                    },
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    color: Colors.white,
                  ),
                  IconButton(
                    onPressed: () {
                      _videoPlayerController.dispose();
                      _videoPlayerController =
                          WinVideoPlayerController.file(widget.file);
                      _videoPlayerController.addListener(() {
                        if (_videoPlayerController.value.isCompleted) {
                          log("El video ha inciado");
                        }
                        setState(() {
                          isPlaying = _videoPlayerController.value.isPlaying;
                          speed = _videoPlayerController.value.playbackSpeed;
                          hours = _videoPlayerController.value.position.inHours;
                          minutes =
                              _videoPlayerController.value.position.inMinutes %
                                  60;
                          seconds =
                              _videoPlayerController.value.position.inSeconds %
                                  60;
                          hoursDuration =
                              _videoPlayerController.value.duration.inHours;
                          minutesDuration =
                              _videoPlayerController.value.duration.inMinutes %
                                  60;
                          secondsDuration =
                              _videoPlayerController.value.duration.inSeconds %
                                  60;
                          currentSeconds =
                              _videoPlayerController.value.position.inSeconds;
                          totalSeconds =
                              _videoPlayerController.value.duration.inSeconds;
                        });
                      });
                      initialized();
                    },
                    icon: const Icon(Icons.stop),
                    color: Colors.white,
                  ),
                  Text(
                    "${hoursDuration > 0 ? "${hours.toString().padLeft(2, '0')}:" : ""}"
                    "${minutesDuration > 0 ? "${minutes.toString().padLeft(2, '0')}:" : ""}"
                    "${secondsDuration > 0 ? seconds.toString().padLeft(2, '0') : ""}"
                    "/"
                    "${hoursDuration > 0 ? "${hoursDuration.toString().padLeft(2, '0')}:" : ""}"
                    "${minutesDuration > 0 ? "${minutesDuration.toString().padLeft(2, '0')}:" : ""}"
                    "${secondsDuration > 0 ? secondsDuration.toString().padLeft(2, '0') : ""}",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: (1 / totalSeconds) * currentSeconds,
                      onChanged: (value) {
                        _videoPlayerController.seekTo(
                          Duration(
                            seconds: (value * totalSeconds).toInt(),
                          ),
                        );
                      },
                      activeColor: Colors.red,
                    ),
                  ),
                  PopupMenuButton<double>(
                    initialValue: speed,
                    onSelected: (double item) {
                      _videoPlayerController.setPlaybackSpeed(item);
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<double>>[
                      const PopupMenuItem<double>(
                        value: 1.0,
                        child: Text('1x'),
                      ),
                      const PopupMenuItem<double>(
                        value: 2.0,
                        child: Text('2x'),
                      ),
                      const PopupMenuItem<double>(
                        value: 3.0,
                        child: Text('3x'),
                      ),
                    ],
                    icon: Text(
                      "${speed.toStringAsFixed(0)}x",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
