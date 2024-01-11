// ignore_for_file: use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymessages/helper/my_date_util.dart';
import 'package:mymessages/models/chat_user.dart';

import '../main.dart';

class OppUserProfilePage extends StatefulWidget {
  final ChatUser chatUser;
  const OppUserProfilePage({super.key, required this.chatUser});

  @override
  State<OppUserProfilePage> createState() => _OppUserProfilePageState();
}

class _OppUserProfilePageState extends State<OppUserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Profile'),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Joined on ',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: mq.width * .01),
              Text(
                MyDateUtil.getLastMessageTime(
                    context: context,
                    time: widget.chatUser.createdAt,
                    showYear: true),
                style: const TextStyle(fontSize: 20, color: Colors.black54),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: mq.height * .03),
                  // using the stack to place one widget upon another
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      imageUrl: widget.chatUser.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),

                  // for the email
                  SizedBox(height: mq.height * .03),
                  Text(
                    widget.chatUser.email,
                    style: const TextStyle(fontSize: 20, color: Colors.black54),
                  ),

                  // for about
                  SizedBox(height: mq.height * .01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: mq.width * .01),
                      Text(
                        widget.chatUser.about,
                        style: const TextStyle(
                            fontSize: 17, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

// this function is for calling the bottom model
