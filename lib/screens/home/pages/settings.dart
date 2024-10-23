// ignore_for_file: prefer_const_constructors

import 'package:budget_app/model/budged.dart';
import 'package:budget_app/model/depense.dart';
import 'package:budget_app/model/revenue.dart';
import 'package:budget_app/model/user.dart';
import 'package:budget_app/screens/home/pages/forms/budget.dart';
import 'package:budget_app/screens/home/pages/forms/expense.dart';
import 'package:budget_app/screens/home/pages/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? imageUrl;
  User? user = FirebaseAuth.instance.currentUser;

  Map<String, dynamic>? userDetails;

  Future<void> fetchUserDetails() async {
    final details = await fetchCurrentUserDetails();
    setState(() {
      userDetails = details;
    });
  }

  Future<Map<String, dynamic>?> fetchCurrentUserDetails() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('Aucun utilisateur connecté.');
        return null;
      }

      String uid = currentUser.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(UserModel.collection)
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        print('Aucun utilisateur trouvé pour cet UID: $uid.');
        return null;
      }

      Map<String, dynamic> userData = {
        'fName': userDoc['fName'],
        'lName': userDoc['lName'],
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

  // Fonction pour afficher la boîte de dialogue avec la liste des budgets
  void _showBudgetsDialog(BuildContext context) async {
    // Récupérer l'utilisateur connecté
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Veuillez vous connecter pour voir vos budgets.')),
      );
      return;
    }

    // Récupérer les budgets depuis Firestore
    List<BudgetModel> budgets = await _fetchUserBudgets();

    // Afficher la boîte de dialogue sans bordures
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          backgroundColor: Colors.grey[100],
          child: Container(
            width: 400,
            height: 550,
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              // Ajout de SingleChildScrollView
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mes Budgets',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.blueAccent),
                        onPressed: () {
                          // Naviguer vers la page d'ajout de budget
                          Navigator.of(context).pop(); // Ferme le dialogue
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FormBudget()),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  budgets.isNotEmpty
                      ? SizedBox(
                          height: 300, // Hauteur de la liste
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: budgets.length,
                            itemBuilder: (context, index) {
                              var budget = budgets[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  side: BorderSide(
                                    color: Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                                color: Colors.grey[100],
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16.0),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    budget.nomBudget,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Montant: \$ ${budget.montant}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      _confirmDeleteBudget(
                                        context,
                                        budgets[index],
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child:
                              Text('Aucun budget trouvé pour cet utilisateur.'),
                        ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0), // Réduire le padding
                      child: Text(
                        'Fermer',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _userAccount(BuildContext context, IconData icon, String label,
      {void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap, // Ajoutez cette ligne pour gérer l'événement onTap
      child: Card(
        elevation: 4, // Élévation pour l'ombre
        color: Colors.blueAccent, // Couleur de fond
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Coins arrondis
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white), // Couleur de l'icône
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600, // Texte en gras
                  color: Colors.white, // Couleur du texte
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Fonction pour supprimer un budget avec confirmation
  void _confirmDeleteBudget(BuildContext context, BudgetModel budget) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce budget ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog sans rien faire
              },
              child: Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                _deleteBudget(budget);
                Navigator.of(context)
                    .pop(); // Fermer le dialog après suppression
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Budget supprimé avec succès.')),
                );
              },
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

// Fonction pour supprimer un budget
  Future<void> _deleteBudget(BudgetModel budget) async {
    try {
      // Start a batch
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Delete the budget document
      DocumentReference budgetRef = FirebaseFirestore.instance
          .collection(BudgetModel.collection)
          .doc(budget.id);
      batch.delete(budgetRef);

      // Delete related revenues
      QuerySnapshot revenuSnapshot = await FirebaseFirestore.instance
          .collection(RevenueModel.collection)
          .where('budgetId', isEqualTo: budget.id)
          .get();

      for (var doc in revenuSnapshot.docs) {
        batch.delete(doc.reference); // Delete each revenue linked to the budget
      }


      // Delete related expenses
      QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
          .collection(DepenseModel.collection)
          .where('budgetId', isEqualTo: budget.id)
          .get();

      for (var doc in expenseSnapshot.docs) {
        batch.delete(doc.reference); // Delete each expense linked to the budget
      }

      // Commit the batch
      await batch.commit();

      print("Budget et ses éléments associés supprimés avec succès !");
    } catch (e) {
      print(
          "Erreur lors de la suppression du budget et des éléments associés : $e");
    }
  }

// Fonction pour récupérer les budgets de l'utilisateur depuis Firestore
  Future<List<BudgetModel>> _fetchUserBudgets() async {
    return await BudgetModel.getList;
  }

// Fonction pour construire les boutons
  Widget _buildButtonBudget(BuildContext context, IconData icon, String label,
      {VoidCallback? onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20),
        backgroundColor: Colors.blueAccent[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onTap ?? () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
          SizedBox(height: 10),
          Text(label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  // Fonction pour afficher les informations de l'utilisateur
  void _showUserInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          child: FutureBuilder<Map<String, dynamic>?>(
            future:
                fetchCurrentUserDetails(), // Fetch user details from Firestore
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                    ),
                  ),
                );
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                return SizedBox(
                  height: 180,
                  child: Center(
                    child: Text('Erreur lors du chargement des informations.'),
                  ),
                );
              }

              final userDetails = snapshot.data!;
              String userName =
                  '${userDetails['fName']} ${userDetails['lName']}';
              String userEmail = userDetails['email'] ?? 'Email non disponible';
              String userPhotoUrl = userDetails['profile'] ??
                  ''; // Assuming 'profile' contains the photo URL

              return SizedBox(
                width: 400, // Dialog width
                height: 250, // Dialog height
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 115.0),
                            child: CircleAvatar(
                              backgroundImage: userPhotoUrl.isNotEmpty
                                  ? NetworkImage(userPhotoUrl)
                                  : AssetImage('assets/default_user.png')
                                      as ImageProvider,
                              radius: 40,
                            ),
                          ),
                          SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                userEmail,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Text('Retour'),
                        ),
                        TextButton(
                          onPressed: () {
                            _confirmDeleteAccount(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Text('Supprimer'),
                        ),
                        TextButton(
                          onPressed: () {
                            _showEditUserDialog(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Text('Modifier'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteUser(BuildContext context) async {
    try {
      // Current user from FirebaseAuth
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('Aucun utilisateur connecté');
        return;
      }

      // Delete the user document from Firestore
      await FirebaseFirestore.instance
          .collection(UserModel.collection)
          .doc(currentUser.uid)
          .delete();

      // Delete the user from FirebaseAuth
      await currentUser.delete();

      // Optionally, sign out after deletion
      await FirebaseAuth.instance.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur supprimé avec succès.')),
      );

      // Redirect or close dialog after deletion
      Navigator.of(context).pop();
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la suppression de l\'utilisateur.')),
      );
    }
  }

  // Fonction pour confirmer la suppression du compte
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          title: Text('Confirmation de suppression'),
          content: Text('Voulez-vous vraiment supprimer votre compte ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog before deleting
                await _deleteUser(context); // Call the delete user function
              },
              child: Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

// Fonction pour update le dialog d'édition des informations
  Future<void> _updateUserInfo(
      String firstName, String lastName, String email) async {
    try {
      // Current user from FirebaseAuth
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('Aucun utilisateur connecté');
        return;
      }

      // Update the user's Firestore document
      await FirebaseFirestore.instance
          .collection(UserModel.collection)
          .doc(currentUser.uid)
          .update({
        'fName': firstName,
        'lName': lastName,
        'email': email,
      });

      // Optionally update the user's email in FirebaseAuth
      if (currentUser.email != email) {
        // ignore: deprecated_member_use
        await currentUser.updateEmail(email);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Informations utilisateur mises à jour avec succès.')),
      );
    } catch (e) {
      print('Erreur lors de la mise à jour des informations utilisateur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erreur lors de la mise à jour des informations utilisateur.')),
      );
    }
  }

  void _showEditUserDialog(BuildContext context) {
    TextEditingController firstNameController =
        TextEditingController(text: userDetails?['fName'] ?? '');
    TextEditingController lastNameController =
        TextEditingController(text: userDetails?['lName'] ?? '');
    TextEditingController emailController =
        TextEditingController(text: userDetails?['email'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          title: Text('Modifier les informations de l\'utilisateur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Nom de famille',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _updateUserInfo(
                  firstNameController.text,
                  lastNameController.text,
                  emailController.text,
                );
                Navigator.of(context).pop();
                setState(() {}); // Refresh the UI with the new user data
              },
              child: Text(
                'Enregistrer',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14.0,
          mainAxisSpacing: 14.0,
          children: <Widget>[
            _buildButtonBudget(context, Icons.account_balance, 'Mes Budgets',
                onTap: () => _showBudgetsDialog(context)),
            _userAccount(context, Icons.account_circle, 'Mon Compte',
                onTap: () => _showUserInfoDialog(context)),
            buildBackButtonExpense(
                context, Icons.trending_down, 'Mes dépenses'),
            _buildButton(context, Icons.book, 'Rapports'),
            _buildButton(context, Icons.help, 'A propos de nous'),
            buildBackButton(context, Icons.arrow_back,
                'Aller à l\'accuiel'), // Ajout du bouton Déconnexion
          ],
        ),
      ),
    );
  }

  // erreur ici
  void backToWelcomeScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  Widget buildBackButton(BuildContext context, IconData icon, String label) {
    return ElevatedButton(
      onPressed: () => backToWelcomeScreen(context), // Appeler la fonction ici
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20.0),
        backgroundColor: Colors.blueAccent[200], // Couleur de fond du bouton
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bords arrondis
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 40.0, // Taille de l'icône
            color: Colors.white, // Couleur de l'icône
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackButtonExpense(
      BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ElevatedButton(
        onPressed: () {
          // Naviguer vers la page de dépenses
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddExpense()),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20.0),
          backgroundColor: Colors.blueAccent[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 40.0,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour créer un bouton avec une icône et un texte
  Widget _buildButton(BuildContext context, IconData icon, String label) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              //title: Center(child: Text("Déconnexion")),
              content: Text(
                "Voulez-vous vous déconnecter ?",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Si l'utilisateur annule
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    shape: const StadiumBorder(),
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
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    "Déconnexion",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent),
                  ),
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20.0),
        backgroundColor: Colors.blueAccent[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 40.0,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
