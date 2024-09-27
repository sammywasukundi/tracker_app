// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/screens/home/pages/forms/budget.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? imageUrl;
  User? user = FirebaseAuth.instance.currentUser;



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
                        color: const Color.fromARGB(255, 162, 161, 158),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ClipOval(
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.person,
                                size: 40,
                              ), // Affiche l'icône par défaut si aucune image n'est trouvée
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
                      //'Bienvenue, $firstName!',
                      'Bienvenue sur Tracker_app',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white60),
                    ),
                    Text(
                      user?.email ?? 'example@example.com',
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
                              side: BorderSide(
                                // Ajout d'une bordure
                                color: Colors
                                    .redAccent, // Couleur de la bordure (verte)
                                width: 0.5, // Épaisseur de la bordure
                              ),
                            ),
                            child: Text(
                              "Non",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.redAccent),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Si l'utilisateur confirme la déconnexion
                              FirebaseAuth.instance
                                  .signOut(); // Action de déconnexion
                              Navigator.of(context).pop(); // Fermer le dialogue
                            },
                            style: TextButton.styleFrom(
                              shape:
                                  const StadiumBorder(), // Forme de bouton en stade
                              side: BorderSide(
                                // Ajout d'une bordure
                                color: Colors
                                    .green, // Couleur de la bordure (verte)
                                width: 0.5, // Épaisseur de la bordure
                              ),
                            ),
                            child: Text(
                              "Oui",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.greenAccent),
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
                'Avec Tracker_app',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
