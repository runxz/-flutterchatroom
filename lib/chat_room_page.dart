import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class ChatRoomPage extends StatefulWidget {
  final String token;

  ChatRoomPage(this.token);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final messageController = TextEditingController();
  final socket = IO.io('ws://192.168.18.26:3000', <String, dynamic>{
    'transports': ['websocket'],
  });
  final messages = <String>[];

  Future<String> _getName() async {
    final SharedPreferences prefs = await _prefs;
    final String name = (prefs.getString('name') ?? 'unknown');
    return name;
  }

  Color getRandomColor() {
    var random = Random();
    return Color.fromRGBO(
        random.nextInt(256), random.nextInt(256), random.nextInt(256), 1);
  }

  @override
  void initState() {
    super.initState();
    socket.onConnect((_) {
      print('connected');
    });
    socket.on('chat message', (data) {
      setState(() {
        messages.add(data);
      });
    });
    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: getRandomColor(),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            messages[index],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.emoji_emotions),
                        onPressed: () {
                          // Handle emoji button press
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          TextField(
            controller: messageController,
            decoration: InputDecoration(labelText: 'Message'),
          ),
          ElevatedButton(
            onPressed: () {
              String msg = messageController.text;
              _getName().then((name) {
                socket.emit('chat message', '$name : $msg');
                messageController.clear();
              });
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
