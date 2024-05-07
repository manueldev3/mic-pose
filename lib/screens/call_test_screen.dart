import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:role_play/services/SignalingService.dart';

class CallTestScreen extends StatefulWidget {
  final String callerID, calledId;
  final dynamic offer;

  const CallTestScreen(
      {super.key, required this.callerID, required this.calledId, this.offer});

  @override
  State<CallTestScreen> createState() => _CallTestScreenState();
}

class _CallTestScreenState extends State<CallTestScreen> {
  final socket = SignallingService.instance.socket;
  final _localRTCVideoRenderer = RTCVideoRenderer();
  final _remoteRTCVideoRenderer = RTCVideoRenderer();

  RTCPeerConnection? _rtcPeerConnection;
  List<RTCIceCandidate> rtcIceCandidates = [];

  bool isAudioOn = true, isVideoOn = true;

  @override
  void initState() {
    _remoteRTCVideoRenderer.initialize();

    _setupPeerConnection();
    super.initState();
  }

  _setupPeerConnection() async {
    _rtcPeerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    });
    // listen for remotePeer mediaTrack event
    _rtcPeerConnection!.onTrack = (event) {
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      setState(() {});
    };
    if (widget.offer != null) {
      socket!.on("IceCandidate", (data) {
        String candidate = data["iceCandidate"]["candidate"];
        String sdpMid = data["iceCandidate"]["id"];
        int sdpMLineIndex = data["iceCandidate"]["label"];

        _rtcPeerConnection!.addCandidate(
            RTCIceCandidate(
              candidate,
              sdpMid,
              sdpMLineIndex
            )
          );
        }
      );

      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(
            widget.offer["sdp"],
            widget.offer["type"]
        )
      );

      RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();
      _rtcPeerConnection!.setLocalDescription(answer);

      socket!.emit("answerCall", {
        "callerId": widget.calledId,
        "sdpAnswer": answer.toMap()
      });
    }
    else{
      _rtcPeerConnection!.onIceCandidate =
          (RTCIceCandidate candidate) => rtcIceCandidates.add(candidate);

      socket!.on("callAnswered", (data) async {
          await _rtcPeerConnection!.setRemoteDescription(
            RTCSessionDescription(
                data["sdpAnswer"]["sdp"],
                data["sdpAnswer"]["type"]
            )
          );

          for(RTCIceCandidate candidate in rtcIceCandidates){
            socket!.emit("IceCandidate",{
                "calledId": widget.calledId,
                "iceCandidate":{
                  "id": candidate.sdpMid,
                  "label": candidate.sdpMLineIndex,
                  "candidate": candidate.candidate
                }
              }
            );
          }
        }
      );

      // create SDP Offer
      RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();

      // set SDP offer as localDescription for peerConnection
      await _rtcPeerConnection!.setLocalDescription(offer);

      // make a call to remote peer over signalling
      socket!.emit('makeCall', {
        "calledId": widget.calledId,
        "sdpOffer": offer.toMap(),
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Call Test Screen'),
      ),
      body: SafeArea(
        child: RTCVideoView(
          _remoteRTCVideoRenderer,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        ),
      ),
    );
  }
}
