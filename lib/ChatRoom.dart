import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bubble/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import "package:universal_html/html.dart" as UniversalHTML;

String message = "";
List<ChatMessage> chatMessagesList = [];
bool runningOnAndroid = true;

//COLORS//
Color colorSystemMessage = Color(0xFF4F7C5B);
Color colorUserMessage = Color(0xFF4F547C);
Color colorForeignUserMessage = Color(0xFF7C4F59);
//COLORS//

final messageTextController = TextEditingController();

class Chatroom extends StatefulWidget{
  final int chatroomNumber;
  final String chatUserName;
  final IO.Socket socketIOInstance;

  Chatroom(this.chatroomNumber, this.chatUserName, this.socketIOInstance);

  @override
  State<StatefulWidget> createState() => _ChatRoomStateFullWidget(chatroomNumber.toString(), chatUserName, socketIOInstance);

}

class _ChatRoomStateFullWidget extends State<Chatroom>{
  final String chatroomNumber, chatUserName;
  final IO.Socket socketIOInstance;
  final _listViewScrollController = ScrollController();


  _ChatRoomStateFullWidget(this.chatroomNumber, this.chatUserName, this.socketIOInstance){

    if(kIsWeb){
      final userAgent = UniversalHTML.window.navigator.userAgent.toString().toLowerCase();
      if(!userAgent.contains("android")){
        runningOnAndroid = false;
      }
    }

    socketIOInstance.on("receive_new_message", (data){
      ChatMessage chatMessage = ChatMessage.fromJson(jsonDecode(data));
      chatMessagesList.add(chatMessage);

      SchedulerBinding.instance!.addPostFrameCallback((_) {
        _listViewScrollController.jumpTo(_listViewScrollController.position.maxScrollExtent);
      });

      setState((){});
    });


    socketIOInstance.once("joined_chat_room", (data){
      socketIOInstance.emit("update_chatroom_user_count");
    });


    List<String> tags = [chatroomNumber, chatUserName];
    String jsonMessage = jsonEncode(tags);
    socketIOInstance.emit('join_chatroom', jsonMessage);
  }

  void sendNewMessage(String messageText){
    List<String> tags = [chatroomNumber, chatUserName, messageText];
    String jsonMessage = jsonEncode(tags);
    socketIOInstance.emit('send_new_message', jsonMessage);
  }

    @override
    Widget build(BuildContext context) {
      return new WillPopScope(
          onWillPop: _catchPop,
          child: new Scaffold(
        backgroundColor: Color(0xFF0D1A26),
        appBar: AppBar(
          title: Text("Chatroom #$chatroomNumber"),
          centerTitle: true,
        ),
        body:  new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              new Expanded(child: _chatMessagesListView()),
              new Padding(padding: EdgeInsets.only(bottom: 10)),
              new Stack(
                  children: <Widget>[
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: TextField (
                          maxLines: null,
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.white),
                          controller: messageTextController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'write a message...',
                            hintStyle: TextStyle(fontSize: 20.0, color: Colors.white60),
                            contentPadding: const EdgeInsets.only(left: 25, right: 50, bottom: 17),
                          ),
                          onChanged: (messageText){
                             message = messageText;
                          },

                        onSubmitted: (messageText){
                          if(messageText.length >0){
                            messageTextController.clear();
                            sendNewMessage(messageText);
                            message = "";
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("You can't send an empty message"),
                            ));
                          }

                        },
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child:IconButton(
                            icon: Icon(Icons.send),
                            iconSize: 30,
                            color: Colors.white,
                            padding: EdgeInsets.only(right: 15, bottom: 10),
                            onPressed: () {
                              if(message.length >0){
                                messageTextController.clear();
                                sendNewMessage(message);
                                message = "";
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("You can't send an empty message"),
                                ));
                              }
                            }
                        )
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }

  ListView _chatMessagesListView() {
    return ListView.builder(
      controller: _listViewScrollController,
      itemCount: chatMessagesList.length,
      itemBuilder: (_, index){
        return _chatMessageBubble(index);
      },
    );
  }

  Bubble _chatMessageBubble(int index){
    BubbleNip bubbleNip;
    Alignment alignment;
    BubbleEdges bubbleEdges;
    bool showBubbleNip;
    Color backgroundColor;

    if(chatMessagesList[index].chatUserName == chatUserName){
      bubbleNip = BubbleNip.rightTop;
      alignment = Alignment.topRight;
      bubbleEdges = BubbleEdges.only(top: 10, left: 100);
      backgroundColor = colorUserMessage;
    }

    else if(chatMessagesList[index].chatUserName == "SYSTEM"){
      bubbleNip = BubbleNip.no;
      alignment = Alignment.center;
      bubbleEdges = BubbleEdges.only(top: 10);
      backgroundColor = colorSystemMessage;
    }

    else{
      bubbleNip = BubbleNip.leftTop;
      alignment = Alignment.topLeft;
      bubbleEdges = BubbleEdges.only(top: 10, right: 100);
      backgroundColor = colorForeignUserMessage;
    }
    if(!runningOnAndroid){
      if(index >0 && chatMessagesList[index-1].chatUserName == chatMessagesList[index].chatUserName){
        showBubbleNip = false;
      }
      else{
        showBubbleNip = true;
      }
    }

    else{
      showBubbleNip = false;
    }

    return Bubble(
        color: backgroundColor,
        margin: bubbleEdges,
        alignment: alignment,
        nip: bubbleNip,
        showNip: showBubbleNip,
        elevation: 2,
        shadowColor: Colors.white,
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.end,
          children: [
            Text(
              chatMessagesList[index].messageText,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.left,
            ),

            Padding(
              padding: EdgeInsets.only(right: 10),
            ),

            Text(
              chatMessagesList[index].chatUserName,
              style: TextStyle(color: Colors.white60, fontSize: 14),
              textAlign: TextAlign.right,
            ),

          ],
        )
    );
  }


    Future<bool> _catchPop(){
      //LEAVE CURRENT CHAT ROOM//
      socketIOInstance.on("left_chat_room", (data){
        if(data.toString() == chatroomNumber){
          socketIOInstance.off('receive_new_message');
        }
      });
      List<String> tags = [chatroomNumber, chatUserName];
      String jsonMessage = jsonEncode(tags);
      socketIOInstance.emit("leave_chatroom", jsonMessage);
      //LEAVE CURRENT CHAT ROOM//

      //UPDATE CHAT USER COUNT//
      socketIOInstance.emit("update_chatroom_user_count");
      //UPDATE CHAT USER COUNT//

      chatMessagesList.clear();
      return new Future.value(true);
    }


  }


class ChatMessage {
  String chatUserName, messageText;

  ChatMessage(this.chatUserName, this.messageText);

  factory ChatMessage.fromJson(dynamic json) {
    return ChatMessage(json['chatUserName'] as String, json['messageText'] as String);
  }

  @override
  String toString() {
    return '{ ${this.chatUserName}, ${this.messageText} }';
  }
}
