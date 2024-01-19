import 'package:cached_network_image/cached_network_image.dart';
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
    bool myMsg = Providers.googleAuthUser.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(myMsg);
      },
      child: myMsg ? _greenMessage() : _blueMessage(),
    );
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
              padding: EdgeInsets.all(widget.message.type == Type.image
                  ? mq.width * .03
                  : mq.width * .04),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .04, vertical: mq.height * .01),
              decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  border: Border.all(color: Colors.lightBlue)),
              child: widget.message.type == Type.text
                  ? Text(
                      widget.message.msg,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 16),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        // width: mq.height * .05,
                        // height: mq.height * .05,
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 70),
                      ),
                    )),
        ),

        //  second child for time
        Padding(
          padding: EdgeInsets.only(right: mq.width * .01),
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
              padding: EdgeInsets.all(widget.message.type == Type.image
                  ? mq.width * .03
                  : mq.width * .04),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                border: Border.all(color: Colors.green),
              ),
              child: widget.message.type == Type.text
                  ? Text(
                      widget.message.msg,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        // width: mq.height * .30,
                        // height: mq.height * .30,
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 70),
                      ),
                    )),
        )
      ],
    );
  }

//  this below code is for the bottom sheet
  void _showBottomSheet(bool myMsg) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            // divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .4, vertical: mq.height * .015),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            // first row for copy item or the save option for image
            widget.message.type == Type.text
                ? _OptionItems(
                    icon: const Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Copy Text',
                    onTap: () {},
                  )
                : _OptionItems(
                    icon: const Icon(Icons.save_alt),
                    name: 'Save',
                    onTap: () {},
                  ),
            // divider
            if (myMsg)
              Divider(
                color: Colors.black,
                indent: mq.width * .04,
                endIndent: mq.width * .04,
              ),
            //  second row for the edit option
            if (widget.message.type == Type.text && myMsg)
              _OptionItems(
                icon: const Icon(Icons.edit, color: Colors.blue),
                name: 'Edit',
                onTap: () {},
              ),
            // third row is for delete option
            if (myMsg)
              _OptionItems(
                icon: const Icon(Icons.delete, color: Colors.blue),
                name: 'Delete',
                onTap: () {},
              ),
            // divider
            Divider(
              color: Colors.black,
              indent: mq.width * .04,
              endIndent: mq.width * .04,
            ),
            // fourth row is for dilvered at option
            _OptionItems(
              icon: const Icon(
                Icons.remove_red_eye_rounded,
                color: Colors.blue,
              ),
              name: 'Delivered at :',
              onTap: () {},
            ),
            // fifth row is for seen at option
            _OptionItems(
              icon: const Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.green,
              ),
              name: 'Seen at :',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }
}

//  stateless widget for the icons and the row
class _OptionItems extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItems(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .015),
        child: Row(children: [
          // icon
          icon,
          // name
          Text(
            '     $name',
            style: const TextStyle(
                fontSize: 15, color: Colors.black54, letterSpacing: 0.5),
          )
        ]),
      ),
    );
  }
}
