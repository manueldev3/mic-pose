import 'dart:async';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocket {
  // ------------------------- Members ------------------------- //
  late String url;
  WebSocketChannel? _channel;
  StreamController<bool> streamController = StreamController<bool>.broadcast();

  // ---------------------- Getter Setters --------------------- //
  String get getUrl {
    return url;
  }

  set setUrl(String url) {
    this.url = url;
  }

  Stream<dynamic> get stream {
    if (_channel != null) {
      return _channel!.stream;
    } else {
      throw WebSocketChannelException("The connection was not established !");
    }
  }

  // --------------------- Constructor ---------------------- //
  WebSocket(this.url);

  // ---------------------- Functions ----------------------- //

  /// Connects the current application to a websocket
  void connect() async {
    _channel = IOWebSocketChannel.connect(Uri.parse(url));
  }

  void send_message() async{
    _channel!.sink.add("data_data_data");
  }

  /// Disconnects the current application from a websocket
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
    }
  }
}