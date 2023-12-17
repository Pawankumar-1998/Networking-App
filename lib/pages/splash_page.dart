import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mymessages/pages/auth/login_page.dart';
import 'package:mymessages/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 1500),
      () {
        if (FirebaseAuth.instance.currentUser != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomePage(),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
              ));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   title: const Text('Welcome to We Chat'),
      // ),
      body: Stack(
        children: [
          // in the stack this is the first positioned element
          Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset('assets/icon/chat.png'),
          ),
          // in the stack this is the second positioned element
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Text(
              'Made with  💜  in india ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
                wordSpacing: 3,
              ),
            ),
          )
        ],
      ),
    );
  }
}
