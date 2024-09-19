// ignore_for_file: prefer_const_constructors

//import 'dart:io';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //profil controller

  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;
  bool isLoading = false;

  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();

  // Fonction pour choisir une image depuis la galerie
  Future<void> pickImage() async {
    try {
      XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery); 

      if(res != null) {
        await uploadImageToFirebase(File(res.path));
      }  
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Echec lors du chargement de l\'image: $e'),
        )
      );
    }
  }

  Future<void> uploadImageToFirebase(File image) async {
    setState(() {
      isLoading = true;
    });
    try {
      Reference reference = FirebaseStorage.instance.ref().child("image/${DateTime.now().microsecondsSinceEpoch}.png");
      await reference.putFile(image).whenComplete(() {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text('Chargement de l\'image avec succès'),
        )
      );
      },);
      imageUrl = await reference.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Echec lors du chargement de l\'image: $e'),
        )
      );
    }
    setState(() {
      isLoading = false;
    });
  }


  Future signUp() async {
  //authentication
  try {
    if (passwordConfirmed()) {
      // Créer un nouvel utilisateur avec Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Ajouter les détails de l'utilisateur dans Firestore
      await addUserDetails(
        _firstName.text.trim(),
        _lastName.text.trim(),
        _emailController.text.trim(),
      );

      // Rediriger vers la page de connexion
      widget.showLoginPage();
      
    } else {
      // Gérer le cas où les mots de passe ne correspondent pas
      print('Les mots de passe ne correspondent pas');
    }
  } catch (e) {
    // Gérer les erreurs comme les emails déjà utilisés, etc.
    print('Erreur lors de l\'inscription: $e');
  }
}


  Future addUserDetails(String firstName,String lastName,String email) async {
    await FirebaseFirestore.instance.collection('users').add({
     'first name':firstName,
      'last name':lastName,
      'email':email, 
    }
    );
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                Text(
                  'Bienvenue sur Tracker_app',
                  style: GoogleFonts.bebasNeue(
                      fontWeight: FontWeight.w400, fontSize: 35),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Créer votre compte sur Tracker_app',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                //profil user
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Stack(
                        children: [
                          Center(
                            //let's display the image 
                            child: CircleAvatar(
                              radius: 65,
                              child: imageUrl == null
                                ? Icon(
                                  Icons.person,
                                  size: 120,
                                  color: Colors.grey,
                                ): SizedBox(
                                  height: 220,
                                  child: ClipOval(
                                    child: Image.network(
                                      width: double.infinity,
                                      imageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                            ),
                          ),
                          // let's display the progressbar
                          if(isLoading) 
                            Positioned(
                              top: 70,
                              right: 190,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            ), 
                          Positioned(
                            right: 110,
                            top: 9,
                            child: GestureDetector(
                              onTap: () {
                                pickImage();
                              },
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[500],
                                size: 30,
                              ),
                            )
                          )
                        ],
                      )
                    ],
                  ),
                ),
                //firstName
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
                        controller: _firstName,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nom',
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                //lastName
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
                        controller: _lastName,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Postnom',
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
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
                            border: InputBorder.none,
                            hintText: 'Adresse email',
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
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
                            border: InputBorder.none,
                            hintText: 'Mot de passe',
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                //confirm_pwd
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
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Confirmer le mot de passe',
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300)),
                      ),
                    ),
                  ),
                ),
                //insription
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () => signUp(),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent[400],
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: Text(
                          'S\'inscrire',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                //inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Je suis déjà membre ?'),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        ' Connectez-vous',
                        style: TextStyle(
                            color: Colors.blueAccent[400],
                            fontWeight: FontWeight.w400),
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
