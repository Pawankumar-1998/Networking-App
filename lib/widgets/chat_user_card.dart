import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymessages/models/chat_user.dart';
import 'package:mymessages/pages/auth/login_page.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

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
        onTap: () {},
        child: ListTile(
          leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
          title: Text(widget.user.name),
          subtitle: Text(widget.user.about, maxLines: 1),
          trailing:
              const Text('12:30', style: TextStyle(color: Colors.black54)),
        ),
      ),
    );
  }
}
