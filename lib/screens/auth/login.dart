// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/screens/auth/forgot_pwd_page.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage}) ;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // text controllers 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {

    showDialog(
      context: context,
      builder: (context) {
        return Center(child: SpinKitWave(
          color: Colors.blueAccent[100],
          size: 35,
        ));
      },
    );

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim()
    );

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //Bienvenue
                Image.asset(
                  'assets/auth/login1.png',
                  height: 135,
                  width: 135,
                ),
                SizedBox(height: 10,),
                Text(
                  'Bonjour encore',
                  style: GoogleFonts.bebasNeue(fontWeight: FontWeight.w400, fontSize: 35),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Connectez-vous sur Tracker_app',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 30,
                ),
                //email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Adresse email', hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                //pwd
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Mot de passe', hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300)),
                      ),
                    ),
                  ),
                ),
                //forgot pwd
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ForgotPassword();
                              }
                            )
                          );
                        },
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: Colors.blueAccent[400],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //connexion
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () => signIn(),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent[400],
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Center(
                        child: Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 15
                        ),
                      ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25,),
                //inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Pas membre ?'),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: Text(
                        '  Inscrivez-vous',
                          style: TextStyle(
                            color: Colors.blueAccent[400],
                            fontWeight: FontWeight.w400
                          ),
                      ),
                    ),
                  ],
                )
              ],  
            ),
          ),
        ),
      ),
    );
  }
}