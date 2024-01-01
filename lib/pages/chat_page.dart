import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mymessages/authprovider/provider.dart';
import 'package:mymessages/models/chat_user.dart';

import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser chatUser;
  const ChatScreen({super.key, required this.chatUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        body: Column(
          children: [
            // this is for the messaging area where the user can see messages
            Expanded(
              child: StreamBuilder(
                stream: Providers.getMessages(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final messageData = snapshot.data?.docs;
                      log('Data ${jsonEncode(messageData![0].data())}');

                      final list = ['Pawan', 'Kumar'];

                      if (list.isNotEmpty) {
                        return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return Text('Message ${list[index]}');
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'No Messages available',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }
                  }
                },
              ),
            ),
            //  chat input where the user types the message
            _chatInput(),
          ],
        ),
      ),
    );
  }

  // this function is for our custom app bar
  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          //  back button
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),

          // user profile picture
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .03),
            child: CachedNetworkImage(
              width: mq.height * .05,
              height: mq.height * .05,
              imageUrl: widget.chatUser.image,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.person),
            ),
          ),

          const SizedBox(width: 15),

          // name of the user and last seen
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // for name
              Text(
                widget.chatUser.name,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              // for last seen
              const Text(
                'Last seen not available',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                    fontWeight: FontWeight.normal),
              )
            ],
          )
        ],
      ),
    );
  }

  // this function is for buttom chat input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  // for emoji
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      )),

                  // this is for the text field
                  const Expanded(
                      child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Enter a message',
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none,
                    ),
                  )),

                  // for gallery
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                      )),

                  // for camera
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.blueAccent,
                      )),
                ],
              ),
            ),
          ),

          // send message button
          MaterialButton(
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            onPressed: () {},
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, size: 28, color: Colors.white),
          )
        ],
      ),
    );
  }
}
