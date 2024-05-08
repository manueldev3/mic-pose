import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:role_play/enums/record_status.dart';
import 'package:role_play/theme/role_play_theme.dart';
import 'package:role_play/widgets/sidebar_widget.dart';
import 'package:role_play/widgets/toast_widget.dart';
import 'package:role_play/services/WebSocket.dart';

/// Home Screen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Variables
  bool _expandSidebar = true;
  RecordStatus _recordStatus = RecordStatus.inactive;
  RecordingStatus _recordingStatus = RecordingStatus.playing;
  int _videoTimeSeconds = 0;
  Timer? _videoTimer;

  final WebSocket _socket = WebSocket("ws://127.0.0.1:5000/");
  bool _isConnected = false;

  void stop_recording(){
    _videoTimer?.cancel();
    _socket.send_message("stop_recording");
    setState(() {
      _recordingStatus =
          RecordingStatus.paused;
      _recordStatus =
          RecordStatus.preview;
      _videoTimer = null;
    });
  }
  void start_recording() {
    setState(() {
      _socket.send_message("start_recording");
      _recordStatus =
          RecordStatus.recording;
      _recordingStatus =
          RecordingStatus.playing;
      _videoTimer = Timer.periodic(
        const Duration(seconds: 1),
            (timer) {
          setState(() {
            _videoTimeSeconds++;
          });
        },
      );
    });
  }

  void connect(BuildContext context) async {
    _socket.connect();
    setState(() {
      _isConnected = true;
    });
  }

  void disconnect() {
    _socket.disconnect();
    setState(() {
      _isConnected = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        Image.asset(
          "assets/background.png",
          width: screenSize.width,
          height: screenSize.height,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _appBar(context),
          body: _body(context),
        ),
      ],
    );
  }

  /// AppBar
  AppBar _appBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 0,
    );
  }

  /// Body
  Widget _body(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Center(
      child: Row(
        children: [
          Sidebar(
            expand: _expandSidebar,
            onSizePressed: () {
              setState(() {
                _expandSidebar = !_expandSidebar;
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: screenSize.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: RolePlayColors.cardBg,
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 8,
                    children: [
                      Text(
                        "Presentation Practice",
                        style: GoogleFonts.poppins(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Wow your audience",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 854,
                                maxHeight: 480,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: _isConnected
                                    ? Center(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Container(
                                            color: Colors.white
                                          ),
                                          FittedBox(
                                            fit: BoxFit.fitHeight,
                                            child: StreamBuilder(
                                                stream: _socket.stream,
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return const Center(child: CircularProgressIndicator());
                                                  }

                                                  if (snapshot.connectionState ==
                                                      ConnectionState.done) {
                                                    return const Center(
                                                      child:
                                                          Text("Connection Closed !"),
                                                    );
                                                  }
                                                  //? Working for single frames
                                                  var image = json.decode(
                                                      utf8.decode(snapshot.data));

                                                  // return Text("Hola");
                                                  return Image.memory(
                                                    Uint8List.fromList(
                                                      base64Decode(
                                                        (image["image"]),
                                                      ),
                                                    ),
                                                    gaplessPlayback: true,
                                                    excludeFromSemantics: true,
                                                  );
                                                },
                                              ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : Center(child: ElevatedButton(child: Text("Connect", style: TextStyle(color: Colors.black)), onPressed: (){connect(context);},)),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Wrap(
                                spacing: 16,
                                children: [
                                  IconButton.filled(
                                    style: IconButton.styleFrom(
                                      minimumSize: const Size(52, 52),
                                      backgroundColor: Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {},
                                    icon: SvgPicture.asset(
                                      "assets/icons/video.svg",
                                    ),
                                  ),
                                  IconButton.filled(
                                    style: IconButton.styleFrom(
                                      minimumSize: const Size(52, 52),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.settings,
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: IconButton.filled(
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(52, 52),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  "assets/icons/graphic_eq.svg",
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Visibility(
                                    visible: _recordStatus.isInactive,
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(200, 51),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        start_recording();
                                      },
                                      icon: const Icon(
                                        Icons.video_call_rounded,
                                      ),
                                      label: const Text(
                                        "Start Recording",
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: _recordStatus.isRecording,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.black54,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              "${Duration(
                                                seconds: _videoTimeSeconds,
                                              )}"
                                                  .split('.')[0]
                                                  .padLeft(8, '0'),
                                              style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              if (_recordingStatus.isPlaying) {
                                                _videoTimer?.cancel();
                                                setState(() {
                                                  _recordingStatus =
                                                      RecordingStatus.paused;
                                                });
                                              } else {
                                                setState(() {
                                                  _recordingStatus =
                                                      RecordingStatus.playing;
                                                  _videoTimer = Timer.periodic(
                                                    const Duration(seconds: 1),
                                                    (timer) {
                                                      setState(() {
                                                        _videoTimeSeconds++;
                                                      });
                                                    },
                                                  );
                                                });
                                              }
                                            },
                                            icon: Icon(
                                              _recordingStatus.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              stop_recording();
                                            },
                                            icon: const Icon(
                                              Icons.stop,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: _recordStatus.isPreview,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.black54,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            "${Duration(
                                              seconds: _videoTimeSeconds,
                                            )}"
                                                .split('.')[0]
                                                .padLeft(8, '0'),
                                            style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              _videoTimer?.cancel();
                                              setState(() {
                                                _recordStatus =
                                                    RecordStatus.inactive;
                                                _recordingStatus =
                                                    RecordingStatus.playing;
                                                _videoTimeSeconds = 0;
                                                _videoTimer = null;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.replay_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                          FilledButton.icon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(16, 49),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.chevron_right,
                                            ),
                                            label: const Text(
                                              "View Analysis",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 840,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: [
                                Text(
                                  "To Start",
                                  style: GoogleFonts.poppins(
                                    color: RolePlayColors.primary200,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 840,
                                  ),
                                  child: Text(
                                    "Type any role and company or select from the dropdowns, "
                                    "and select your Interviewer type. Edit the starter "
                                    "questions below, or add your own!",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 840,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        RolePlayColors.cardBg.withOpacity(0.75),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        "Personalize your interview",
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Wrap(
                                        direction: Axis.vertical,
                                        spacing: 8,
                                        children: [
                                          Text(
                                            "Role",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 808,
                                              maxHeight: 42,
                                            ),
                                            child: TextField(
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                              ),
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
                                                hintText: "Write a role",
                                                hintStyle: GoogleFonts.poppins(
                                                  color: Colors.grey,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                    width: 2,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 16,
                                            children: [
                                              Wrap(
                                                direction: Axis.vertical,
                                                spacing: 8,
                                                children: [
                                                  Text(
                                                    "Company",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                      maxWidth: 396,
                                                      maxHeight: 42,
                                                    ),
                                                    child: TextField(
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 16,
                                                        ),
                                                        hintText:
                                                            "Write a company name",
                                                        hintStyle:
                                                            GoogleFonts.poppins(
                                                          color: Colors.grey,
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide:
                                                              const BorderSide(
                                                            width: 2,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Wrap(
                                                direction: Axis.vertical,
                                                spacing: 8,
                                                children: [
                                                  Text(
                                                    "Inteviewer",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                      maxWidth: 396,
                                                      maxHeight: 42,
                                                    ),
                                                    child: TextField(
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 16,
                                                        ),
                                                        hintText:
                                                            "Write a inteviewer name",
                                                        hintStyle:
                                                            GoogleFonts.poppins(
                                                          color: Colors.grey,
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide:
                                                              const BorderSide(
                                                            width: 2,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 364,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            direction: Axis.vertical,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                "Interview Status",
                                style: GoogleFonts.poppins(
                                  color: RolePlayColors.backgroundDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(
                                width: 332,
                                child: Text(
                                  "Lorem ipsum dolor sit amet consectetur. "
                                  "Varius diam dolor at feugiat. ",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Wrap(
                                direction: Axis.vertical,
                                children: [
                                  SizedBox(
                                    width: 332,
                                    child: Toast.warning("Watch your posture."),
                                  ),
                                  SizedBox(
                                    width: 332,
                                    child: Toast.success(
                                      "Hands not in the pockets",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 332,
                                    child: Toast.success(
                                      "Hands not in the face",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 332,
                                    child: Toast.danger(
                                      "Try to level your shoulders",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 332,
                                    child: Toast.success(
                                      "Hips are aligned",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 332,
                                    child: Toast.success(
                                      "Your head is straight",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 332,
                                    child: Toast.warning(
                                      "Try to straighten your spine",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth: 364,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: RolePlayColors.cardBg.withOpacity(0.75),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            direction: Axis.vertical,
                            spacing: 8,
                            children: [
                              Text(
                                "Interview practice questions",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    margin: const EdgeInsets.only(top: 8),
                                  ),
                                  SizedBox(
                                    width: 320,
                                    child: Text(
                                      "How do you handle feedback that you disagree with?",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    margin: const EdgeInsets.only(top: 8),
                                  ),
                                  SizedBox(
                                    width: 320,
                                    child: Text(
                                      "How do you prioritize your tasks when working on multiple projects simultaneously?",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    margin: const EdgeInsets.only(top: 8),
                                  ),
                                  SizedBox(
                                    width: 320,
                                    child: Text(
                                      "How do you handle feedback that you disagree with?",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    margin: const EdgeInsets.only(top: 8),
                                  ),
                                  SizedBox(
                                    width: 320,
                                    child: Text(
                                      "How do you prioritize your tasks when working on multiple projects simultaneously?",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
