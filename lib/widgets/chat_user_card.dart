import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mymessages/main.dart';
import 'package:mymessages/models/chat_user.dart';
import 'package:mymessages/pages/chat_page.dart';

class ChatUserCard extends StatefulWidget {
  // this user contains all the details of the Chat user
  final ChatUser chatUser;
  const ChatUserCard({super.key, required this.chatUser});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
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
                builder: (_) => ChatScreen(chatUser: widget.chatUser),
              ));
        },
        child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .3),
              child: CachedNetworkImage(
                width: mq.height * .055,
                height: mq.height * .055,
                imageUrl: widget.chatUser.image,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.person),
              ),
            ),
            title: Text(widget.chatUser.name),
            subtitle: Text(widget.chatUser.about, maxLines: 1),
            trailing:
                // const Text('12:30', style: TextStyle(color: Colors.black54)),
                Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                  color: Colors.greenAccent.shade400,
                  borderRadius: BorderRadius.circular(10)),
            )),
      ),
    );
  }
}
