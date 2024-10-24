// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:tracker_app/screens/home/home_page.dart';

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

  late String
      budgetId; // ID du budget actuel auquel les dépenses et catégories sont liées

  List<Map<String, dynamic>> expenseList = [];
  int expenseCount = 0;

  String? userId; // Make userId nullable to avoid initialization issues

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<List<Map<String, dynamic>>> fetchExpenses(String userId) async {
    print("Fetching expenses for userId: $userId");

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('depense')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) {
      print("Aucune dépense trouvée pour cet utilisateur.");
    } else {
      print("Dépenses trouvées: ${snapshot.docs.length}");
    }

    return snapshot.docs.map((doc) {
      final expenseData = {
        'id': doc.id,
        'categoryName': doc['categoryName'] ?? 'Sans nom',
        'montant': doc['montant'] ?? 0,
        'dateDepense': (doc['dateDepense'] as Timestamp).toDate(),
      };
      print(
          "Dépense trouvée: $expenseData"); // Ajoutez cette ligne pour déboguer
      return expenseData;
    }).toList();
  }

  String?
      selectedBudgetId; // Déclarez cette variable au niveau de l'état de votre widget

  Future<void> addExpense(
      String categoryId,
      String categoryName,
      String montant,
      String description,
      DateTime dateDepense,
      String userId,
      String budgetId) async {
    // Ajout du paramètre budgetId
    try {
      // Référence à la collection des dépenses dans Firestore
      CollectionReference expensesRef =
          FirebaseFirestore.instance.collection('depense');

      // Ajouter une nouvelle dépense dans Firestore
      await expensesRef.add({
        'userId': userId, // ID de l'utilisateur actuel
        'categoryId': categoryId, // ID de la catégorie sélectionnée
        'categoryName':
            categoryName, // Nom de la catégorie pour affichage rapide
        'montant': double.parse(montant), // Montant de la dépense
        'description': description, // Description de la dépense
        'dateDepense': dateDepense, // Date de la dépense
        'budgetId': budgetId, // Ajout du champ budgetId
        'createdAt': FieldValue.serverTimestamp(), // Timestamp de création
      });

      print("Dépense ajoutée avec succès !");
    } catch (e) {
      print("Erreur lors de l'ajout de la dépense : $e");
    }

    // Charger les dépenses après ajout (si besoin)
    await _loadExpenses();
  }

  // Fonction pour supprimer la dépense
  Future<void> deleteExpense(String expenseId) async {
    try {
      // Référence à la dépense à supprimer
      DocumentReference expenseRef =
          FirebaseFirestore.instance.collection('depense').doc(expenseId);

      // Supprimer la dépense
      await expenseRef.delete();

      print("Dépense supprimée avec succès !");
    } catch (e) {
      print("Erreur lors de la suppression de la dépense : $e");
    }
  }

// Fonction pour afficher un dialogue de mise à jour
  void _showUpdateExpenseDialog(
      BuildContext context,
      String expenseId,
      String currentCategoryId,
      String currentCategoryName,
      double currentMontant,
      String currentDescription,
      DateTime currentDate,
      String currentBudgetId) {
    TextEditingController montantController =
        TextEditingController(text: currentMontant.toString());
    TextEditingController descriptionController =
        TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mettre à jour la dépense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: montantController,
                decoration: InputDecoration(labelText: 'Montant'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              // Ajouter un sélecteur pour la catégorie et le budget si nécessaire
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                // Appel de la fonction de mise à jour
                await updateExpense(
                  expenseId,
                  currentCategoryId,
                  currentCategoryName,
                  montantController.text,
                  descriptionController.text,
                  currentDate, // Ou un nouveau date sélectionnée si nécessaire
                  currentBudgetId,
                );
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateExpense(
      String expenseId,
      String categoryId,
      String categoryName,
      String montant,
      String description,
      DateTime dateDepense,
      String budgetId) async {
    try {
      // Référence à la dépense à mettre à jour
      DocumentReference expenseRef =
          FirebaseFirestore.instance.collection('depense').doc(expenseId);

      // Mettre à jour les champs de la dépense
      await expenseRef.update({
        'categoryId': categoryId,
        'categoryName': categoryName,
        'montant': double.parse(montant),
        'description': description,
        'dateDepense': dateDepense,
        'budgetId': budgetId,
        'updatedAt': FieldValue
            .serverTimestamp(), // Optionnel : ajouter un timestamp de mise à jour
      });

      print("Dépense mise à jour avec succès !");
    } catch (e) {
      print("Erreur lors de la mise à jour de la dépense : $e");
    }
  }

  Future<void> _loadExpenses() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('depense')
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        expenseList = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Erreur lors du chargement des dépenses : $e");
    }
  }

  // Fonction pour récupérer l'ID du budget et les catégories liées
  Future<List<Map<String, dynamic>>> fetchAllCategories() async {
    try {
      // Récupérer l'utilisateur actuellement connecté
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Référence à la collection des catégories
      CollectionReference<Map<String, dynamic>> categoriesRef =
          FirebaseFirestore.instance.collection('categorie');

      QuerySnapshot<Map<String, dynamic>> categoriesSnapshot;

      if (currentUser != null) {
        // Si l'utilisateur est connecté, récupérer uniquement les catégories liées à son ID
        categoriesSnapshot = await categoriesRef
            .where('userId', isEqualTo: currentUser.uid)
            .get();
      } else {
        // Si aucun utilisateur n'est connecté, récupérer toutes les catégories
        categoriesSnapshot = await categoriesRef.get();
      }

      // Convertir les catégories en liste de Map
      List<Map<String, dynamic>> categories =
          categoriesSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nom': doc['nom'] ?? 'Sans nom', // Nom avec valeur par défaut si null
          'description': doc['description'] ?? '', // Description facultative
        };
      }).toList();

      return categories; // Retourner la liste des catégories
    } catch (e) {
      print("Erreur lors de la récupération des catégories : $e");
      throw Exception("Erreur de récupération des catégories");
    }
  }

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

  void _showExpenseFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
            title: Text('Ajouter une dépense'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Sélection de la catégorie
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchAllCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: Colors.blueAccent[200],
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('Erreur de chargement des catégories');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('Aucune catégorie disponible');
                      }

                      final List<Map<String, dynamic>> categories =
                          snapshot.data!;

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'], // ID de la catégorie
                            child: Text(category['nom']), // Nom de la catégorie
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            categoryId = value;
                            categoryName = categories
                                .firstWhere((cat) => cat['id'] == value)['nom'];
                          });
                        },
                        validator: (val) => val == null
                            ? 'Veuillez sélectionner une catégorie'
                            : null,
                      );
                    },
                  ),

                  SizedBox(height: 10),

                  // Sélection du budget
                  FutureBuilder<void>(
                    future: fetchBudgets(), // Récupérer les budgets
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: Colors.blueAccent[200],
                        );
                      }
                      if (budgets.isEmpty) {
                        return Text('Aucun budget disponible');
                      }

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Budget',
                          border: OutlineInputBorder(),
                        ),
                        items: budgets.map((budgetDoc) {
                          Map<String, dynamic> budgetData = budgetDoc.data();
                          return DropdownMenuItem<String>(
                            value: budgetDoc.id,
                            child: Text(budgetData['nomBudget']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBudgetId = value;
                          });
                        },
                        validator: (val) => val == null
                            ? 'Veuillez sélectionner un budget'
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
                    User? user = FirebaseAuth.instance.currentUser;
                    String userId = user!.uid;

                    if (userId.isNotEmpty &&
                        categoryId != null &&
                        selectedBudgetId != null) {
                      // Appel de la fonction pour ajouter la dépense
                      await addExpense(
                          categoryId!,
                          nom,
                          montant,
                          description,
                          date,
                          userId,
                          selectedBudgetId!); // Inclure l'ID du budget sélectionné

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Dépense ajoutée avec succès !')),
                        );
                        _montantDepenseController.clear();
                        _descriptionDepenseController.clear();
                        Navigator.of(context).pop();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Veuillez vous connecter, sélectionner une catégorie et un budget.')),
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

  void _sortExpenses(String criterion) {
    setState(() {
      if (criterion == 'alphabetical') {
        expenseList.sort((a, b) =>
            (a['categoryName'] ?? '').compareTo(b['categoryName'] ?? ''));
      } else if (criterion == 'montant_asc') {
        expenseList
            .sort((a, b) => (a['montant'] ?? 0).compareTo(b['montant'] ?? 0));
      } else if (criterion == 'montant_desc') {
        expenseList
            .sort((a, b) => (b['montant'] ?? 0).compareTo(a['montant'] ?? 0));
      } else if (criterion == 'date') {
        expenseList.sort((a, b) => (b['dateDepense'] as DateTime)
            .compareTo(a['dateDepense'] as DateTime));
      }
    });
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
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Colors.blueAccent,
                            size: 28,
                          ),
                          onPressed: () {
                            // Action pour ajouter une nouvelle dépense
                            _showExpenseFormDialog(context);
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            _sortExpenses(value); // Appel de la fonction de tri
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'alphabetical',
                              child: Text('Trier par nom (A-Z)'),
                            ),
                            PopupMenuItem(
                              value: 'montant_asc',
                              child: Text('Trier par montant (croissant)'),
                            ),
                            PopupMenuItem(
                              value: 'montant_desc',
                              child: Text('Trier par montant (décroissant)'),
                            ),
                            PopupMenuItem(
                              value: 'date',
                              child: Text('Trier par date d\'ajout'),
                            ),
                          ],
                          icon: Icon(Icons.sort, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Première ListView
              Expanded(
                child: ListView.builder(
                  itemCount: expenseList.length,
                  itemBuilder: (context, int index) {
                    final expense = expenseList[index];
                    String? expenseId = expense['id'];
                    print(
                        "Dépense à l'index $index: ${expense}"); // Déboguer la dépense ici

                    // Assurez-vous que l'ID n'est pas null
                    if (expense['id'] == null) {
                      print("Erreur: ID de dépense est null à l'index $index");
                    }

                    final date =
                        (expense['dateDepense'] as Timestamp?)?.toDate() ??
                            DateTime.now();
                    final formattedDate =
                        "${date.day}/${date.month}/${date.year}";

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ListTile(
                          title: Text(
                            expense['categoryName'] ?? 'Sans catégorie',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            "Montant: \$ ${expense['montant'].toStringAsFixed(2)}",
                          ),
                          leading: Text(formattedDate),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.remove, color: Colors.redAccent),
                                onPressed: () async {
                                  if (expense['id'] != null) {
                                    await deleteExpense(expense['id']);
                                    setState(
                                        () {}); // Actualiser la liste après suppression
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('ID de dépense manquant.')),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.orangeAccent),
                                onPressed: () {
                                  if (expenseId != null) {
                                    // Vérifiez si expenseId n'est pas null
                                    String currentCategoryId =
                                        expense['categoryId'];
                                    String currentCategoryName =
                                        expense['categoryName'];
                                    String currentMontant =
                                        expense['montant'].toString();
                                    String currentDescription =
                                        expense['description'];
                                    DateTime currentDate =
                                        expense['dateDepense'];
                                    String currentBudgetId =
                                        expense['budgetId'];

                                    // Appeler la fonction de mise à jour
                                    updateExpense(
                                      expenseId, // ID de la dépense à mettre à jour
                                      currentCategoryId,
                                      currentCategoryName,
                                      currentMontant,
                                      currentDescription,
                                      currentDate,
                                      currentBudgetId,
                                    );
                                  } else {
                                    print(
                                        "L'ID de la dépense est nul."); // Afficher un message d'erreur
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
