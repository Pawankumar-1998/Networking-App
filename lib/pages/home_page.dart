import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mymessages/authprovider/provider.dart';
import 'package:mymessages/helper/dialog_box.dart';
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

    Providers
        .currentUserExists(); // this fetches the user document in firebase or creates the user document  if does not exits
    //  as the home screen gets loaded set the current users active status to loaded

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (Providers.fbAuthObj.currentUser != null) {
        //  resume condition gets true when the app comes back in use
        if (message.toString().contains('resume')) {
          Providers.updateActiveStatus(true);
        }
        //  pause condition gets true when the app goes to the background and no use currently
        if (message.toString().contains('pause')) {
          Providers.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
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
                          ProfilePage(chatUser: Providers.ownChatUser),
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
                addEmailDialog();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),

          //  getting the list of user form the data base
          body: StreamBuilder(
            //  gets the users list from the my friends collection
            stream: Providers.getMyFriendsUserId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                // if the data is under fetching
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                // if the data is fetched
                case ConnectionState.active:
                case ConnectionState.done:
                  log('first function ${snapshot.hasData}');
                  log('first function ${snapshot.data?.docs.length}');
                  return StreamBuilder(
                    stream: Providers.getAllUser(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        case ConnectionState.active:
                        case ConnectionState.done:
                          log('second one ${snapshot.hasData}');

                          final data = snapshot.data?.docs;
                          log('second one ${data?.length}');
                          _list = data
                                  ?.map((singleDocument) =>
                                      ChatUser.fromJson(singleDocument.data()))
                                  .toList() ??
                              [];
                      }
                      log('list length ${_list.length}');
                      if (_list.isNotEmpty) {
                        return ListView.builder(
                          padding: EdgeInsets.only(top: mq.height * .01),
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              _isSearching ? _searchList.length : _list.length,
                          itemBuilder: (context, index) {
                            return ChatUserCard(
                              chatUserOpp: _isSearching
                                  ? _searchList[index]
                                  : _list[index],
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
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  //  this function is used to show a dialog for adding email
  void addEmailDialog() {
    String email = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 10),
        title: const Row(
          children: [
            // for email icon
            Icon(
              Icons.person,
              color: Colors.blue,
              size: 28,
            ),
            Text('   Add Email')
          ],
        ),
        // box for entering the email
        content: TextFormField(
          maxLines: null,
          initialValue: email,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email, color: Colors.blue),
              hintText: 'Email address',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
          onChanged: (value) => email = value,
        ),
        actions: [
          //  add button
          MaterialButton(
            onPressed: () async {
              if (email.isNotEmpty) {
                await Providers.addFriend(email).then((value) {
                  if (!value) {
                    Dialogs.showSnackbar(context, 'No such user exists !');
                  }
                });
              }
              // remove the alert dialog
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Add',
                style: TextStyle(color: Colors.blue, fontSize: 18)),
          ),
          // cancel button
          MaterialButton(
            onPressed: () {
              // remove the alert dialog
              Navigator.pop(context);
            },
            child: const Text('Cancel',
                style: TextStyle(color: Colors.blue, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
