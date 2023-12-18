
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mymessages/authprovider/provider.dart';
import 'package:mymessages/models/chat_user.dart';
import 'package:mymessages/pages/auth/login_page.dart';
import 'package:mymessages/widgets/chat_user_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<ChatUser> list = [];

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        centerTitle: true,
        title: const Text('We chat'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () async {
            await Providers.auth.signOut();
            await GoogleSignIn().signOut();
          },
          child: const Icon(Icons.add_comment_rounded),
        ),
      ),
      body: StreamBuilder(
          stream: Providers.firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());

              case ConnectionState.active:
              case ConnectionState.done:
                final data = snapshot.data?.docs;
                list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                    [];
            }
            if (list.isNotEmpty) {
              return ListView.builder(
                padding: EdgeInsets.only(top: mq.height * .01),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return ChatUserCard(
                    user: list[index],
                  );
                },
              );
            } else {
              return const Center(
                child: Text(
                  'No data available !',
                  style: TextStyle(fontSize: 30),
                ),
              );
            }
          }),
    );
  }
}
