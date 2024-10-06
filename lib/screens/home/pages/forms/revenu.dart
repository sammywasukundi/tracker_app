// ignore_for_file: prefer_const_constructors, prefer_if_null_operators, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/screens/home/pages/forms/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceRevenu = TextEditingController();
  final _montantRevenu = TextEditingController();

  List<Map<String, dynamic>> revenusList = [];
  int revenusCount = 0;

 @override
void initState() {
  super.initState();
  // Assurez-vous que vous avez une variable budgetId de type String
  String budgetId = "budgetId"; // Remplacez par votre logique pour obtenir l'ID du budget
  
  // Appelez la méthode fetchRevenus avec l'ID du budget
  fetchRevenus(budgetId);
}


  Future<void> fetchRevenus(String budgetId) async {
  try {
    // Requête pour obtenir uniquement les revenus liés à ce budget
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Revenus')
        .where('budgetId', isEqualTo: budgetId) // Filtrer par l'ID du budget
        .get();

    // Met à jour l'état avec la liste des revenus récupérés
    setState(() {
      revenusList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      revenusCount = revenusList.length; // Met à jour le nombre de revenus
    });

    if (revenusList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun revenu trouvé pour ce budget.')),
      );
    }
  } catch (e) {
    // Gestion des erreurs
    print('Erreur lors de la récupération des revenus : $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de la récupération des revenus.')),
    );
  }
}


  Future<void> addRevenu(String source, double montant, String userId) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('Revenus').add({
      'source': source,
      'montant': montant,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Ajouter à la liste et mettre à jour l'état
    setState(() {
      revenusList.add({
        'id': docRef.id,
        'source': source,
        'montant': montant,
      });
      revenusCount = revenusList.length; // Mettre à jour le nombre
    });
  }

// Supprimer le revenu de la collection
  Future<void> deleteRevenu(String revenuId) async {
    await FirebaseFirestore.instance
        .collection('Revenus')
        .doc(revenuId)
        .delete();

    setState(() {
      revenusList.removeWhere((revenu) => revenu['id'] == revenuId);
      revenusCount = revenusList.length; // Mettre à jour le nombre
    });
  }

  //update un revenu
  Future<void> updateRevenu(
      String revenuId, String newSource, double newMontant) async {
    try {
      // Récupérer le document
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Revenus')
          .doc(revenuId)
          .get();

      // Vérifier si le document existe
      if (docSnapshot.exists) {
        // Si le document existe, procéder à la mise à jour
        await FirebaseFirestore.instance
            .collection('Revenus')
            .doc(revenuId)
            .update({
          'source': newSource,
          'montant': newMontant,
        });

        // Mettre à jour localement les données si vous les stockez dans une liste
        setState(() {
          int index =
              revenusList.indexWhere((revenu) => revenu['id'] == revenuId);
          if (index != -1) {
            revenusList[index]['source'] = newSource;
            revenusList[index]['montant'] = newMontant;
          }
        });
      } else {
        // Si le document n'existe pas, afficher une erreur
        throw FirebaseException(
            plugin: 'cloud_firestore',
            message: 'Le document avec ID $revenuId n\'existe pas.',
            code: 'not-found');
      }
    } catch (e) {
      // Gérer l'erreur
      print('Erreur lors de la mise à jour du revenu : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  //formulaire pour update un revenu
  void _showUpdateFormDialog(
      BuildContext context, String revenuId, String source, double montant) {
    TextEditingController sourceController =
        TextEditingController(text: source);
    TextEditingController montantController =
        TextEditingController(text: montant.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le revenu'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: TextFormField(
                    controller: sourceController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Description/Soucre',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w200,
                      ),
                      suffixIcon: Icon(
                        Icons.source,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: TextFormField(
                    controller: montantController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Montant pour le révenu',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w200,
                      ),
                      suffixIcon: Icon(
                        Icons.money,
                        color: Colors.grey,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                )),
            TextButton(
              onPressed: () async {
                // Appel de la fonction pour mettre à jour le revenu
                await updateRevenu(revenuId, sourceController.text,
                    double.parse(montantController.text));

                // Fermer la boîte de dialogue
                Navigator.of(context).pop();

                // Afficher un message de succès
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Revenu mis à jour avec succès !')),
                );
              },
              child: Container(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Mettre à jour',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // formulaire pour ajouter un revenu
  void _showCategoryFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un révenu'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Nom du revenu
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      controller: _sourceRevenu,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Description/Soucre',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w200,
                        ),
                        suffixIcon: Icon(
                          Icons.source,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Nom du révenu requis'
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // montant
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      controller: _montantRevenu,
                      keyboardType: TextInputType.numberWithOptions(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Montant pour le révenu',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w200,
                        ),
                        suffixIcon: Icon(
                          Icons.money,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Montant requis' : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  // Récupération des valeurs du formulaire
                  String source = _sourceRevenu.text;
                  double montant = double.parse(_montantRevenu.text);

                  // Récupérer l'ID de l'utilisateur actuel
                  User? user = FirebaseAuth.instance.currentUser;
                  String userId = user!.uid;

                  if (userId.isNotEmpty) {
                    // Appel de la fonction pour ajouter le revenu
                    await addRevenu(source, montant, userId);

                    // Afficher un message de succès
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Revenu ajouté avec succès !')),
                    );

                    // Réinitialiser les champs du formulaire
                    _sourceRevenu.clear();
                    _montantRevenu.clear();

                    // Fermer le formulaire
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Veuillez vous connecter pour ajouter un revenu.')),
                    );
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Ajouter',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Revenus',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Column(
            children: [
              // Premier titre et ListView
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(children: [
                        Text(
                          'Revenu disponible',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '$revenusCount revenus ajoutés',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ]),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                      onPressed: () {
                        // Action pour ajouter un revenu ou une catégorie
                        _showCategoryFormDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              // Première ListView
              Expanded(
                child: ListView.builder(
                  itemCount: revenusList.length,
                  itemBuilder: (context, int index) {
                    var revenu = revenusList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Source : ${revenu['source']}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Montant : ${revenu['montant']} USD',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              // Colonne pour les actions (modifier/supprimer)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove,
                                        color: Colors.redAccent),
                                    onPressed: () async {
                                      try {
                                        // Vérifier que revenu n'est pas nul
                                        // Récupérer l'ID du revenu dans la Map
                                        String revenuId = revenu[
                                            'id']; // Accéder à l'ID via la clé 'id'

                                        // Vérifier que l'ID n'est pas vide
                                        if (revenuId.isNotEmpty) {
                                          // Appel de la fonction pour supprimer le revenu
                                          await deleteRevenu(revenuId);

                                          // Afficher un message de succès
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Revenu supprimé avec succès !')),
                                          );
                                        } else {
                                          throw 'L\'ID du revenu est invalide.';
                                        }
                                                                            } catch (e) {
                                        // En cas d'erreur
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Erreur lors de la suppression du revenu : $e')),
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(width: 4),
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.orangeAccent),
                                    onPressed: () {
                                      // Vérifiez si les champs existent avant d'appeler la fonction
                                      String id =
                                          revenu['id'] ?? 'ID non disponible';
                                      String source =
                                          revenu['source'] ?? 'Source inconnue';
                                      double montant = revenu['montant'] != null
                                          ? revenu['montant']
                                          : 0.0; // Valeur par défaut pour montant

                                      // Appel de la méthode pour afficher le formulaire de mise à jour
                                      _showUpdateFormDialog(
                                        context,
                                        id, // ID du revenu à modifier
                                        source, // Source actuelle du revenu
                                        montant, // Montant actuel du revenu
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 140,
        height: 70,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onPressed: () {
              // Naviguer vers le HomeScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategorie()),
              );
            },
            label: Text(
              'Suivant',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.5,
                  color: Colors.white),
            ),
            icon: Icon(Icons.check, size: 24, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Positionnement en bas à droite
    );
  }
}
