// ignore_for_file: prefer_const_constructors

import 'package:budget_app/screens/auth/login.dart';
import 'package:budget_app/screens/auth/register_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  //initiallement montre le login page
  bool showLoginPage = true;

  @override
  Widget build(BuildContext context) {
    void toggleScreen() {
      setState(() {
        showLoginPage = !showLoginPage;
      });
    }

    if (showLoginPage) {
      return LoginPage(showRegisterPage: toggleScreen);

    }else{
      return RegisterPage(showLoginPage: toggleScreen);
    }
  }
}