// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_app/screens/home/pages/stat_screen.dart';
import 'package:tracker_app/screens/home/pages/welcome.dart';
//import 'package:tracker_app/screens/widgets/widgets_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? imageUrl;
  int _selectedIndex = 0; // to track the selected tab

  List<String> docIDs = [];

  // Dummy method for fetching document IDs
  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              docIDs.add(document.reference.id);
            }));
  }

  @override
  void initState() {
    super.initState();
    getDocId(); // Fetch document IDs on initialization
  }

  // Bottom navigation bar tap handling
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    //String bgImage = 'bgImage.png';
    //String homeScreen = 'homeExpense1.png';

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
                      'Bienvenue, ${user?.displayName ?? 'Utilisateur'}!',
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
          // Logout button
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
                            child: Text(
                              "Non",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.redAccent),
                            ),
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
                          ),
                          TextButton(
                            onPressed: () {
                              // Si l'utilisateur confirme la déconnexion
                              FirebaseAuth.instance
                                  .signOut(); // Action de déconnexion
                              Navigator.of(context).pop(); // Fermer le dialogue
                            },
                            child: Text(
                              "Oui",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.greenAccent),
                            ),
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
      body: SafeArea(
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                WelcomeScreen(),
                // Home Page Content
                // FutureBuilder(
                //   future: getDocId(),
                //   builder: (context, snapshot) {
                //     return ListView.builder(
                //       itemCount: docIDs.length,
                //       itemBuilder: (context, index) {
                //         return Padding(
                //           padding: const EdgeInsets.all(6.0),
                //           child: ListTile(
                //             title: GetUserName(documentId: docIDs[index]),
                //             tileColor: Colors.grey[300],
                //           ),
                //         );
                //       },
                //     );
                //   },
                // ),
                // StatScreen
                StatScreen(),
                // Other pages (placeholders for now)
                Center(child: Text("Transactions Page")),
                Center(child: Text("Categories Page")),
                Center(child: Text("settings Page")),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Graphiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Catégories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
