// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymessages/authprovider/provider.dart';
import 'package:mymessages/helper/dialog_box.dart';
import 'package:mymessages/models/chat_user.dart';
import 'package:mymessages/pages/auth/login_page.dart';

import '../main.dart';

class ProfilePage extends StatefulWidget {
  final ChatUser chatUser;
  const ProfilePage({super.key, required this.chatUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // every form needs a key to validate and the form state give functionalities to save and validate form
  final _formKey = GlobalKey<FormState>();

  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Profile'),
          ),

          //  button for logout
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              onPressed: () async {
                Dialogs.showProgressBar(context);
                await Providers.fbAuthObj.signOut().then(
                  (value) async {
                    // set the user as offline
                    Providers.updateActiveStatus(false);

                    // log out the user from the app
                    await GoogleSignIn().signOut().then((value) {
                      // pops the progress bar
                      Navigator.of(context).pop();
                      //  pops the home screen
                      Navigator.of(context).pop();

                      Providers.fbAuthObj = FirebaseAuth.instance;
                      // replaces the home screen with the login screen
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ));
                    });
                  },
                );
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
                  // using the stack to place one widget upon another
                  Stack(
                    children: [
                      //  this comes below for the profile pic
                      // if the _image is not null means the image is comming from the device path
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          // if the image is null then the image is coming from the Chat user
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                imageUrl: widget.chatUser.image,
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                      // this widget comes above thisis edit button for profle
                      Positioned(
                        bottom: 0,
                        right: -25,
                        child: MaterialButton(
                          color: Colors.red,
                          shape: const CircleBorder(),
                          onPressed: () {
                            _showBottomSheet();
                          },
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
                    widget.chatUser.email,
                    style: const TextStyle(fontSize: 20, color: Colors.black54),
                  ),

                  // fpr the name text field
                  SizedBox(height: mq.height * .03),

                  TextFormField(
                    initialValue: widget.chatUser.name,
                    onSaved: (newValue) =>
                        Providers.ownChatUser.name = newValue ?? '',
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
                    initialValue: widget.chatUser.about,
                    onSaved: (newValue) =>
                        Providers.ownChatUser.about = newValue ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Invalid-About',
                    decoration: const InputDecoration(
                      label: Text('About'),
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

  // this function is for calling the bottom model
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding:
              EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .03),
          children: [
            const Text(
              'Select Image',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // this button is for selecting the image from thr gallery
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (image != null) {
                        log('image path : ${image.path}  --- meme type : ${image.mimeType}');
                        setState(() {
                          _image = image.path;
                        });

                        // calling the function to update the profile pic
                        Providers.updateProfilePicture(File(_image!));
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/icon/addimage.png')),

                // this button is for camera purpose
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        log('image path : ${image.path}  --- meme type : ${image.mimeType}');
                        setState(() {
                          _image = image.path;
                        });
                        Providers.updateProfilePicture(File(_image!));

                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/icon/camera.png'))
              ],
            )
          ],
        );
      },
    );
  }
}
