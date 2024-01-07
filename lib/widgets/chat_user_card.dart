import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mymessages/authprovider/provider.dart';
import 'package:mymessages/helper/my_date_util.dart';
import 'package:mymessages/main.dart';
import 'package:mymessages/models/chat_user.dart';
import 'package:mymessages/models/message.dart';
import 'package:mymessages/pages/chat_page.dart';

class ChatUserCard extends StatefulWidget {
  // this user contains all the details of the opposite Chat user
  final ChatUser chatUserOpp;
  const ChatUserCard({super.key, required this.chatUserOpp});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? message; // this contains the last message of the conversation
  List<Message> lastMessageList = [];
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(chatUserOpp: widget.chatUserOpp),
                ));
          },
          child: StreamBuilder(
            stream: Providers.getLastMessage(widget.chatUserOpp),
            builder: (context, snapshot) {
              final fireStoreQueryDocuments = snapshot.data?.docs;
              lastMessageList = fireStoreQueryDocuments
                      ?.map((singleDocument) =>
                          Message.fromJson(singleDocument.data()))
                      .toList() ??
                  [];

              if (lastMessageList.isNotEmpty) {
                message = lastMessageList[0];
              }
              return ListTile(
                  //  image or profile pic of the user
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: widget.chatUserOpp.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person),
                    ),
                  ),
                  //  name of the opp user
                  title: Text(widget.chatUserOpp.name),
                  //  status of the opp user or the last message of the conversation
                  subtitle: Text(
                      message != null ? message!.msg : widget.chatUserOpp.about,
                      maxLines: 1),
                  // green dot for  online
                  trailing: message == null
                      ? null
                      //  if the last message belongs to opp user and it hasnt been seen then the green dot will be shown
                      : message!.read.isEmpty &&
                              message!.fromId != Providers.googleAuthUser.uid
                          ? Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(10)),
                            )
                          //  if the below conditions hits it means the message is read and we should show the sent time of the message
                          : Text(
                              MyDateUtil.getLastMessage(
                                  context: context, sentTime: message!.sent),
                              style: const TextStyle(color: Colors.black54),
                            ));
            },
          )),
    );
  }
}
