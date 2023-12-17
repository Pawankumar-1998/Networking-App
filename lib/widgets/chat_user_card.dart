import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymessages/pages/auth/login_page.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

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
