// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tracker_app/screens/auth/forgot_pwd_page.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;

  // Constructeur corrigé
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

  // text controllers 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Méthode de validation des champs
  bool _validateFields() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Afficher un message d'erreur ou un dialog si un champ est vide
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Veuillez remplir tous les champs.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return false;
    }
    return true;
  }

  Future signIn() async {
    // Valider les champs avant de tenter de se connecter
    if (!_validateFields()) return;

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: SpinKitWave(
          color: Colors.blueAccent[100],
          size: 35,
        ));
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.of(context).pop(); // Fermer le dialog de chargement
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // Fermer le dialog de chargement

      // Afficher un message d'erreur si la connexion échoue
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erreur de connexion'),
            content: Text(e.message ?? 'Échec de la connexion. Veuillez réessayer.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String app = 'app.png';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Bienvenue
                Image.asset(
                  'assets/auth/$app',
                  height: 160,
                  width: 160,
                ),
                SizedBox(height: 35,),
                Text(
                  'Connectez-vous sur Tracker_app',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                // email
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
                // pwd
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
                // forgot pwd
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
                // connexion
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
                // inscription
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
