import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mymessages/models/chat_user.dart';

class Providers {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for the cloud fire base
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for getting the current user
  static User get user => auth.currentUser!;

  // function for checking if the user exist or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // this function is used to create a new document of type user in the collection
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      image: user.photoURL.toString(),
      about: 'Hey! i am using We chat',
      name: user.displayName.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      id: user.uid,
      email: user.email.toString(),
      pushToken: '',
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }
}
