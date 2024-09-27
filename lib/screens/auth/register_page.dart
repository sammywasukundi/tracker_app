// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  // Form key
  final _formKey = GlobalKey<FormState>();

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
      if (res != null) {
        await uploadImageToFirebase(File(res.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Echec lors du chargement de l\'image: $e'),
      ));
    }
  }

  Future<void> uploadImageToFirebase(File image) async {
    setState(() {
      isLoading = true;
    });
    try {
      Reference reference = FirebaseStorage.instance
          .ref()
          .child("image/${DateTime.now().microsecondsSinceEpoch}.png");
      await reference.putFile(image).whenComplete(
        () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            content: Text('Chargement de l\'image avec succès'),
          ));
        },
      );
      imageUrl = await reference.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Echec lors du chargement de l\'image: $e'),
      ));
    }
    setState(() {
      isLoading = false;
    });
  }

  Future signUp() async {
    // Valider les champs
    if (_formKey.currentState!.validate()) {
      try {
        if (passwordConfirmed()) {
          showDialog(
            context: context,
            builder: (context) {
              return Center(
                  child: SpinKitWave(
                color: Colors.blueAccent[100],
                size: 35,
              ));
            },
          );

          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          Navigator.of(context).pop();
          await addUserDetails(
            _firstName.text.trim(),
            _lastName.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
          widget.showLoginPage();
        } else {
          print('Les mots de passe ne correspondent pas');
        }
      } catch (e) {
        print('Erreur lors de l\'inscription: $e');
      }
    }
  }

  Future addUserDetails(
      String firstName, String lastName, String email, String password) async {
    await FirebaseFirestore.instance.collection('users').add({
      'first name': firstName,
      'last name': lastName,
      'email': email,
      'password': password,
      'createdAt': FieldValue.serverTimestamp(), // Timestamp du serveur
    });
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
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
            child: Form(
              key: _formKey, // Lien au GlobalKey
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                  // Profil utilisateur
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Center(
                          child: CircleAvatar(
                              radius: 65,
                              child: imageUrl == null
                                  ? Icon(Icons.person,
                                      size: 120, color: Colors.grey)
                                  : SizedBox(
                                      height: 220,
                                      child: ClipOval(
                                        child: Image.network(
                                          width: double.infinity,
                                          imageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )),
                        ),
                        if (isLoading)
                          Positioned(
                              top: 70,
                              right: 190,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )),
                        Positioned(
                            right: 110,
                            top: 9,
                            child: GestureDetector(
                              onTap: pickImage,
                              child: Icon(Icons.camera_alt,
                                  color: Colors.grey[500], size: 30),
                            ))
                      ],
                    ),
                  ),
                  // Prénom
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _firstName,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Nom',
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300)),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Nom requis' : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Postnom
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _lastName,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Postnom',
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300)),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Postnom requis'
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Email
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Adresse email',
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300)),
                          validator: (val) => val == null || !val.contains('@')
                              ? 'Email invalide'
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Mot de passe
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Mot de passe',
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300)),
                          validator: (val) => val == null || val.length < 6
                              ? 'Mot de passe trop court'
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Confirmation mot de passe
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Confirmer le mot de passe',
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300)),
                          validator: (val) =>
                              val == null || val != _passwordController.text
                                  ? 'Les mots de passe ne correspondent pas'
                                  : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Inscription
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
                  SizedBox(height: 25),
                  // Lien vers la connexion
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
