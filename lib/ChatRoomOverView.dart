import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'ChatRoom.dart';

class ChatRoomOverView extends StatefulWidget{
  final BuildContext context;
  final String chatUserName;
  final IO.Socket socketIOInstance;
  final chatRoomsMaxUserCount;

  ChatRoomOverView(this.context, this.chatUserName, this.socketIOInstance, this.chatRoomsMaxUserCount);

  @override
  State<StatefulWidget> createState() => _ChatRoomOverViewStateFullWidget(chatUserName, socketIOInstance);
}

class _ChatRoomOverViewStateFullWidget extends State<ChatRoomOverView>{
  List<String> chatRoomUserCountList = ["0", "0", "0", "0", "0", "0"];
  List<int> chatRoomMaxUserCountList = [2, 4, 6, 8, 10, 12];

  final String chatUserName;
  final IO.Socket socketIOInstance;
  _ChatRoomOverViewStateFullWidget(this.chatUserName, this.socketIOInstance){
    socketIOInstance.on("chatroom_client_count", (data){
      ChatRoomUserCount chatRoomUserCount = ChatRoomUserCount.fromJson(jsonDecode(data));
      setState(() {
        chatRoomUserCountList = [
          chatRoomUserCount.chatroom1,
          chatRoomUserCount.chatroom2,
          chatRoomUserCount.chatroom3,
          chatRoomUserCount.chatroom4,
          chatRoomUserCount.chatroom5,
          chatRoomUserCount.chatroom6,
        ];
      });
    });

    socketIOInstance.emit("update_chatroom_user_count");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1A26),
      appBar: AppBar(
        title: Text("simple chatroom application"),
        centerTitle: true,
      ),
      body: new Container(
        child: _chatRoomsListView(),
      ),
    );
  }

  ListView _chatRoomsListView() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, index){
        return Card(
          color: Colors.black12,
          child:  ListTile(
            title: Text('Chatroom #' + (index+1).toString(), style: TextStyle(color: Colors.white),),
            subtitle: Text(chatRoomUserCountList[index] + '/' + chatRoomMaxUserCountList[index].toString(), style: TextStyle(color: Colors.white),),
            trailing: Icon(Icons.arrow_forward, color: Colors.white,),
            onTap: () {
              if(int.parse(chatRoomUserCountList[index]) < chatRoomMaxUserCountList[index]){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Chatroom(index+1, chatUserName, socketIOInstance))
                );
              }
              else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("ROOM IS FULL, CHOOSE AN OTHER!"),
                ));
              }
            },
          ),
        );
      },
    );
  }
}

class ChatRoomUserCount {
  String chatroom1, chatroom2, chatroom3, chatroom4, chatroom5, chatroom6;

  ChatRoomUserCount(this.chatroom1, this.chatroom2, this.chatroom3, this.chatroom4, this.chatroom5, this.chatroom6);

  factory ChatRoomUserCount.fromJson(dynamic json) {
    return ChatRoomUserCount(
      json['chatroom1'] as String,
      json['chatroom2'] as String,
      json['chatroom3'] as String,
      json['chatroom4'] as String,
      json['chatroom5'] as String,
      json['chatroom6'] as String,
    );
  }

  @override
  String toString() {
    return '{ ${this.chatroom1},'
        ' ${this.chatroom2}, '
        '${this.chatroom3}, '
        '${this.chatroom4}, '
        '${this.chatroom5}, '
        '${this.chatroom6} }';
  }
}