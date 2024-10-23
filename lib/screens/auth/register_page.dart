// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:budget_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  String? imageUrl; // URL de l'image après téléchargement
  bool isLoading = false;

// Clé de formulaire
  final _formKey = GlobalKey<FormState>();

// Contrôleurs de texte
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Échec lors du chargement de l\'image: $e'),
        ),
      );
    }
  }

// Fonction pour uploader l'image sur Firebase Storage
  Future<void> uploadImageToFirebase(File image) async {
    setState(() {
      isLoading = true;
    });
    try {
      // Référence à l'emplacement où l'image sera stockée
      Reference reference = FirebaseStorage.instance
          .ref()
          .child("image/${DateTime.now().microsecondsSinceEpoch}.png");

      // Téléchargement du fichier dans Firebase Storage
      await reference.putFile(image).whenComplete(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            content: Text('Image chargée avec succès'),
          ),
        );
      });

      // Récupération de l'URL de l'image
      imageUrl = await reference.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Échec lors du chargement de l\'image: $e'),
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getUserProfileImage() async {
    // Get the current user's UID
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Fetch the user's document from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Retrieve the profile image URL from the document
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? userProfileImageUrl = userData['profile'];

        // Update the state to display the image
        setState(() {
          imageUrl = userProfileImageUrl;
        });
      }
    } catch (e) {
      print('Error fetching user profile image: $e');
    }
  }

// Fonction pour inscrire l'utilisateur
  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (passwordConfirmed()) {
          // Show loading indicator
          showDialog(
            context: context,
            builder: (context) {
              return Center(child: CircularProgressIndicator());
            },
          );

          // Create a new Firebase user and get the user credentials
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          // Get the UID of the newly created user
          String uid = userCredential.user!.uid;
          print('Utilisateur créé avec succès. UID: $uid');

          // Close the loading indicator
          Navigator.of(context).pop();

          // Add user details in Firestore
          await addUserDetails(
            uid, // Pass the UID here
            _firstName.text.trim(),
            _lastName.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
            imageUrl, // Utilisez imageUrl qui a déjà été assigné
          );

          // Fetch and display the user's profile image
          await getUserProfileImage();

          // Navigate to login page
          widget.showLoginPage();
        } else {
          print('Les mots de passe ne correspondent pas.');
        }
      } catch (e) {
        print('Erreur lors de l\'inscription: $e');
      }
    } else {
      print('Le formulaire n\'est pas valide.');
    }
  }

  // Fonction d'ajout d'utilisateur avec UID dans Firestore
  Future<void> addUserDetails(
    String uid, // UID de l'utilisateur
    String firstName,
    String lastName,
    String email,
    String password,
    String? imageUrl,
  ) async {
    try {
      // Log pour vérifier les données avant l'ajout
      print('Données utilisateur à ajouter:');
      print('UID: $uid');
      print('First Name: $firstName');
      print('Last Name: $lastName');
      print('Email: $email');
      print('Profile URL: ${imageUrl ?? 'Aucune image'}');

      // Vérifier si uid est valide
      if (uid.isEmpty) {
        print('UID est vide. Impossible d\'ajouter l\'utilisateur.');
        return; // Sortir si le UID est vide
      }

      // Tenter d'ajouter les détails de l'utilisateur à Firestore
      final user = UserModel.avecParametre(
          id: uid,
          email: email,
          password: password,
          profile: imageUrl ?? '',
          fName: firstName,
          lName: lastName,
          createAt: DateTime.now());
      await user.add();
      // await FirebaseFirestore.instance.collection('users').doc(uid).set({
      //   'userId': uid,
      //   'first name': firstName,
      //   'last name': lastName,
      //   'email': email,
      //   'password': password,
      //   'profile': imageUrl ?? '',
      //   'createdAt': FieldValue.serverTimestamp().,
      // });

      print('Utilisateur ajouté avec succès avec UID.');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'utilisateur dans Firestore: $e');
    }
  }

// Fonction pour vérifier si les mots de passe correspondent
  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
  }

// Libérer les ressources des contrôleurs de texte
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
                    'Bienvenue sur Budget_app',
                    style: GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.w400, fontSize: 35),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Créer votre compte sur Budget_app',
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
                            backgroundColor: Colors
                                .grey[200], // You can add a background color
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl!)
                                : null, // Display image if URL exists
                            child: imageUrl == null
                                ? Icon(Icons.person,
                                    size: 120, color: Colors.grey)
                                : null, // Display icon if no image
                          ),
                        ),
                        if (isLoading)
                          Positioned(
                            top: 70,
                            right: 190,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Positioned(
                          right: 110,
                          top: 9,
                          child: GestureDetector(
                            onTap: pickImage, // Function to pick the image
                            child: Icon(Icons.camera_alt,
                                color: Colors.grey[500], size: 30),
                          ),
                        ),
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
