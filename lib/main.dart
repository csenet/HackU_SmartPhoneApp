import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:vibration/vibration.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'HackU 振動連動アプリ';

    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isRed = false;
  bool _isBlocking = false;
  IOWebSocketChannel _ws;
  String _socketMessage = "";
  String _socketStatus = "待機中";

  @override
  Widget build(BuildContext context) {
    _ws = IOWebSocketChannel.connect(
        'ws://hacku.australiacentral.cloudapp.azure.com/');

    _ws.stream.listen((msg) {
      setState(() {
        this._socketStatus = "振動中";
        this._isRed = true;
        this._socketMessage = msg;
      });
      this._vibrate();
      this._isBlocking = true;
      Timer timeCounter = new Timer(new Duration(seconds: 3), () {
        if (!this._isBlocking) {
          setState(() {
            this._isRed = false;
            this._socketMessage = "";
            this._socketStatus = "待機中";
          });
        } else {
          this._isBlocking = false;
        }
      });
    });
    //widget.channel.stream.listen((message) {});
    return Scaffold(
      backgroundColor: this._isRed ? Colors.red : Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*
                Form(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Send a message'),
                  ),
                ),
                */
            Text(
              this._socketStatus,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(this._socketMessage),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "〈注意〉\nこのアプリはバックグラウンドやロック画面では動作しません。使用時には，[設定]からディスプレイをOFFにする等の設定をお願いします。",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 1000);
    }
  }

  @override
  void dispose() {
    this._ws.sink.close();
    super.dispose();
  }
}
