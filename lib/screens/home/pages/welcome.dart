// ignore_for_file: prefer_const_constructors

import 'package:budget_app/screens/home/pages/forms/budget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? imageUrl;
  User? user = FirebaseAuth.instance.currentUser;

  bool _isLoading = false;

  Map<String, dynamic>? userDetails; // Détails utilisateur

  Future<void> fetchUserDetails() async {
    // Récupère les détails utilisateur depuis Firestore
    final details = await fetchCurrentUserDetails();
    // Met à jour l'état avec les données utilisateur
    setState(() {
      userDetails = details;
    });
  }

  Future<Map<String, dynamic>?> fetchCurrentUserDetails() async {
    try {
      // Vérifier si l'utilisateur est connecté
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('Aucun utilisateur connecté.');
        return null;
      }

      // Récupérer l'UID de l'utilisateur connecté
      String uid = currentUser.uid;

      // Chercher dans Firestore l'utilisateur avec cet UID
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        print('Aucun utilisateur trouvé pour cet UID: $uid.');
        return null;
      }

      // Récupérer les détails de l'utilisateur
      Map<String, dynamic> userData = {
        'firstName': userDoc['first name'],
        'lastName': userDoc['last name'],
        'email': userDoc['email'],
        'profile': userDoc['profile'],
        'createdAt': userDoc['createdAt'] != null
            ? userDoc['createdAt'].toDate().toString()
            : 'N/A',
      };

      return userData;
    } catch (e) {
      print('Erreur lors de la récupération des détails utilisateur: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Colors.blueAccent,
          elevation: 4.0,
          title: Padding(
            padding: const EdgeInsets.only(top: 14.0),
            child: Row(
              children: [
                // Profile Picture (CircleAvatar)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(
                            255, 162, 161, 158), // Couleur de fond par défaut
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ClipOval(
                        child: (userDetails != null &&
                                userDetails!['profile'] != null &&
                                userDetails!['profile'] != '')
                            ? Image.network(
                                userDetails![
                                    'profile'], // Vérification si 'profile' n'est pas null
                                width: 60, // Largeur du cercle
                                height: 60, // Hauteur du cercle
                                fit: BoxFit
                                    .cover, // Ajuste l'image pour remplir le cercle
                              )
                            : Icon(
                                Icons.account_circle,
                                size: 60, // Taille de l'icône par défaut
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    width: 12), // Spacing between profile picture and title
                // User title (name or email)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue sur Budget_app',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white60),
                    ),
                    Text(
                      userDetails != null
                          ? '${userDetails!['firstName']} ${userDetails!['lastName']}'
                          : 'Chargement...', // Affiche le nom de l'utilisateur ou un texte par défaut
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          //Logout button
          actions: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () {
                  // Appel de showDialog pour confirmation de déconnexion
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        //title: Center(child: Text("Déconnexion")),
                        content: Text(
                          "Voulez-vous vous déconnecter ?",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Si l'utilisateur annule
                              Navigator.of(context).pop(); // Fermer le dialogue
                            },
                            style: TextButton.styleFrom(
                              shape:
                                  const StadiumBorder(), // Forme de bouton en stade
                            ),
                            child: Text(
                              "Annuler",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true; // Début du chargement
                              });

                              try {
                                // Action de déconnexion
                                await FirebaseAuth.instance.signOut();

                                // Fermer le dialogue après la déconnexion
                                Navigator.of(context).pop();
                              } catch (e) {
                                // Gérer l'erreur si besoin
                                print('Erreur lors de la déconnexion: $e');
                              } finally {
                                setState(() {
                                  _isLoading = false; // Fin du chargement
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              shape: const StadiumBorder(),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blueAccent),
                                  )
                                : Text(
                                    "Se déconnecter",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Image.asset(
                  'assets/auth/homeScreen.png',
                  height: 330,
                  width: double.infinity,
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Text(
                'Avec Budget_app',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 35,
              ),
              Text(
                'Suivez vos revenus, enregistrez vos dépenses,\nconsultez des graphes visuels de vos habitudes \nde dépense et prenez le contrôle de votre argent',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FormBudget()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Commençons !',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
