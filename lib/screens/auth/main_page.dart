import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/screens/auth/auth_page.dart';
//import 'package:tracker_app/screens/home/home_page.dart';
import 'package:tracker_app/screens/home/pages/welcome.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const WelcomeScreen();
          }else{
            return const AuthPage();
          }
        }
      ),
    );
  }
}
