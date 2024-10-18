// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

//import 'package:firebase_storage/firebase_storage.dart';
import 'package:budget_app/screens/home/main_screen.dart';
import 'package:budget_app/screens/home/pages/forms/expense.dart';
import 'package:budget_app/screens/home/pages/graphs/graph.dart';
import 'package:budget_app/screens/home/pages/settings.dart';
import 'package:budget_app/screens/home/pages/transaction.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _searchController = TextEditingController();

  String? imageUrl;
  int _selectedIndex = 0; // to track the selected tab
  String? firstName;
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

  Widget buildUserDetails() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchCurrentUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child:
                  Text('Erreur lors du chargement des détails utilisateur.'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Aucun utilisateur trouvé.'));
        } else {
          Map<String, dynamic> user = snapshot.data!;

          return Column(
            children: [
              user['profile'] != null
                  ? Image.network(user['profile'],
                      width: 100, height: 100, fit: BoxFit.cover)
                  : Icon(Icons.account_circle, size: 100),
              SizedBox(height: 10),
              Text('${user['firstName']} ${user['lastName']}',
                  style: TextStyle(fontSize: 20)),
              Text(user['email']),
              Text('Ajouté le: ${user['createdAt']}'),
            ],
          );
        }
      },
    );
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
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    //User? user = FirebaseAuth.instance.currentUser;

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
                Spacer(),
                // Bouton de recherche
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      // Gérer la recherche (ajouter votre logique ici)
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
                        MainScreen(),
                        GraphScreen(),
                        TransactionScreen(),
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
