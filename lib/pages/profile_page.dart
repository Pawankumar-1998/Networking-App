import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mymessages/authprovider/provider.dart';
import 'package:mymessages/helper/dialog_box.dart';
import 'package:mymessages/models/chat_user.dart';
import 'package:mymessages/pages/auth/login_page.dart';

import '../main.dart';

class ProfilePage extends StatefulWidget {
  final ChatUser user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Profile'),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await Providers.auth.signOut().then(
                (value) async {
                  await GoogleSignIn().signOut().then((value) {
                    // pops the progress bar
                    Navigator.of(context).pop();
                    //  pops the home screen
                    Navigator.of(context).pop();
                    // replaces the home screen with the login screen
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ));
                  });
                },
              );
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            label: const Text('Logout'),
            icon: const Icon(Icons.logout_outlined),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: Column(
            children: [
              SizedBox(height: mq.height * .03),
              // for the user profile
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      // color: Colors.amber,
                      width: 100,
                      height: 100,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: -25,
                    child: MaterialButton(
                      color: Colors.red,
                      shape: const CircleBorder(),
                      onPressed: () {},
                      child: Icon(
                        Icons.edit,
                        color: Colors.amber.shade500,
                      ),
                    ),
                  )
                ],
              ),

              // for the email
              SizedBox(height: mq.height * .03),
              Text(
                widget.user.email,
                style: const TextStyle(fontSize: 20, color: Colors.black54),
              ),

              // fpr the name text field
              SizedBox(height: mq.height * .03),

              TextFormField(
                initialValue: widget.user.name,
                decoration: const InputDecoration(
                    label: Text('Name'),
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    hintText: 'eg : Pawan Kumar'),
              ),

              // fpr the about text field
              SizedBox(height: mq.height * .02),

              TextFormField(
                initialValue: widget.user.about,
                decoration: const InputDecoration(
                  label: Text('Name'),
                  prefixIcon: Icon(Icons.info),
                  border: OutlineInputBorder(),
                ),
              ),

              // this is for the elevated button
              SizedBox(height: mq.height * .02),

              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * .4, mq.height * .055)),
                  onPressed: () {},
                  icon: const Icon(Icons.update),
                  label: const Text(
                    'Update',
                    style: TextStyle(fontSize: 20),
                  ))
            ],
          ),
        ));
  }
}
