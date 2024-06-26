import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:role_play/enums/record_status.dart';
import 'package:role_play/theme/role_play_theme.dart';
import 'package:role_play/widgets/posture_progress.dart';
import 'package:role_play/widgets/filler_button.dart';
import 'package:role_play/widgets/sidebar_widget.dart';
import 'package:role_play/widgets/speed_speech_graphic.dart';
import 'package:role_play/widgets/toast_widget.dart';
import 'package:role_play/services/WebSocket.dart';
import 'package:role_play/widgets/video.dart';
import 'package:spider_chart/spider_chart.dart';
import 'package:supercontext/supercontext.dart';
import 'package:unique_simple_bar_chart/data_models.dart';
import 'package:unique_simple_bar_chart/simple_bar_chart.dart';

/// Home Screen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  /// Variables
  bool _expandSidebar = true;
  RecordStatus _recordStatus = RecordStatus.inactive;
  RecordingStatus _recordingStatus = RecordingStatus.playing;
  int _videoTimeSeconds = 0;
  Timer? _videoTimer;
  int analyticsCurrentIndex = 0;
  bool showTranscription = false;

  /// In voice
  bool _openSpeedOfSpeech = true;
  bool _openNumberOfFillings = false;
  bool _openCoherenceOfTheSpeech = false;

  /// late variables
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        analyticsCurrentIndex = _tabController.index;
      });
    });
  }

  final WebSocket _socket = WebSocket("ws://127.0.0.1:5000/");
  bool _isConnected = false;

  void stop_recording() {
    _videoTimer?.cancel();
    _socket.send_message("stop_recording");
    setState(() {
      _recordingStatus = RecordingStatus.paused;
      _recordStatus = RecordStatus.preview;
      _videoTimer = null;
    });
  }

  void start_recording() {
    setState(() {
      _socket.send_message("start_recording");
      _recordStatus = RecordStatus.recording;
      _recordingStatus = RecordingStatus.playing;
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
  void dispose() {
    _tabController.dispose();
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
            child: SingleChildScrollView(
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
                          /// Video player
                          Visibility(
                            visible: _recordStatus.isView,
                            child: Video(
                              file: File(
                                "D:\\projects\\Role Play\\windows\\role_play\\assets\\video_example.mp4",
                              ),
                            ),
                          ),

                          /// Video streaming
                          Visibility(
                            visible: !_recordStatus.isView,
                            child: Stack(
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
                                                Container(color: Colors.white),
                                                FittedBox(
                                                  fit: BoxFit.fitHeight,
                                                  child: StreamBuilder(
                                                    stream: _socket.stream,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return const Center(
                                                            child:
                                                                CircularProgressIndicator());
                                                      }

                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        return const Center(
                                                          child: Text(
                                                              "Connection Closed !"),
                                                        );
                                                      }

                                                      /// Working for single frames
                                                      var image = json.decode(
                                                          utf8.decode(
                                                              snapshot.data));

                                                      // return Text("Hola");
                                                      return Image.memory(
                                                        Uint8List.fromList(
                                                          base64Decode(
                                                            (image["image"]),
                                                          ),
                                                        ),
                                                        gaplessPlayback: true,
                                                        excludeFromSemantics:
                                                            true,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Center(
                                            child: ElevatedButton(
                                              child: Text(
                                                "Connect",
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              onPressed: () {
                                                connect(context);
                                              },
                                            ),
                                          ),
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                                  if (_recordingStatus
                                                      .isPlaying) {
                                                    _videoTimer?.cancel();
                                                    setState(() {
                                                      _recordingStatus =
                                                          RecordingStatus
                                                              .paused;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _recordingStatus =
                                                          RecordingStatus
                                                              .playing;
                                                      _videoTimer =
                                                          Timer.periodic(
                                                        const Duration(
                                                            seconds: 1),
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                                  minimumSize:
                                                      const Size(16, 49),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _recordStatus =
                                                        RecordStatus.view;
                                                  });
                                                },
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
                          ),

                          /// Show transcriptions
                          Visibility(
                            visible: _recordStatus.isView,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 840,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Wrap(
                                  direction: Axis.vertical,
                                  spacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: [
                                    Text(
                                      "Interview Overview",
                                      style: GoogleFonts.poppins(
                                        color: RolePlayColors.primary200,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 32,
                                      children: [
                                        Wrap(
                                          spacing: 8,
                                          direction: Axis.vertical,
                                          children: [
                                            Text(
                                              "Role",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              "Designer",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Wrap(
                                          spacing: 8,
                                          direction: Axis.vertical,
                                          children: [
                                            Text(
                                              "Company",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              "Mercadolibre",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Wrap(
                                          spacing: 8,
                                          direction: Axis.vertical,
                                          children: [
                                            Text(
                                              "Inteviewer",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              "Role",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 840,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: RolePlayColors.cardBg
                                              .withOpacity(0.75),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          children: [
                                            SizedBox(
                                              width: 808,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Transcription",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        showTranscription =
                                                            !showTranscription;
                                                      });
                                                    },
                                                    icon: Icon(
                                                      showTranscription
                                                          ? Icons
                                                              .keyboard_arrow_up
                                                          : Icons
                                                              .keyboard_arrow_down,
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Visibility(
                                              visible: showTranscription,
                                              child: const SizedBox(height: 16),
                                            ),
                                            Visibility(
                                              visible: showTranscription,
                                              child: Wrap(
                                                direction: Axis.vertical,
                                                spacing: 8,
                                                children:
                                                    List.generate(4, (index) {
                                                  return Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                      maxWidth: 808,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8,
                                                      ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            width: context
                                                                .mediaSize
                                                                .width,
                                                            child: Text(
                                                              "${Random().nextInt(23).toString().padLeft(2, "0")}"
                                                              ":"
                                                              "${Random().nextInt(60).toString().padLeft(2, "0")}",
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                color: RolePlayColors
                                                                    .secondary500,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: context
                                                                .mediaSize
                                                                .width,
                                                            child: Text(
                                                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vitae congue augue, sit amet tincidunt nisl.",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// Streaming form
                          Visibility(
                            visible: !_recordStatus.isView,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 840,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                        color: RolePlayColors.cardBg
                                            .withOpacity(0.75),
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
                                                constraints:
                                                    const BoxConstraints(
                                                  maxWidth: 808,
                                                  maxHeight: 42,
                                                ),
                                                child: TextField(
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                  ),
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 16,
                                                    ),
                                                    hintText: "Write a role",
                                                    hintStyle:
                                                        GoogleFonts.poppins(
                                                      color: Colors.grey,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
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
                                                        style:
                                                            GoogleFonts.poppins(
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
                                                          style: GoogleFonts
                                                              .poppins(
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
                                                                GoogleFonts
                                                                    .poppins(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              borderSide:
                                                                  const BorderSide(
                                                                width: 2,
                                                                color:
                                                                    Colors.grey,
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
                                                        style:
                                                            GoogleFonts.poppins(
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
                                                          style: GoogleFonts
                                                              .poppins(
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
                                                                GoogleFonts
                                                                    .poppins(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              borderSide:
                                                                  const BorderSide(
                                                                width: 2,
                                                                color:
                                                                    Colors.grey,
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
                          ),
                        ],
                      ),

                      /// Column 2
                      Visibility(
                        visible: !_recordStatus.isView,
                        child: Column(
                          children: [
                            Container(
                              width: context.mediaSize.width > 1366 ? 364 : 840,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              margin: context.mediaSize.width > 1366
                                  ? EdgeInsets.zero
                                  : const EdgeInsets.only(left: 8),
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
                                        width: context.mediaSize.width > 1366
                                            ? 332
                                            : 810,
                                        child: Toast.warning(
                                          "Watch your posture.",
                                        ),
                                      ),
                                      SizedBox(
                                        width: context.mediaSize.width > 1366
                                            ? 332
                                            : 810,
                                        child: Toast.success(
                                          "Hands not in the pockets",
                                        ),
                                      ),
                                      SizedBox(
                                        width: context.mediaSize.width > 1366
                                            ? 332
                                            : 810,
                                        child: Toast.success(
                                          "Hands not in the face",
                                        ),
                                      ),
                                      SizedBox(
                                        width: context.mediaSize.width > 1366
                                            ? 332
                                            : 810,
                                        child: Toast.danger(
                                          "Try to level your shoulders",
                                        ),
                                      ),
                                      SizedBox(
                                        width: context.mediaSize.width > 1366
                                            ? 332
                                            : 810,
                                        child: Toast.success(
                                          "Hips are aligned",
                                        ),
                                      ),
                                      SizedBox(
                                        width: context.mediaSize.width > 1366
                                            ? 332
                                            : 810,
                                        child: Toast.success(
                                          "Your head is straight",
                                        ),
                                      ),
                                      SizedBox(
                                        width: context.mediaSize.width > 1366
                                            ? 332
                                            : 810,
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
                              constraints: BoxConstraints(
                                minWidth:
                                    context.mediaSize.width > 1366 ? 334 : 840,
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
                                        width: context.mediaSize.width > 1366
                                            ? 320
                                            : 740,
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
                                        width: context.mediaSize.width > 1366
                                            ? 320
                                            : 740,
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
                                        width: context.mediaSize.width > 1366
                                            ? 320
                                            : 740,
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
                                        width: context.mediaSize.width > 1366
                                            ? 320
                                            : 740,
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
                      ),
                      Visibility(
                        visible: _recordStatus.isView,
                        child: Container(
                          width: context.mediaSize.width > 1366 ? 364 : 840,
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
                                "Analitycs",
                                style: GoogleFonts.poppins(
                                  color: RolePlayColors.backgroundDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(
                                width: 332,
                                child: Text(
                                  "Lorem ipsum dolor sit amet consectetur."
                                  "Varius diam dolor at feugiat.",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Row(
                                children: [
                                  MaterialButton(
                                    color: analyticsCurrentIndex == 0
                                        ? RolePlayColors.primary200
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    onPressed: () {
                                      if (analyticsCurrentIndex != 0) {
                                        _tabController.animateTo(0);
                                      }
                                    },
                                    child: const Text("Feedback"),
                                  ),
                                  MaterialButton(
                                    color: analyticsCurrentIndex == 1
                                        ? RolePlayColors.primary200
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    onPressed: () {
                                      if (analyticsCurrentIndex != 1) {
                                        _tabController.animateTo(1);
                                      }
                                    },
                                    child: const Text("Voice"),
                                  ),
                                  MaterialButton(
                                    color: analyticsCurrentIndex == 2
                                        ? RolePlayColors.primary200
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    onPressed: () {
                                      if (analyticsCurrentIndex != 2) {
                                        _tabController.animateTo(2);
                                      }
                                    },
                                    child: const Text("Posture"),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width:
                                    context.mediaSize.width > 1366 ? 300 : 808,
                                height: 720,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    /// FeedBack
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: const Border.fromBorderSide(
                                          BorderSide(
                                            width: 2,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Wrap(
                                            direction: Axis.vertical,
                                            spacing: 8,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  color:
                                                      RolePlayColors.error100,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 2,
                                                ).copyWith(bottom: 4),
                                                child: Text(
                                                  "Key points",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text("1. "),
                                                  SizedBox(
                                                    width: context.mediaSize
                                                                .width >
                                                            1366
                                                        ? 256
                                                        : 740,
                                                    child: const Text(
                                                      "La candidata, Katja Rüegg, ha mostrado su entusiasmo por el puesto, que considera hecho a la medida de sus capacidades e intereses.",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text("2. "),
                                                  SizedBox(
                                                    width: context.mediaSize
                                                                .width >
                                                            1366
                                                        ? 256
                                                        : 740,
                                                    child: const Text(
                                                      "Ha hecho especial hincapié en la oportunidad de utilizar diferentes idiomas y formar un equipo.",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text("3. "),
                                                  SizedBox(
                                                    width: context.mediaSize
                                                                .width >
                                                            1366
                                                        ? 256
                                                        : 740,
                                                    child: const Text(
                                                      "La candidata estaba deseando saber más sobre el puesto durante la entrevista.",
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              /// 2
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  top: 16,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color:
                                                      RolePlayColors.success200,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 2,
                                                ).copyWith(bottom: 4),
                                                child: Text(
                                                  "Positive Feedback",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text("1. "),
                                                  SizedBox(
                                                    width: context.mediaSize
                                                                .width >
                                                            1366
                                                        ? 256
                                                        : 740,
                                                    child: const Text(
                                                      "La candidata se mostró muy entusiasta y segura en su entrevista. Mostró un claro interés por el puesto y parecía versada en él.",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text("2. "),
                                                  SizedBox(
                                                    width: context.mediaSize
                                                                .width >
                                                            1366
                                                        ? 256
                                                        : 740,
                                                    child: const Text(
                                                      "Hizo hincapié en sus conocimientos de idiomas, lo que supone una gran ventaja en el mercado global actual.",
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              /// 3
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  top: 16,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  color:
                                                      RolePlayColors.warning200,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 2,
                                                ).copyWith(bottom: 4),
                                                child: Text(
                                                  "Comments to be Improved",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text("1. "),
                                                  SizedBox(
                                                    width: context.mediaSize
                                                                .width >
                                                            1366
                                                        ? 256
                                                        : 740,
                                                    child: const Text(
                                                      "Aunque la mayor parte de la comunicación fue clara, la candidata cambió inesperadamente a otro idioma (francés). Esto podría causar confusión a algunos entrevistadores, a menos que la empresa espere aptitudes multilingües.",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text("2. "),
                                                  SizedBox(
                                                    width: context.mediaSize
                                                                .width >
                                                            1366
                                                        ? 256
                                                        : 740,
                                                    child: const Text(
                                                      "Conocimientos de inglés: Dado que la entrevista se realizó en alemán, no se puede evaluar el nivel de inglés del candidato. Las puntuaciones para el inglés entre 1 y 100 no pueden calcularse sin información adicional.",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Voice
                                    SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Lorem ipsum dolor sit amet consectetur. Varius diam dolor at feugiat.",
                                            style: GoogleFonts.montserrat(),
                                          ),
                                          const SizedBox(height: 16),
                                          AnimatedSize(
                                            alignment: Alignment.topCenter,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: SizedBox(
                                              width: context.mediaSize.width,
                                              child: Card(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Speed of Speech",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Wrap(
                                                            crossAxisAlignment:
                                                                WrapCrossAlignment
                                                                    .center,
                                                            children: [
                                                              Visibility(
                                                                visible:
                                                                    !_openSpeedOfSpeech,
                                                                child: Text(
                                                                  "58%",
                                                                  style: GoogleFonts
                                                                      .montserrat(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                              IconButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    _openSpeedOfSpeech =
                                                                        !_openSpeedOfSpeech;
                                                                  });
                                                                },
                                                                icon: Icon(
                                                                  _openSpeedOfSpeech
                                                                      ? Icons
                                                                          .keyboard_arrow_up
                                                                      : Icons
                                                                          .keyboard_arrow_down,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            _openSpeedOfSpeech,
                                                        child: const SizedBox(
                                                          height: 16,
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            _openSpeedOfSpeech,
                                                        child:
                                                            const SpeechGraphic(
                                                          title:
                                                              "Conversational",
                                                          startTitle: "Slow",
                                                          endTitle: "Fast",
                                                          progress: 58,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          /// Number of Fillings
                                          AnimatedSize(
                                            alignment: Alignment.topCenter,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            child: Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Number of fillings",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Wrap(
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .center,
                                                          children: [
                                                            Visibility(
                                                              visible:
                                                                  !_openNumberOfFillings,
                                                              child: Text(
                                                                "3 Fillers",
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  _openNumberOfFillings =
                                                                      !_openNumberOfFillings;
                                                                });
                                                              },
                                                              icon: Icon(
                                                                _openNumberOfFillings
                                                                    ? Icons
                                                                        .keyboard_arrow_up
                                                                    : Icons
                                                                        .keyboard_arrow_down,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _openNumberOfFillings,
                                                      child: const SizedBox(
                                                        height: 16,
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _openNumberOfFillings,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: RolePlayColors
                                                              .primary100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            8,
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Center(
                                                          child: Text(
                                                            "Nice job! It’s natural to have fewer than 4% fillers.",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _openNumberOfFillings,
                                                      child: const SizedBox(
                                                        height: 16,
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _openNumberOfFillings,
                                                      child: Wrap(
                                                        spacing: 4,
                                                        children: [
                                                          FillerButton(
                                                            onPressed: () {},
                                                            label: "Uh",
                                                          ),
                                                          FillerButton(
                                                            onPressed: () {},
                                                            number: 2,
                                                            label: "Ah",
                                                          ),
                                                          FillerButton(
                                                            onPressed: () {},
                                                            number: 3,
                                                            label: "Mm",
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          /// Coherence of the speech
                                          AnimatedSize(
                                            alignment: Alignment.topCenter,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            child: Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Coherence of the speech",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Wrap(
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .center,
                                                          children: [
                                                            Visibility(
                                                              visible:
                                                                  !_openCoherenceOfTheSpeech,
                                                              child: Text(
                                                                "30%",
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  _openCoherenceOfTheSpeech =
                                                                      !_openCoherenceOfTheSpeech;
                                                                });
                                                              },
                                                              icon: Icon(
                                                                _openCoherenceOfTheSpeech
                                                                    ? Icons
                                                                        .keyboard_arrow_up
                                                                    : Icons
                                                                        .keyboard_arrow_down,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _openCoherenceOfTheSpeech,
                                                      child: const SizedBox(
                                                        height: 16,
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _openCoherenceOfTheSpeech,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: RolePlayColors
                                                              .primary100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            8,
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Center(
                                                          child: Text(
                                                            "Nice job! It’s natural to have fewer than 4% fillers.",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _openCoherenceOfTheSpeech,
                                                      child: const SizedBox(
                                                        height: 16,
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _openCoherenceOfTheSpeech,
                                                      child: Center(
                                                        child: Column(
                                                          children: [
                                                            /// Spider chart
                                                            SizedBox(
                                                              width: 200,
                                                              height: 200,
                                                              child:
                                                                  SpiderChart(
                                                                data: const [
                                                                  7,
                                                                  5,
                                                                  10,
                                                                  7,
                                                                  4,
                                                                ],
                                                                maxValue:
                                                                    10, // the maximum value that you want to represent (essentially sets the data scale of the chart)
                                                                colors: const [
                                                                  Colors.red,
                                                                  Colors.green,
                                                                  Colors.blue,
                                                                  Colors.yellow,
                                                                  Colors.indigo,
                                                                ],
                                                              ),
                                                            ),

                                                            /// Pie Chart
                                                            const SizedBox(
                                                              width: 300,
                                                              height: 300,
                                                              child: PieChart(
                                                                dataMap: <String,
                                                                    double>{
                                                                  "Data 1": 5,
                                                                  "Data 2": 3,
                                                                  "Data 3": 2,
                                                                  "Data 4": 2,
                                                                },
                                                              ),
                                                            ),

                                                            /// Line Chart
                                                            SizedBox(
                                                              width: 300,
                                                              height: 300,
                                                              child: Sparkline(
                                                                data: const [
                                                                  0.0,
                                                                  1.0,
                                                                  1.5,
                                                                  2.0,
                                                                  0.0,
                                                                  0.0,
                                                                  -0.5,
                                                                  -1.0,
                                                                  -0.5,
                                                                  0.0,
                                                                  0.0,
                                                                ],
                                                                lineWidth: 10.0,
                                                                lineGradient:
                                                                    LinearGradient(
                                                                  begin: Alignment
                                                                      .topCenter,
                                                                  end: Alignment
                                                                      .bottomCenter,
                                                                  colors: [
                                                                    Colors
                                                                        .purple
                                                                        .shade400,
                                                                    Colors
                                                                        .purple
                                                                        .shade200,
                                                                  ],
                                                                ),
                                                              ),
                                                            ),

                                                            /// Bar chart
                                                            SimpleBarChart(
                                                              listOfHorizontalBarData: [
                                                                HorizontalDetailsModel(
                                                                  name: '1',
                                                                  color: const Color(
                                                                      0xFFEB7735),
                                                                  size: 73,
                                                                ),
                                                                HorizontalDetailsModel(
                                                                  name: '2',
                                                                  color: const Color(
                                                                      0xFFEB7735),
                                                                  size: 92,
                                                                ),
                                                                HorizontalDetailsModel(
                                                                  name: '3',
                                                                  color: const Color(
                                                                      0xFFFBBC05),
                                                                  size: 120,
                                                                ),
                                                                HorizontalDetailsModel(
                                                                  name: '4',
                                                                  color: const Color(
                                                                      0xFFFBBC05),
                                                                  size: 86,
                                                                ),
                                                              ],
                                                              verticalInterval:
                                                                  100,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// Posture
                                    SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Lorem ipsum dolor sit amet consectetur. Varius diam dolor at feugiat.",
                                            style: GoogleFonts.montserrat(),
                                          ),
                                          const SizedBox(height: 16),
                                          AnimatedSize(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: SizedBox(
                                              width: context.mediaSize.width,
                                              child: Card(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Column(
                                                    children:
                                                        ListTile.divideTiles(
                                                      color: Colors.grey,
                                                      tiles: List.generate(
                                                        10,
                                                        (index) {
                                                          return PostureProgress(
                                                            progress: Random()
                                                                    .nextInt(
                                                                  80,
                                                                ) +
                                                                20,
                                                            description:
                                                                "Posture description",
                                                          );
                                                        },
                                                      ),
                                                    ).toList(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
