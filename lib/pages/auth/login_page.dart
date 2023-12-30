import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mymessages/authprovider/provider.dart';
import 'package:mymessages/helper/dialog_box.dart';
import 'package:mymessages/main.dart';
import 'package:mymessages/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAnimated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          isAnimated = true;
        });
      },
    );
  }

  _handelGoogleSignIn() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.of(context).pop();
      if (user != null) {
        if (await (Providers.userExists())) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomePage()));
        } else {
          await Providers.createUser().then((value) {
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomePage()));
          });
        }
      }
    });
  }

  // function for google login
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('www.google.com');
      // Initiates the Google Sign-In process, prompting the user to select their Google account.
      // Returns a GoogleSignInAccount object representing the signed-in Google account. This object may be null if the user cancels the sign-in process.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      ///Retrieves the authentication details (tokens) associated with the signed-in Google account.
      /// Returns a GoogleSignInAuthentication object containing an access token (accessToken) and an ID token (idToken).
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Providers.fbAuthObj.signInWithCredential(credential);
    } catch (e) {
      // ignore: use_build_context_synchronously
      Dialogs.showSnackbar(context, 'Please chek your internet connection');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Welcome to We Chat'),
      ),
      body: Stack(
        children: [
          // in the stack this is the first positioned element this stays below
          AnimatedPositioned(
            top: mq.height * .15,
            right: isAnimated ? mq.width * .25 : mq.width * -5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('assets/icon/chat.png'),
          ),
          // in the stack this is the second positioned element
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[300],
                  shape: const StadiumBorder()),
              onPressed: () {
                _handelGoogleSignIn();
              },
              icon: Image.asset(
                'assets/icon/google.png',
                height: mq.height * .05,
              ),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 19),
                  children: [
                    TextSpan(
                      text: ' Signin with ',
                    ),
                    TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.w500))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
