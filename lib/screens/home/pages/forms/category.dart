// ignore_for_file: prefer_const_constructors

import 'package:budget_app/screens/home/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddCategorie extends StatefulWidget {
  const AddCategorie({super.key});

  @override
  State<AddCategorie> createState() => _AddCategorieState();
}

class _AddCategorieState extends State<AddCategorie> {
  final _formKey = GlobalKey<FormState>();
  final _nomCat = TextEditingController();
  final _descriptionCat = TextEditingController();

  List<Map<String, dynamic>> categoryList = [];
  int categoryCount = 0;

  // List<QueryDocumentSnapshot<Map<String, dynamic>>> budgets = [];

  // Future<void> fetchBudgets() async {
  //   User? currentUser = FirebaseAuth.instance.currentUser;

  //   if (currentUser == null) {
  //     print("Aucun utilisateur connecté.");
  //     return;
  //   }

  //   try {
  //     QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
  //         .instance
  //         .collection('budget')
  //         .where('userId', isEqualTo: currentUser.uid)
  //         .get();

  //     // Stocker les budgets dans la liste
  //     setState(() {
  //       budgets = snapshot.docs;
  //     });
  //   } catch (e) {
  //     print('Erreur lors de la récupération des budgets : $e');
  //   }
  // }

  Future<String> getUserBudgetId(String userId) async {
    // Récupérer le budget de l'utilisateur à partir de Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('budget')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Retourner l'ID du premier budget trouvé
      return snapshot.docs.first.id;
    }
    return ''; // Retourner une chaîne vide si aucun budget n'est trouvé
  }

  Future<void> addCat(String nom, String description, String budgetId) async {
    try {
      // Récupérer l'utilisateur actuellement connecté
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("Aucun utilisateur connecté.");
        return;
      }

      // Récupérer l'ID de l'utilisateur connecté
      String userId = currentUser.uid;

      // Ajouter la catégorie avec l'ID du budget et l'ID de l'utilisateur
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('categorie').add({
        'nom': nom,
        'description': description,
        'userId': userId, // L'ID de l'utilisateur est récupéré ici
        'budgetId': budgetId, // ID du budget passé en paramètre
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Ajouter à la liste et mettre à jour l'état
      setState(() {
        categoryList.add({
          'id': docRef.id,
          'nom': nom,
          'description': description,
          'budgetId': budgetId, // Stocker l'ID du budget
        });
        categoryCount = categoryList.length; // Mettre à jour le nombre
      });
    } catch (e) {
      print("Erreur lors de l'ajout de la catégorie : $e");
    }
  }

// Supprimer la category de la collection
  Future<void> deleteCat(String categoryId) async {
    await FirebaseFirestore.instance
        .collection('categorie')
        .doc(categoryId)
        .delete();

    setState(() {
      categoryList.removeWhere((category) => category['id'] == categoryId);
      categoryCount = categoryList.length; // Mettre à jour le nombre
    });
  }

  //update la category
  Future<void> updateCat(String categoryId, String newNom,
      String newDescription, String? newBudgetId) async {
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
          if (newBudgetId != null)
            'budgetId': newBudgetId, // Mettre à jour l'ID du budget si fourni
        });

        // Mettre à jour localement les données si vous les stockez dans une liste
        setState(() {
          int index = categoryList
              .indexWhere((category) => category['id'] == categoryId);
          if (index != -1) {
            categoryList[index]['nom'] = newNom;
            categoryList[index]['description'] = newDescription;
            if (newBudgetId != null) {
              categoryList[index]['budgetId'] =
                  newBudgetId; // Mettre à jour l'ID du budget localement
            }
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
      print('Erreur lors de la mise à jour de la catégorie : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  //formulaire pour update un revenu
  void _showUpdateFormDialog(
      BuildContext context, String categoryId, String nom, String description) {
    TextEditingController nomController = TextEditingController(text: nom);
    TextEditingController descriptionController =
        TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
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
                await updateCat(categoryId, nomController.text,
                    descriptionController.text, null);

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

  void _showCatFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          title: Text('Ajouter une catégorie'),
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
                      controller: _nomCat,
                      keyboardType: TextInputType.text,
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
                      validator: (val) => val == null || val.isEmpty
                          ? 'Nom de la catégorie requis'
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
                      controller: _descriptionCat,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'description',
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
                          ? 'description requise'
                          : null,
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
                  String nom = _nomCat.text;
                  String description = _descriptionCat.text;

                  // Récupérer l'ID de l'utilisateur actuel
                  User? user = FirebaseAuth.instance.currentUser;
                  String userId = user!.uid;

                  // Récupérer l'ID du budget de l'utilisateur (assurez-vous d'avoir une méthode pour cela)
                  String budgetId = await getUserBudgetId(
                      userId); // Implémentez cette méthode pour obtenir l'ID du budget

                  if (userId.isNotEmpty && budgetId.isNotEmpty) {
                    // Appel de la fonction pour ajouter la catégorie
                    await addCat(nom, description, budgetId);

                    // Afficher un message de succès
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Catégorie ajoutée avec succès !')),
                    );

                    // Réinitialiser les champs du formulaire
                    _nomCat.clear();
                    _descriptionCat.clear();

                    // Fermer le formulaire
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Veuillez vous connecter et avoir un budget pour ajouter une catégorie.')),
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

  Future<void> addCategoryToFirestore(String nom, String description) async {
    try {
      // Récupérer l'utilisateur connecté
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('Aucun utilisateur connecté');
        return;
      }

      // Ajouter la catégorie à Firestore en incluant l'userId
      await FirebaseFirestore.instance.collection('categorie').add({
        'nom': nom,
        'description': description,
        'userId':
            currentUser.uid, // Associer la catégorie à l'utilisateur connecté
        'createdAt': FieldValue.serverTimestamp(),
      });

      print(
          'Catégorie ajoutée avec succès pour l\'utilisateur : ${currentUser.uid}');
    } catch (e) {
      print('Erreur lors de l\'ajout de la catégorie : $e');
    }
  }

  int categoryCountInterne = 0; // Compteur de catégories ajoutées

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categorie')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        categoryList = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'nom': doc['nom'],
            'description': doc['description'],
          };
        }).toList();

        // Mettre à jour le compteur de catégories ajoutées
        categoryCountInterne = categoryList.length;
      });
    } catch (e) {
      print('Erreur lors de la récupération des catégories : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la récupération des catégories.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> staticCategories = [
      {'nom': 'Ménage', 'description': 'Dépenses pour le ménage'},
      {'nom': 'Restauration', 'description': 'Dépenses pour la restauration'},
      {'nom': 'Habillement', 'description': 'Dépenses pour l\'habillement'},
      {'nom': 'Soin', 'description': 'Dépenses pour le soin'},
      {'nom': 'Alimentation', 'description': 'Dépenses pour nourriture'},
      {'nom': 'Logement', 'description': 'Dépenses pour le logement'},
      {'nom': 'Transport', 'description': 'Dépenses pour le transport'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catégories',
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
                          'Catégories de dépenses budgétisées',
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
                          '$categoryCountInterne catégories internes ajoutées',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        // Text(
                        //   '$categoryCount catégories externes ajoutées',
                        //   style: TextStyle(
                        //     fontSize: 12.0,
                        //     fontWeight: FontWeight.w400,
                        //     color: Theme.of(context).colorScheme.onSurface,
                        //   ),
                        // ),
                      ]),
                    ),
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.add,
                    //     color: Colors.blueAccent,
                    //     size: 28,
                    //   ),
                    //   onPressed: () {
                    //     // Action pour ajouter un revenu ou une catégorie
                    //     _showCatFormDialog(context);
                    //   },
                    // ),
                  ],
                ),
              ),
              // Première ListView
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: staticCategories.length,
                  itemBuilder: (context, int index) {
                    var category = staticCategories[index];

                    // Vérifier si la catégorie est déjà ajoutée
                    bool isCategoryAdded = categoryList
                        .any((cat) => cat['nom'] == category['nom']);

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
                                    '${category['nom']}',
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
                                    '${category['description']}',
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
                              Row(
                                children: [
                                  if (!isCategoryAdded)
                                    IconButton(
                                      icon:
                                          Icon(Icons.add, color: Colors.green),
                                      onPressed: () async {
                                        // Ajouter la catégorie
                                        await addCategoryToFirestore(
                                          category['nom'],
                                          category['description'],
                                        );
                                        // Mettre à jour l'état
                                        await fetchCategories();
                                      },
                                    )
                                  else
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove,
                                              color: Colors.redAccent),
                                          onPressed: () async {
                                            var addedCategory =
                                                categoryList.firstWhere((cat) =>
                                                    cat['nom'] ==
                                                    category['nom']);
                                            await deleteCat(
                                                addedCategory['id']);
                                            await fetchCategories();
                                          },
                                        ),
                                        SizedBox(width: 4),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.orangeAccent),
                                          onPressed: () {
                                            var addedCategory =
                                                categoryList.firstWhere((cat) =>
                                                    cat['nom'] ==
                                                    category['nom']);
                                            _showUpdateFormDialog(
                                              context,
                                              addedCategory['id'],
                                              addedCategory['nom'],
                                              addedCategory['description'],
                                            );
                                          },
                                        ),
                                      ],
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

              SizedBox(height: 16), // Espacement entre les deux ListView

              // Deuxième ListView dynamique pour les catégories dans Firestore
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: categoryList.length,
              //     itemBuilder: (context, int index) {
              //       var category = categoryList[index];
              //       return Padding(
              //         padding: const EdgeInsets.only(bottom: 8.0),
              //         child: Container(
              //           decoration: BoxDecoration(
              //             color: Colors.white,
              //             borderRadius: BorderRadius.circular(4),
              //           ),
              //           child: Padding(
              //             padding: const EdgeInsets.all(10.0),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     Text(
              //                       '${category['nom']}',
              //                       style: TextStyle(
              //                         fontSize: 14.0,
              //                         color: Theme.of(context)
              //                             .colorScheme
              //                             .onSurface,
              //                         fontWeight: FontWeight.w500,
              //                       ),
              //                     ),
              //                     SizedBox(height: 12),
              //                     Text(
              //                       '${category['description']}',
              //                       style: TextStyle(
              //                         fontSize: 14.0,
              //                         color: Theme.of(context)
              //                             .colorScheme
              //                             .onSurface,
              //                         fontWeight: FontWeight.w400,
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //                 Row(
              //                   children: [
              //                     IconButton(
              //                       icon: Icon(Icons.remove,
              //                           color: Colors.redAccent),
              //                       onPressed: () async {
              //                         String categoryId = category['id'];

              //                         if (categoryId.isNotEmpty) {
              //                           await deleteCat(categoryId);
              //                           setState(() {});
              //                         } else {
              //                           ScaffoldMessenger.of(context)
              //                               .showSnackBar(
              //                             SnackBar(
              //                                 content: Text(
              //                                     'ID de catégorie manquant.')),
              //                           );
              //                         }
              //                       },
              //                     ),
              //                     SizedBox(width: 4),
              //                     IconButton(
              //                       icon: Icon(Icons.edit,
              //                           color: Colors.orangeAccent),
              //                       onPressed: () {
              //                         _showUpdateFormDialog(
              //                           context,
              //                           category['id'],
              //                           category['nom'],
              //                           category['description'],
              //                         );
              //                       },
              //                     ),
              //                   ],
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
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
