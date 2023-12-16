import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymessages/main.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: mq.width * .03, vertical: mq.height * .01),
      child: InkWell(
        onTap: () {},
        child: const ListTile(
          leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
          title: Text('Name of the person'),
          subtitle: Text('Last mesaage of the user goes here ', maxLines: 1),
          trailing: Text('12:30', style: TextStyle(color: Colors.black54)),
        ),
      ),
    );
  }
}
