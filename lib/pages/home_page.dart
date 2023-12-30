import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mymessages/authprovider/provider.dart';
import 'package:mymessages/main.dart';
import 'package:mymessages/models/chat_user.dart';
import 'package:mymessages/pages/profile_page.dart';
import 'package:mymessages/widgets/chat_user_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ignore: no_leading_underscores_for_local_identifiers
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  // ignore: no_leading_underscores_for_local_identifiers
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    Providers.currentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            centerTitle: true,
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search by name ',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    autofocus: true,
                    onChanged: (value) {
                      _searchList.clear();

                      for (var user in _list) {
                        if (user.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            user.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(user);
                        }
                      }
                      setState(() {
                        _searchList;
                      });
                    },
                  )
                : const Text('We chat'),
            actions: [
              //  this button is for the searching icon
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      // _searchList.clear(); --> if you dont use this the search list will have previous data
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),

              // this button is for profile icon
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          ProfilePage(chatUser: Providers.currentChatUser),
                    ));
                  },
                  icon: const Icon(Icons.people_alt)),
            ],
          ),

          //  this floating action button  below the screen
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton(
              onPressed: () async {
                await Providers.fbAuthObj.signOut();
                await GoogleSignIn().signOut();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),

          //  getting the list of user form the data base
          body: StreamBuilder(
              stream: Providers.getAllUser(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];
                }
                if (_list.isNotEmpty) {
                  return ListView.builder(
                    padding: EdgeInsets.only(top: mq.height * .01),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _isSearching ? _searchList.length : _list.length,
                    itemBuilder: (context, index) {
                      return ChatUserCard(
                        user: _isSearching ? _searchList[index] : _list[index],
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
        ),
      ),
    );
  }
}
