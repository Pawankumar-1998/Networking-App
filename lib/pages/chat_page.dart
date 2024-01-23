import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymessages/authprovider/provider.dart';
import 'package:mymessages/helper/my_date_util.dart';
import 'package:mymessages/models/chat_user.dart';
import 'package:mymessages/models/message.dart';
import 'package:mymessages/pages/user_profile_page.dart';
import 'package:mymessages/widgets/message_card.dart';

import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser chatUserOpp;
  const ChatScreen({super.key, required this.chatUserOpp});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //  for storing list of messages of the both users
  List<Message> messageList = [];
// this will contains opp user's document
  List<ChatUser> listOfOppUserDocument = [];
  //  to store the text in the the text editing controller
  final textController = TextEditingController();
  //  for the emoji
  bool showEmoji = false;
  //  for images uploading
  bool imageIsUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (showEmoji) {
              setState(() {
                showEmoji = !showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 203, 233, 247),
            body: Column(
              children: [
                // this is for the messaging area where the user can see messages
                Expanded(
                  child: StreamBuilder(
                    stream: Providers.getMessages(widget.chatUserOpp),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:

                          /// snapshot has the bundle of document get all the document from the
                          /// snapshot and store in the messageData variable
                          final messageData = snapshot.data?.docs;

                          // log('Data ${jsonEncode(messageData![0].data())}');
                          messageList = messageData
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (messageList.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: messageList.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: messageList[index],
                                );
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
                // this is for the loading effect when the images are uploading
                if (imageIsUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )),
                //  chat input where the user types the message
                _chatInput(),
                //  the below lines will be for the emoji section
                if (showEmoji)
                  SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                      textEditingController: textController,
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // this function is for our custom app bar
  Widget _appBar() {
    return InkWell(
        onTap: () {
          // when user clicks on the app bar he should move to opp user profile screen to see his details
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    OppUserProfilePage(chatUser: widget.chatUserOpp),
              ));
        },
        child: StreamBuilder(
          stream: Providers.getOppUserInfo(widget.chatUserOpp),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                //  this contains the list of opp user documents
                final oppUserDocuments = snapshot.data?.docs;
                listOfOppUserDocument = oppUserDocuments
                        ?.map((e) => ChatUser.fromJson(e.data()))
                        .toList() ??
                    [];

                return Row(
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
                        imageUrl: listOfOppUserDocument.isNotEmpty
                            ? listOfOppUserDocument[0].image
                            : widget.chatUserOpp.image,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person),
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
                          listOfOppUserDocument.isNotEmpty
                              ? listOfOppUserDocument[0].name
                              : widget.chatUserOpp.name,
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        // for last seen
                        Text(
                          listOfOppUserDocument.isNotEmpty
                              ? listOfOppUserDocument[0].isOnline
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive:
                                          listOfOppUserDocument[0].lastActive)
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive:
                                      listOfOppUserDocument[0].lastActive),
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        )
                      ],
                    )
                  ],
                );
            }
          },
        ));
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
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          showEmoji = !showEmoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      )),

                  // this is for the text field
                  Expanded(
                      child: TextField(
                    controller: textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (showEmoji) {
                        setState(() {
                          showEmoji = !showEmoji;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none,
                    ),
                  )),

                  // for gallery
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick a list of images.
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 60);

                        //  iterate through the list and send the images
                        for (var singleImage in images) {
                          //  change the state and set image is uploading to true
                          setState(() {
                            imageIsUploading = !imageIsUploading;
                          });
                          await Providers.sendImageAsMessage(
                              widget.chatUserOpp, File(singleImage.path));
                          //  change the state and set the image is uploading is false
                          setState(() {
                            imageIsUploading = !imageIsUploading;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                      )),

                  // for camera
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 60);
                        if (image != null) {
                          log('image path : ${image.path}  --- meme type : ${image.mimeType}');
                          await Providers.sendImageAsMessage(
                              widget.chatUserOpp, File(image.path));
                        }
                      },
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
            onPressed: () {
              if (textController.text.isNotEmpty) {
                if (messageList.isEmpty) {
                  log('${messageList.length}');
                  // if the message list is empty means it is the first message
                  Providers.sendFirstMessage(
                      widget.chatUserOpp, textController.text, Type.text);
                } else {
                  log('message list ${messageList.length}');
                  Providers.sendMessage(
                      widget.chatUserOpp, textController.text, Type.text);
                }
                textController.clear();
              }
            },
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, size: 28, color: Colors.white),
          )
        ],
      ),
    );
  }
}
