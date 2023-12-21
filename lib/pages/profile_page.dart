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
  // every form needs a key to validate and the form state give functionalities to save and validate form
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
          body: Form(
            key: _formKey,
            child: Padding(
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
                    onSaved: (newValue) =>
                        Providers.currentUser.name = newValue ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Invalid username',
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
                    onSaved: (newValue) =>
                        Providers.currentUser.about = newValue ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Invalid-About',
                    decoration: const InputDecoration(
                      label: Text('Hey i am using we chat!'),
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
                      onPressed: () {
                        // this calls all the validate function of the text feilds if null returned
                        // good to go or else specified string is thrown as error
                        if (_formKey.currentState!.validate()) {
                          // if the validation is sucessfully done the save the updated data
                          _formKey.currentState!.save();
                          Providers.updateCurrentUserInfo().then((value) {
                            Dialogs.showSnackbar(context, 'Updated!');
                          });
                        }
                      },
                      icon: const Icon(Icons.update),
                      label: const Text(
                        'Update',
                        style: TextStyle(fontSize: 20),
                      ))
                ],
              ),
            ),
          )),
    );
  }
}
