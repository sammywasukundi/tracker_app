// ignore_for_file: prefer_const_constructors

import 'package:budget_app/model/categorie.dart';
import 'package:budget_app/screens/home/home_page.dart';
import 'package:budget_app/services/firebase/firebase_service.dart';
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

  List<CategorieModel> categoryList = [];
  int categoryCount = 0;

  // Future<String> getUserBudgetId(String userId) async {
  //   // Récupérer le budget de l'utilisateur à partir de Firestore
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('budget')
  //       .where('userId', isEqualTo: userId)
  //       .get();

  //       CategorieModel().

  //   if (snapshot.docs.isNotEmpty) {
  //     return snapshot.docs.first.id;
  //   }
  //   return '';
  // }

  Future<void> addCat(CategorieModel categorie) async {
    try {
      await categorie.add();
      final list = await CategorieModel.getList;

      setState(() {
        categoryList = list;
        categoryCount = categoryList.length;
      });
    } catch (e) {
      print("Erreur lors de l'ajout de la catégorie : $e");
    }
  }

// Supprimer la category de la collection
  Future<void> deleteCat(CategorieModel categorie) async {
    await categorie.delete();
    final list = await CategorieModel.getList;

    setState(() {
      categoryList = list;
      categoryCount = categoryList.length; // Mettre à jour le nombre
    });
  }

  //update la category
  // Future<void> updateCat(String categoryId, String newNom,
  //     String newDescription, String? newBudgetId) async {
  //   try {
  //     DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
  //         .collection('categorie')
  //         .doc(categoryId)
  //         .get();

  //     if (docSnapshot.exists) {
  //       await FirebaseFirestore.instance
  //           .collection('categorie')
  //           .doc(categoryId)
  //           .update({
  //         'nom': newNom,
  //         'description': newDescription,
  //         if (newBudgetId != null)
  //           'budgetId': newBudgetId,
  //       });

  //       setState(() {
  //         int index = categoryList
  //             .indexWhere((category) => category['id'] == categoryId);
  //         if (index != -1) {
  //           categoryList[index]['nom'] = newNom;
  //           categoryList[index]['description'] = newDescription;
  //           if (newBudgetId != null) {
  //             categoryList[index]['budgetId'] =
  //                 newBudgetId;
  //           }
  //         }
  //       });
  //     } else {
  //       throw FirebaseException(
  //           plugin: 'cloud_firestore',
  //           message: 'Le document avec ID $categoryId n\'existe pas.',
  //           code: 'not-found');
  //     }
  //   } catch (e) {
  //     print('Erreur lors de la mise à jour de la catégorie : $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Erreur : $e')),
  //     );
  //   }
  // }

  User? user = FirebaseAuth.instance.currentUser;

  //formulaire pour update un revenu
  void _showUpdateFormDialog(BuildContext context, CategorieModel categorie) {
    TextEditingController nomController =
        TextEditingController(text: categorie.nom);
    TextEditingController descriptionController =
        TextEditingController(text: categorie.description);

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
                await addCat(categorie
                  ..nom = nomController.text
                  ..description = descriptionController.text);

                Navigator.of(context).pop();

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
                  String nom = _nomCat.text;
                  String description = _descriptionCat.text;

                  User? user = FirebaseAuth.instance.currentUser;
                  String userId = user!.uid;

                  // String budgetId = await getUserBudgetId(userId);
                  final categorie = CategorieModel.avecParametre(
                      id: generateID(),
                      description: description,
                      userId: userId,
                      nom: nom);

                  if (userId.isNotEmpty) {
                    await addCat(categorie);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Catégorie ajoutée avec succès !')),
                    );

                    _nomCat.clear();
                    _descriptionCat.clear();

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

  Future<void> addCategoryToFirestore(CategorieModel categorie) async =>
      addCat(categorie);

  int categoryCountInterne = 0;

  Future<void> fetchCategories() async {
    try {
      var snapshot = await CategorieModel.getList;

      setState(() {
        categoryList = snapshot;
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
                height: 320,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: staticCategories.length,
                  itemBuilder: (context, int index) {
                    var category = staticCategories[index];

                    // Vérifier si la catégorie est déjà ajoutée
                    bool isCategoryAdded =
                        categoryList.any((cat) => cat.nom == category['nom']);

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
                                        final cate =
                                            CategorieModel.avecParametre(
                                                id: generateID(),
                                                description:
                                                    category['description'],
                                                userId: user?.uid ?? '',
                                                nom: category['nom']);
                                        await addCategoryToFirestore(cate);
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
                                                    cat.nom == category['nom']);
                                            await deleteCat(addedCategory);
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
                                                    cat.nom == category['nom']);
                                            _showUpdateFormDialog(
                                              context,
                                              addedCategory,
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
