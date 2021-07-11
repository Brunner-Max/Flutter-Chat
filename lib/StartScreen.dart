import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'ChatRoomOverView.dart';

IO.Socket socketIOInstance = IO.io('SOCKET_IO_SERVER_URL',
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build()
);

String chatUserName = "";

void main() {
  socketIOInstance.onConnect((_) {
    runApp(StartScreen());
  });

  socketIOInstance.connect();
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: StartScreenWidget(),
    );
  }
}

class StartScreenWidget extends StatelessWidget {
  final String randomName = new Faker().internet.userName();
  final chatRoomsMaxUserCount = [2,3,4,7,2,12];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1A26),
      appBar: AppBar(
        title: Text("simple chatroom application"),
        centerTitle: true,
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
                  new TextField (
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                      hintText: randomName,
                      hintStyle: TextStyle(fontSize: 20.0, color: Colors.white60),
                    ),
                    onSubmitted: (text){
                      String userName = "";
                      if(text.length >0){
                        userName = text;
                      }

                      else{
                        userName = randomName;
                      }

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ChatRoomOverView(context, userName, socketIOInstance, chatRoomsMaxUserCount))
                      );

                    },
                    onChanged: (text){
                      chatUserName = text;
                    },
                  ),

            new TextButton(
              child: Text(
                  "ENTER CHAT",
                  style: TextStyle(fontSize: 14, color: Colors.white)
              ),
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(30)),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(45.0),
                          side: BorderSide(color: Colors.white60)
                      )
                  )
              ),

              onPressed: () {
                var userName = "";
                if(chatUserName.length == 0){
                  userName = randomName;
                }

                else{
                  userName = chatUserName;
                }

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChatRoomOverView(context, userName, socketIOInstance, chatRoomsMaxUserCount))
                );
              },
            ),
          ],
        ),
    );
  }
}