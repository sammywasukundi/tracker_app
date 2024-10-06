// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/screens/home/home_page.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  // Déclaration des variables d'état
  String? categoryId;
  String? categoryName;
  DateTime? selectedDate;

// Variables globales pour le formulaire
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Clé du formulaire

  final TextEditingController _montantDepenseController =
      TextEditingController(); // Contrôleur pour le montant de la dépense
  final TextEditingController _descriptionDepenseController =
      TextEditingController(); // Contrôleur pour la description de la dépense

  String? selectedCategory; // Variable pour stocker la catégorie sélectionnée

// Remplacez par l'ID de votre budget actuel
  late String
      budgetId; // ID du budget actuel auquel les dépenses et catégories sont liées

  List<Map<String, dynamic>> expenseList = [];
  int expenseCount = 0;

  Future<List<Map<String, dynamic>>> fetchCategoriesFromFirestore() async {
    try {
      // Référence à la collection des catégories dans Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('budgetId', isEqualTo: budgetId) // Filtrer par ID du budget
          .get();

      // Parcourir les résultats et extraire les noms de catégories
      snapshot.docs.map((doc) {
        return (doc.data() as Map<String, dynamic>)['name'] as String;
      }).toList();

      return [
      {'id': '1', 'name': 'Catégorie 1'},
      {'id': '2', 'name': 'Catégorie 2'},
    ];
    } catch (e) {
      print("Erreur lors de la récupération des catégories : $e");
      return [];
    }
  }

  Future<void> addExpense(String categoryId, String categoryName, String amount,
      String description, DateTime date, String userId) async {
    try {
      // Référence à la collection des dépenses dans Firestore
      CollectionReference expensesRef =
          FirebaseFirestore.instance.collection('expenses');

      // Ajouter une nouvelle dépense dans Firestore
      await expensesRef.add({
        'userId': userId, // ID de l'utilisateur actuel
        'budgetId': budgetId, // ID du budget lié à la dépense
        'categoryId': categoryId, // ID de la catégorie sélectionnée
        'categoryName':
            categoryName, // Nom de la catégorie pour affichage rapide
        'amount': double.parse(amount), // Montant de la dépense
        'description': description, // Description de la dépense
        'date': date, // Date de la dépense
        'createdAt': FieldValue.serverTimestamp(), // Timestamp de création
      });

      print("Dépense ajoutée avec succès !");
    } catch (e) {
      print("Erreur lors de l'ajout de la dépense : $e");
    }
  }

  // Supprimer la category de la collection
  Future<void> deleteCat(String categoryId) async {
    await FirebaseFirestore.instance
        .collection('categorie')
        .doc(categoryId)
        .delete();

    setState(() {
      expenseList.removeWhere((expense) => expense['id'] == categoryId);
      expenseCount = expenseList.length; // Mettre à jour le nombre
    });
  }

  //update la category
  Future<void> updateCat(
      String categoryId, String newNom, String newDescription) async {
    try {
      // Récupérer le document
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('categorie')
          .doc(categoryId)
          .get();

      // Vérifier si le document existe
      if (docSnapshot.exists) {
        // Si le document existe, procéder à la mise à jour
        await FirebaseFirestore.instance
            .collection('categorie')
            .doc(categoryId)
            .update({
          'nom': newNom,
          'description': newDescription,
        });

        // Mettre à jour localement les données si vous les stockez dans une liste
        setState(() {
          int index = expenseList
              .indexWhere((category) => category['id'] == categoryId);
          if (index != -1) {
            expenseList[index]['nom'] = newNom;
            expenseList[index]['description'] = newDescription;
          }
        });
      } else {
        // Si le document n'existe pas, afficher une erreur
        throw FirebaseException(
            plugin: 'cloud_firestore',
            message: 'Le document avec ID $categoryId n\'existe pas.',
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

  void _showUpdateFormDialog(
      BuildContext context, String categoryId, String nom, String description) {
    TextEditingController nomController = TextEditingController(text: nom);
    TextEditingController descriptionController =
        TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier la catégorie'),
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
                    controller: nomController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Nom',
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
                    controller: descriptionController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'description de la catégorie',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w200,
                      ),
                      suffixIcon: Icon(
                        Icons.money,
                        color: Colors.grey,
                      ),
                    ),
                    keyboardType: TextInputType.text,
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
                await updateCat(
                    categoryId, nomController.text, descriptionController.text);

                // Fermer la boîte de dialogue
                Navigator.of(context).pop();

                // Afficher un message de succès
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Catégorie mise à jour avec succès !')),
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

  void _showExpenseFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Ajouter une dépense'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Sélection de la catégorie
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future:
                        fetchCategoriesFromFirestore(), // Fonction pour récupérer les catégories
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Text('Aucune catégorie disponible');
                      }
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        items: snapshot.data!.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'], // ID de la catégorie
                            child: Text(category['name']), // Nom de la catégorie
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            categoryId =
                                value; // Assignation de l'ID de la catégorie sélectionnée
                            categoryName = snapshot.data!
                                    .firstWhere((cat) => cat['id'] == value)[
                                'name']; // Récupération du nom de la catégorie
                          });
                        },
                        validator: (val) => val == null
                            ? 'Veuillez sélectionner une catégorie'
                            : null,
                      );
                    },
                  ),
                  SizedBox(height: 10),
          
                  // Montant de la dépense
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextFormField(
                        controller: _montantDepenseController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Montant',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w200,
                          ),
                          suffixIcon: Icon(
                            Icons.attach_money,
                            color: Colors.grey,
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Montant de la dépense requis'
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
          
                  // Description de la dépense
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextFormField(
                      controller: _descriptionDepenseController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Description',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w200,
                        ),
                        suffixIcon: Icon(
                          Icons.description,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Description requise'
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),
          
                  // Sélection de la date de la dépense
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate == null
                                  ? 'Sélectionner une date'
                                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                          ],
                        ),
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
                    String nom = categoryName!;
                    String montant = _montantDepenseController.text;
                    String description = _descriptionDepenseController.text;
                    DateTime date = selectedDate!;
          
                    // Récupérer l'ID de l'utilisateur actuel
                    User? user = FirebaseAuth.instance.currentUser;
                    String userId = user!.uid;
          
                    if (userId.isNotEmpty && categoryId != null) {
                      // Appel de la fonction pour ajouter la dépense
                      await addExpense(
                          categoryId!, nom, montant, description, date, userId);
          
                      // Afficher un message de succès
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dépense ajoutée avec succès !')),
                      );
          
                      // Réinitialiser les champs du formulaire
                      _montantDepenseController.clear();
                      _descriptionDepenseController.clear();
          
                      // Fermer le formulaire
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Veuillez vous connecter et sélectionner une catégorie pour ajouter une dépense.')),
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          'Liste de dépenses',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '$expenseCount dépenses ajoutées',
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
                        _showExpenseFormDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              // Première ListView
              Expanded(
                child: ListView.builder(
                  itemCount: expenseList.length,
                  itemBuilder: (context, int index) {
                    var expense = expenseList[index];
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
                                    '${expense['nom']}',
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
                                    '${expense['description']}',
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
                                        String categoryId = expense[
                                            'id']; // Accéder à l'ID via la clé 'id'

                                        // Vérifier que l'ID n'est pas vide
                                        if (categoryId.isNotEmpty) {
                                          // Appel de la fonction pour supprimer le revenu
                                          await deleteCat(categoryId);

                                          // Afficher un message de succès
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Catégorie supprimée avec succès !')),
                                          );
                                        } else {
                                          throw 'L\'ID de la catégorie est invalide.';
                                        }
                                      } catch (e) {
                                        // En cas d'erreur
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Erreur lors de la suppression de la catégorie : $e')),
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
                                          expense['id'] ?? 'ID non disponible';
                                      String nom =
                                          expense['nom'] ?? 'Nom inconnue';
                                      String description =
                                          expense['description'] ??
                                              'Description inconue';

                                      // Appel de la méthode pour afficher le formulaire de mise à jour
                                      _showUpdateFormDialog(
                                        context,
                                        id, // ID du revenu à modifier
                                        nom, // Source actuelle du revenu
                                        description, // Montant actuel du revenu
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
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          budgetId: 'id',
                        )),
              );
            },
            label: Text(
              'Terminer',
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
