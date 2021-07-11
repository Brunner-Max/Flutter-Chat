const express = require('express');
const bodyParser = require('body-parser');
const https = require('https');
const fs = require( 'fs' );
const app = express();
const serverPort = 4000;

app.use(bodyParser.json());

const server = https.createServer({
    key: fs.readFileSync('./ssl_files/private.key'),
    cert: fs.readFileSync('./ssl_files/certificate.crt'),
    ca: fs.readFileSync('./ssl_files/ca_bundle.crt'),
    requestCert: false,
    rejectUnauthorized: false
},app);
server.listen(serverPort);

const io = require('socket.io')(server);

/////////////////////////////////////////////////////////////////////////////////////////////



console.log(new Date(), "SERVER STARTED!");
        
io.on('connection',(socket)=>{    	
	socket.on('join_chatroom', (...args)=>{
		var objectValue = JSON.parse(args);			
		socket.join(objectValue[0]);
		socket.emit("joined_chat_room", objectValue[0]);	
		var messageObject = '{"chatUserName" : "' + "SYSTEM" + '", "messageText" : "' + objectValue[1] + " joined the room" + '"}';
		io.sockets.in(objectValue[0]).emit("receive_new_message", messageObject);		
	});
	
	socket.on('leave_chatroom', (...args)=>{
		var objectValue = JSON.parse(args);				
		socket.leave(objectValue[0]);
		socket.emit("left_chat_room", objectValue[0]);		
		var messageObject = '{"chatUserName" : "' + "SYSTEM" + '", "messageText" : "' + objectValue[1] + " left the room" + '"}';
		io.sockets.in(objectValue[0]).emit("receive_new_message", messageObject);		
	});
	
	
	socket.on('send_new_message', (...args)=>{
		var objectValue = JSON.parse(args);		
		var messageObject = '{"chatUserName" : "' + objectValue[1] + '", "messageText" : "' + objectValue[2] + '"}';
		io.sockets.in(objectValue[0]).emit("receive_new_message", messageObject);		
	});
	
	
	
	socket.on('update_chatroom_user_count', ()=>{
		var chatrooms = ['1', '2', '3', '4', '5', '6'];	
		
		var chatroomCountObject = "";
		
		for(let i = 1; i<7; i++){
			var clients = io.sockets.adapter.rooms.get(chatrooms[i-1]);
			var clientCount = clients ? clients.size : 0;
			
			if(i == 1){
				chatroomCountObject = '{"chatroom1" : "' + clientCount + '", '; 
			}
			
			else if(i == 6){
				chatroomCountObject += '"chatroom6" : "' + clientCount + '"}'; 
			}
			
			else{
				chatroomCountObject += '"chatroom' + i + '" : "' + clientCount + '", '; 
			}
		}
		
		io.emit("chatroom_client_count", chatroomCountObject);		
		
	});
});