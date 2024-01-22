import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mymessages/models/chat_user.dart';
import 'package:mymessages/models/message.dart';
import 'package:http/http.dart' as http;

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
  static late ChatUser ownChatUser;

  //  this object is used for the message notification in the app
  static FirebaseMessaging fbMessagingObj = FirebaseMessaging.instance;

  //  this function is used for get the user permission for the notification messages
  static Future<void> getFirebaseMessagingToken() async {
    // for requesting the permission from the user
    await fbMessagingObj.requestPermission();

    await fbMessagingObj.getToken().then((token) {
      if (token != null) {
        ownChatUser.pushToken = token;
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  //  this function below is used to add a chatuser as a friend
  static Future<bool> addFriend(String email) async {
    // get the document
    final data = await fbFirestoreObj
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    log('$data');

    //  put it in the following reference
    if (data.docs.isNotEmpty && data.docs.first.id != googleAuthUser.uid) {
      fbFirestoreObj
          .collection('users')
          .doc(googleAuthUser.uid)
          .collection('my_friends')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  // this below function is used for the push notification
  static Future<void> sendPushNotification(
      ChatUser chatUserOpp, String msg) async {
    try {
      // think it of as the body of the letter
      final body = {
        //  address of the opp user
        "to": chatUserOpp.pushToken,
        //  content of the notification
        "notification": {
          "title": ownChatUser.name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "user_data": "User ID : ${ownChatUser.id}",
        },
      };

      var response =
          //  sending the request to the server
          await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
              //  think it as the details on the letter card
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                //  think this as the post office address
                HttpHeaders.authorizationHeader:
                    'key = AAAAV6GHZmo:APA91bFEAvBO1Ha0_X2GmURxXUy3KTcp2fcPUOLJ3zia-IDjEfeJaMbU4mAen-fRZ0NDimLJbq1lPiW5vhkYiR85nPXaextFFUi8rMEhQ92dzbf2jJhgx5ZGqywPUWR2dQxp6V-xcDg9'
              },
              body: jsonEncode(body));

      log('${response.statusCode}');
    } catch (e) {
      log('error : $e');
    }
  }

  // this function is used for updating the message
  static Future<void> updateMessage(Message message, String updateMsg) async {
    await fbFirestoreObj
        .collection('chats/${getUniqueConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updateMsg});
  }

  //  this function is used for deleting the doc from the firestore
  static Future<void> deleteMessage(Message message) async {
    await fbFirestoreObj
        .collection('chats/${getUniqueConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    // if the message is of type image then it shpuld be deleted from the google storage database
    if (message.type == Type.image) {
      fbStorageObj.refFromURL(message.msg);
    }
  }

  // function for checking if the user exist or not in db
  static Future<bool> userExists() async {
    return (await fbFirestoreObj
            .collection('users')
            .doc(googleAuthUser.uid)
            .get())
        .exists;
  }

  // this function is used for create user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

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

  // this functions is used to get the users who are in our own friends collections
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyFriendsUserId() {
    return fbFirestoreObj
        .collection('users')
        .doc(googleAuthUser.uid)
        .collection('my_friends')
        .snapshots();
  }

  //  this function gets all the document(users) from the collection(table)
  //  excepts the document where the id is user id ( used for the chat screen )
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> friendsUserIds) {
    return fbFirestoreObj
        .collection('users')
        .where('id', whereIn: friendsUserIds.isEmpty ? [''] : friendsUserIds)
        .where('id', isNotEqualTo: googleAuthUser.uid)
        .snapshots();
  }

  //  this function get the user with specified id and store it in a chatuser object ( used for the profile section )
  static Future<void> currentUserExists() async {
    await fbFirestoreObj
        .collection('users')
        .doc(googleAuthUser.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        ownChatUser = ChatUser.fromJson(user.data()!);
        // get the FCM token
        await getFirebaseMessagingToken();
        //  update the last seen and the FCM token in the firbase
        Providers.updateActiveStatus(true);

        log('update user doc : ${user.data()}');
      } else {
        await Providers.createUser().then((user) => currentUserExists());
      }
    });
  }

  // this function is for getting the oppsite user information
  static Stream<QuerySnapshot<Map<String, dynamic>>> getOppUserInfo(
      ChatUser chatUserOpp) {
    return fbFirestoreObj
        .collection('users')
        .where('id', isEqualTo: chatUserOpp.id)
        .snapshots();
  }

  //  this below function is used for updating our online status and last active online
  static Future<void> updateActiveStatus(bool isOnline) async {
    fbFirestoreObj.collection('users').doc(googleAuthUser.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().microsecondsSinceEpoch.toString(),
      'push_token': ownChatUser.pushToken
    });
  }

  //  this function is used for updating the user info ( name , about )
  static Future<void> updateCurrentUserInfo() async {
    await fbFirestoreObj.collection('users').doc(googleAuthUser.uid).update({
      'name': ownChatUser.name,
      'about': ownChatUser.about,
    });
  }

  // this function is used for updating the profile picture
  static Future<void> updateProfilePicture(File file) async {
    // for getting the image file extension
    final ext = file.path.split('.').last;
    log('Extension : $ext');

    //  the below ref contains the address of the firebase storage folder
    final ref = fbStorageObj
        .ref()
        .child('profile_picture / ${googleAuthUser.uid}.$ext');

    // this line of code ios used for uploading the file it line go to the address and put the image there
    //  and set the meta data
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data transfered');
    });

    // this below line of code is used for updating the latest image in the firebase firestore
    ownChatUser.image =
        await ref.getDownloadURL(); // this is for getting the url of the image

    await fbFirestoreObj
        .collection('users')
        .doc(googleAuthUser.uid)
        .update({'image': ownChatUser.image});
  }

  /// the below codes are for the chat messages

  // this below function generaters a unique conversation id for a two user converstation
  static String getUniqueConversationId(String oppUserId) =>
      googleAuthUser.uid.hashCode <= oppUserId.hashCode
          ? '${googleAuthUser.uid}_$oppUserId'
          : '${oppUserId}_${googleAuthUser.uid}';

  //  this function is used for getting all the messages documents of a specific chat (chatUser) .
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      ChatUser chatUserOpp) {
    return fbFirestoreObj
        .collection(
            'chats/${getUniqueConversationId(chatUserOpp.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // this function is used for the sending the first message
  static Future<void> sendFirstMessage(
      ChatUser chatUserOpp, String msg, Type type) async {
    // we need to first set our document in the opp user my friend collection because initially our document does not
    //  present in the opp user my friend collection
    await fbFirestoreObj
        .collection('users')
        .doc(chatUserOpp.id)
        .collection('my_friends')
        .doc(googleAuthUser.uid)
        .set({}).then((value) => sendMessage(chatUserOpp, msg, type));
  }

  //  this below function is used to send the messages (chatUser)
  static Future<void> sendMessage(
      ChatUser chatUserOpp, String msg, Type type) async {
    //  this gives the time when the document ( message) is send and we are going to use the time as document id of the message
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // this is the message that needs to be send
    final Message message = Message(
        toId: chatUserOpp.id,
        msg: msg,
        read: '',
        type: type,
        fromId: googleAuthUser.uid,
        sent: time);

    // this gets the location or the address where the chat document needs to be stored
    final ref = fbFirestoreObj.collection(
        'chats/${getUniqueConversationId(chatUserOpp.id)}/messages/');

    // this is putting the data/ document in the address which ref is pointing
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUserOpp, type == Type.text ? msg : 'image'));
  }

  // this below function is used for setting the blue tick or sets as message has been seen by the oppsite user in the Green messages
  static Future<void> updateMessageReadStatus(
      {required Message message}) async {
    fbFirestoreObj
        .collection(
            'chats/${getUniqueConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // this function below is used to show the last message of the converstation ]
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatUserOpp) {
    return fbFirestoreObj
        .collection(
            'chats/${getUniqueConversationId(chatUserOpp.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //  this function is used for sending the pic as an image
  static Future<void> sendImageAsMessage(
      ChatUser chatUserOpp, File file) async {
    // for getting the image file extension
    final ext = file.path.split('.').last;
    log('Extension : $ext');

    //  the below ref contains the address of the firebase storage folder
    final ref = fbStorageObj.ref().child(
        'images/${getUniqueConversationId(chatUserOpp.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    // this line of code ios used for uploading the file it line go to the address and put the image there
    //  and set the meta data
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data transfered');
    });

// this is for getting the url of the image
    final imageUrl = await ref.getDownloadURL();

// updating the message document with image url to the msg attribute of the messagw document
    await sendMessage(chatUserOpp, imageUrl, Type.image);
  }
}
