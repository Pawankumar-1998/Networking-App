import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mymessages/models/chat_user.dart';

class Providers {
  // this is a authentication object used to authenticate the user
  static FirebaseAuth fbAuthObj = FirebaseAuth.instance;

  // this is a firestore object used to read and write into database
  static FirebaseFirestore fbFirestoreObj = FirebaseFirestore.instance;

  //  creating the object for the using the firebase storage to store image and files
  static FirebaseStorage fbStorageObj = FirebaseStorage.instance;

  // for getting the current user in the firebase auth instance this is the google user
  static User get googleAuthUser => fbAuthObj.currentUser!;

  // this is used to store the current user
  static late ChatUser currentChatUser;

  // function for checking if the user exist or not
  static Future<bool> userExists() async {
    return (await fbFirestoreObj.collection('users').doc(googleAuthUser.uid).get())
        .exists;
  }

  // this function is used for create user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    //  here the chatUser get it properties from the google user
    final chatUser = ChatUser(
      image: googleAuthUser.photoURL.toString(),
      about: 'Hey! i am using We chat',
      name: googleAuthUser.displayName.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      id: googleAuthUser.uid,
      email: googleAuthUser.email.toString(),
      pushToken: '',
    );

    //  the below line of code send the user detail to the firestore user collection
    return await fbFirestoreObj
        .collection('users')
        .doc(googleAuthUser.uid)
        .set(chatUser.toJson());
  }

  //  this function gets all the document(users) from the collection(table)
  //  excepts the document where the id is user id ( used for the chat screen )
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return fbFirestoreObj
        .collection('users')
        .where('id', isNotEqualTo: googleAuthUser.uid)
        .snapshots();
  }

  //  this function get the user with specified id and store it in a chatuser object ( used for the profile section )
  static Future<void> currentUserInfo() async {
    await fbFirestoreObj
        .collection('users')
        .doc(googleAuthUser.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        currentChatUser = ChatUser.fromJson(user.data()!);
      } else {
        await Providers.createUser().then((user) => currentUserInfo());
      }
    });
  }

  //  this function is used for updating the user info
  static Future<void> updateCurrentUserInfo() async {
    await fbFirestoreObj.collection('users').doc(googleAuthUser.uid).update({
      'name': currentChatUser.name,
      'about': currentChatUser.about,
    });
  }

  // this function is used for updating the profile picture
  static Future<void> updateProfilePicture(File file) async {
    // for getting the image file extension
    final ext = file.path.split('.').last;
    log('Extension : $ext');

      //  the below ref contains the address of the firebase storage folder 
    final ref =
        fbStorageObj.ref().child('profile_picture / ${googleAuthUser.uid}.$ext');

    // this line of code ios used for uploading the file it line go to the address and put the image there 
    //  and set the meta data 
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data transfered');
    });

    // this below line of code is used for updating the latest image in the firebase firestore
    currentChatUser.image =
        await ref.getDownloadURL(); // this is for getting the url of the image

    await fbFirestoreObj
        .collection('users')
        .doc(googleAuthUser.uid)
        .update({'image': currentChatUser.image});
  }
}
