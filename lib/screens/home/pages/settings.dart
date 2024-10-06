// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    List<DocumentSnapshot> budgets = await _fetchUserBudgets(user.uid);

    // Afficher la boîte de dialogue sans bordures
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          // Pas de borderRadius
          backgroundColor: Colors.grey[100],
          child: Container(
            width: 400,
            height: 550,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mes Budgets',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                budgets.isNotEmpty
                    ? Container(
                        height: 300, // Hauteur de la liste
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: budgets.length,
                          itemBuilder: (context, index) {
                            var budget =
                                budgets[index].data() as Map<String, dynamic>;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    4.0), // Bordure arrondie
                                side: BorderSide(
                                    color: Colors.transparent,
                                    width:
                                        2.0), // Couleur et largeur de la bordure
                              ),
                              color: Colors.grey[100],
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(
                                    16.0), // Padding autour du contenu
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
                                  budget['nomBudget'] ?? 'Budget sans nom',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                  ),
                                ),
                                subtitle: Text(
                                  'Montant: ${budget['montant'] ?? '0'}',
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
                                        budgets[index]
                                            .id); // Appel à la fonction de confirmation
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
                    padding: const EdgeInsets.only(top: 130.0),
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
  void _confirmDeleteBudget(BuildContext context, String budgetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce budget ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog sans rien faire
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                _deleteBudget(budgetId);
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
  void _deleteBudget(String budgetId) async {
    await FirebaseFirestore.instance
        .collection('budget')
        .doc(budgetId)
        .delete();
    print("Budget supprimé");
  }

// Fonction pour récupérer les budgets de l'utilisateur depuis Firestore
  Future<List<DocumentSnapshot>> _fetchUserBudgets(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('budget')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs;
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
    // Récupération des informations de l'utilisateur (remplacez par votre logique)
    User? user = FirebaseAuth.instance.currentUser; // Par exemple
    String userName = user?.displayName ?? 'Nom non disponible';
    String userEmail = user?.email ?? 'Email non disponible';
    String userPhotoUrl = user?.photoURL ?? ''; // URL de la photo

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          child: Container(
            width: 400, // Largeur du dialog
            height: 180, // Hauteur du dialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: userPhotoUrl.isNotEmpty
                            ? NetworkImage(userPhotoUrl)
                            : AssetImage(
                                'assets/default_user.png'), // Image par défaut
                        radius: 40,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Logique pour déconnexion
                        //FirebaseAuth.instance.signOut();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Colors.grey, // Couleur du texte du bouton
                        backgroundColor: Colors
                            .transparent, // Couleur de fond du bouton (facultatif)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)
                        )
                      ),
                      child: Text('Retour'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Logique pour suppression du compte
                        _confirmDeleteAccount(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Colors.redAccent, // Couleur du texte du bouton
                        backgroundColor: Colors
                            .transparent, // Couleur de fond du bouton (facultatif)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)
                        )
                      ),
                      child: Text('Supprimer'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Logique pour modification des informations
                        _showEditUserDialog(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Colors.blueAccent, // Couleur du texte du bouton
                        backgroundColor: Colors
                            .transparent, // Couleur de fond du bouton (facultatif)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)
                        )
                      ),
                      child: Text('Modifier'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Fonction pour confirmer la suppression du compte
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation de Suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer votre compte ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialog
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                // Logique pour supprimer le compte
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Supprimez l'utilisateur
                  await user.delete();
                  Navigator.of(context).pop(); // Ferme le dialog
                }
              },
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

// Fonction pour afficher le dialog d'édition des informations
  void _showEditUserDialog(BuildContext context) {
    // Implémentez ici votre logique pour l'édition des informations
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Deux boutons par ligne
          crossAxisSpacing: 14.0, // Espace horizontal entre les boutons
          mainAxisSpacing: 14.0, // Espace vertical entre les boutons
          children: <Widget>[
            _buildButtonBudget(context, Icons.account_balance, 'Mes Budgets',
                onTap: () => _showBudgetsDialog(context)),
            _userAccount(context, Icons.account_circle, 'Mon Compte',
                onTap: () => _showUserInfoDialog(context)),
            _buildButton(context, Icons.trending_down, 'Mes dépenses'),
            _buildButton(context, Icons.history, 'Historique'),
            _buildButton(context, Icons.help_outline, 'A propos de nous'),
            _buildButton(context, Icons.exit_to_app,
                'Déconnexion'), // Ajout du bouton Déconnexion
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
                    Navigator.of(context).pop(); // Fermer le dialogue
                  },
                  style: TextButton.styleFrom(
                    shape: const StadiumBorder(), // Forme de bouton en stade
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
                    // Si l'utilisateur confirme la déconnexion
                    FirebaseAuth.instance.signOut(); // Action de déconnexion
                    Navigator.of(context).pop(); // Fermer le dialogue
                  },
                  style: TextButton.styleFrom(
                    shape: const StadiumBorder(), // Forme de bouton en stade
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
        backgroundColor:
            Colors.blueAccent[200], // Espacement à l'intérieur du bouton
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bords arrondis
        ), // Couleur de fond du bouton
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
}
