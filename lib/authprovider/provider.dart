import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mymessages/models/chat_user.dart';

class Providers {
  // this is a authentication object used to authenticate the user  
  static FirebaseAuth auth = FirebaseAuth.instance;

  // this is a firestore object used to read and write into database 
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // for getting the current user in the firebase auth instance
  static User get user => auth.currentUser!;

  // this is used to store the current user
  static late ChatUser currentUser;


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

  //  this function gets all the document(users) from the collection(table)
  //  excepts the document where the id is user id
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //  this function get the user with specified id and store it in a chatuser object
  static Future<void> currentUserInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        currentUser = ChatUser.fromJson(user.data()!);
      } else {
        await Providers.createUser().then((user) => currentUserInfo());
      }
    });
  }

  //  this function is used for updating the user info
  static Future<void> updateCurrentUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': currentUser.name,
      'about': currentUser.about,
    });
  }
}
