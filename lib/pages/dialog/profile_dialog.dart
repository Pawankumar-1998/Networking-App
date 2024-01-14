import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymessages/main.dart';
import 'package:mymessages/models/chat_user.dart';
import 'package:mymessages/pages/user_profile_page.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.chatUserOpp});
  final ChatUser chatUserOpp;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            // for the profie pic
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .1),
                child: CachedNetworkImage(
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                  imageUrl: chatUserOpp.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),

            // for the text of the user
            Positioned(
              left: mq.width * .02,
              top: mq.height * .01,
              width: mq.width * .55,
              child: Text(
                chatUserOpp.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // info button
            Align(
              alignment: Alignment.topRight       ,
              child: MaterialButton(
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OppUserProfilePage(chatUser: chatUserOpp),
                      ));
                },
                child: const Icon(Icons.info_outline,
                    color: Colors.blue, size: 30),
              ),
            )
          ],
        ),
      ),
    );
  }
}
