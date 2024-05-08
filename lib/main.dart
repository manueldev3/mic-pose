import 'package:role_play/screens/VideoStreaming.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:role_play/screens/home_screen.dart';
import 'package:role_play/theme/role_play_theme.dart';

/*
IO.Socket socket = IO.io("http://localhost:5000", <String, dynamic>{
  'transports': ['websocket'],
  'extraHeaders': {'foo': 'bar'} // optional
});*/

var PC_CONFIG = {
  'iceServers': [
    {
      'urls': [
        'stun:stun.l.google.com:19302',
        'stun:stun1.l.google.com:19302',
        'stun:stun2.l.google.com:19302',
        'stun:stun3.l.google.com:19302',
        'stun:stun4.l.google.com:19302'
      ]
    },
  ]
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: RolePlayColors.backgroundDark,
      ),
      home: const MainApp(),
    ),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    /*
    SignallingService.instance
        .init(websocketUrl: "ws://127.0.0.1:5000", selfCallerID: "000001");
    */


    return HomeScreen();
  }
}
