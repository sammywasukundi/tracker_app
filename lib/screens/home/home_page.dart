// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_app/screens/home/pages/forms/expense.dart';
import 'package:tracker_app/screens/home/pages/graphs/graph.dart';
import 'package:tracker_app/screens/home/pages/settings.dart';
//import 'package:tracker_app/screens/home/pages/welcome.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.budgetId});
  final String budgetId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching =
      false; // Variable pour afficher ou non la barre de recherche
  TextEditingController _searchController = TextEditingController();

  String? imageUrl;
  int _selectedIndex = 0; // to track the selected tab
  String? firstName;

  void _getUserProfileImage() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Construis le chemin de l'image (supposons que l'image est nommée par l'userId)
        String imagePath = 'image/${user.uid}.png';

        // Récupérer la référence à l'image dans Firebase Storage
        Reference ref = FirebaseStorage.instance.ref().child(imagePath);

        // Obtenir l'URL de téléchargement
        String downloadUrl = await ref.getDownloadURL();

        setState(() {
          imageUrl = downloadUrl; // Stocker l'URL pour l'afficher
        });
      } catch (e) {
        print('Erreur lors de la récupération de l\'URL de l\'image : $e');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToExpenseScreen() {
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddExpense(),
        ),
      );
    } catch (e) {
      print('Error navigating to ExpenseScreen: $e');
      // Optionally, show a message to the user or log the error
    }
  }

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
    _getUserProfileImage();
    //fetchBudgetData(); // Call function to fetch data from Firestore
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          automaticallyImplyLeading: false,
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
                Spacer(),
                // Bouton de recherche
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearching =
                          !_isSearching; // Inverse l'état de la recherche
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              // Utilisation d'un Column pour empiler la barre de recherche et le contenu
              children: [
                // Afficher la barre de recherche si _isSearching est vrai
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '  Rechercher...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      onChanged: (value) {
                        // Logique pour filtrer les résultats en fonction de la recherche
                        print("Recherche : $value");
                      },
                    ),
                  ),
                // Le reste du contenu (IndexedStack)
                Expanded(
                  // Utilisation de Expanded pour occuper tout l'espace restant
                  child: Container(
                    decoration: BoxDecoration(
                      //color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.transparent,
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // Positionnement de l'ombre
                        ),
                      ],
                    ),
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        Center(
                          child: Text("Home Page"),
                        ),
                        GraphScreen(),
                        Center(child: Text("Transactions Page")),
                        AddExpense(),
                        SettingsScreen(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Graphiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_down),
            label: 'Dépenses',
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
