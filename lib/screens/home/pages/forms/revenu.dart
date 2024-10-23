// ignore_for_file: prefer_const_constructors, prefer_if_null_operators, use_build_context_synchronously, body_might_complete_normally_catch_error

import 'package:budget_app/screens/home/pages/forms/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  List<QueryDocumentSnapshot<Map<String, dynamic>>> budgets = [];

  Future<void> fetchBudgets() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("Aucun utilisateur connecté.");
      return;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('budget')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      // Stocker les budgets dans la liste
      setState(() {
        budgets = snapshot.docs;
      });
    } catch (e) {
      print('Erreur lors de la récupération des budgets : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    String budgetId =
        "budgetId"; 

    // Appelez la méthode fetchRevenus avec l'ID du budget
    fetchRevenus(budgetId);
  }

  Future<void> fetchRevenus(String budgetId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Revenus')
          .where('budgetId', isEqualTo: budgetId) 
          .get();

      setState(() {
        revenusList = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        revenusCount = revenusList.length; 
      });

      if (revenusList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucun revenu trouvé pour ce budget.')),
        );
      }
    } catch (e) {
      print('Erreur lors de la récupération des revenus : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des revenus.')),
      );
    }
  }

  Future<void> addRevenu(
      String source, double montant, String budgetId, String budgetName) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("Aucun utilisateur connecté.");
        return;
      }

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('Revenus').add({
        'source': source,
        'montant': montant,
        'budgetId': budgetId, 
        'budgetName': budgetName, 
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        revenusList.add({
          'id': docRef.id,
          'source': source,
          'montant': montant,
          'budgetId': budgetId,
          'budgetName': budgetName, 
        });
        revenusCount = revenusList.length; 
      });

      print("Revenu ajouté avec succès pour le budget $budgetName.");
    } catch (e) {
      print("Erreur lors de l'ajout du revenu : $e");
    }
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
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
  void _showCategoryFormDialog(BuildContext context) async {
    await fetchBudgets();

    String? selectedBudgetId;
    String? selectedBudgetName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          title: Text('Ajouter un revenu'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Dropdown pour sélectionner le budget
                    DropdownButtonFormField<String>(
                      value: selectedBudgetId,
                      decoration: InputDecoration(
                        labelText: 'Sélectionnez un budget',
                        border: OutlineInputBorder(),
                      ),
                      items: budgets.map((budget) {
                        var budgetData = budget.data();
                        return DropdownMenuItem<String>(
                          value: budget.id,
                          child:
                              Text(budgetData['nomBudget'] ?? 'Budget sans nom'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBudgetId = newValue;
                          selectedBudgetName = budgets
                              .firstWhere((budget) => budget.id == newValue)
                              .data()['nomBudget'];
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un budget';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // Champ pour la source du revenu
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          controller: _sourceRevenu,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Description/Source',
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
                              ? 'Source du revenu requise'
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Champ pour le montant du revenu
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
                            hintText: 'Montant pour le revenu',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w200,
                            ),
                            suffixIcon: Icon(
                              Icons.money,
                              color: Colors.grey,
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Montant requis'
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                if (_formKey.currentState!.validate() &&
                    selectedBudgetId != null) {
                  String source = _sourceRevenu.text;
                  double montant = double.parse(_montantRevenu.text);

                  // Appeler la fonction pour ajouter le revenu
                  await addRevenu(
                      source, montant, selectedBudgetId!, selectedBudgetName!);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Revenu ajouté avec succès pour $selectedBudgetName !')),
                  );

                  _sourceRevenu.clear();
                  _montantRevenu.clear();

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez sélectionner un budget.')),
                  );
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
                                    'Montant : \$ ${revenu['montant']}',
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
                                        String revenuId = revenu[
                                            'id']; 

                                        if (revenuId.isNotEmpty) {
                                          await deleteRevenu(revenuId);

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

                                      String id =
                                          revenu['id'] ?? 'ID non disponible';
                                      String source =
                                          revenu['source'] ?? 'Source inconnue';
                                      double montant = revenu['montant'] != null
                                          ? revenu['montant']
                                          : 0.0; 

                                      _showUpdateFormDialog(
                                        context,
                                        id, 
                                        source, 
                                        montant, 
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
