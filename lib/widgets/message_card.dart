import 'package:flutter/material.dart';
import 'package:mymessages/authprovider/provider.dart';
import 'package:mymessages/helper/my_date_util.dart';
import 'package:mymessages/main.dart';
import 'package:mymessages/models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Providers.googleAuthUser.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  //  for opposite person message
  Widget _blueMessage() {
    // update the read status if the auth user and the owner of the message document is different
    if (widget.message.read.isEmpty) {
      Providers.updateMessageReadStatus(message: widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //  first child message
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                border: Border.all(color: Colors.lightBlue)),
            child: Text(
              widget.message.msg,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ),

        //  second child for time
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),
        )
      ],
    );
  }

  //  for our own message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // this is for the time
        Row(
          children: [
            // for space
            SizedBox(
              width: mq.width * .02,
            ),
            //  for the double tick
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
              ),
            // for space
            SizedBox(
              width: mq.width * .02,
            ),
            // for time
            Text(MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent)),
          ],
        ),
        //  this for the message content flixible is used because as the content of the message increese  the container which is flexible also increases
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            padding: EdgeInsets.all(mq.width * .04),
            decoration: BoxDecoration(
              color: Colors.lightGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        )
      ],
    );
  }
}
