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

// Remplacez par l'ID de votre budget actuel
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

  Future<void> _loadExpenses() async {
    // Assurez-vous que userId est bien défini
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Récupérer les dépenses si l'utilisateur est connecté
      List<Map<String, dynamic>> fetchedExpenses = await fetchExpenses(userId);
      setState(() {
        expenseList = fetchedExpenses;
        expenseCount = expenseList.length;
      });
    } else {
      // Gérer le cas où l'utilisateur n'est pas connecté ou que userId est nul
      print(
          "L'utilisateur n'est pas connecté ou l'ID utilisateur est introuvable.");
    }
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
      print(
          "Dépense trouvée: ${doc.data()}"); // Ajoutez cette ligne pour déboguer
      return {
        'id': doc.id,
        'categoryName': doc['categoryName'] ?? 'Sans nom',
        'montant': doc['montant'] ?? 0,
        'dateDepense': (doc['dateDepense'] as Timestamp).toDate(),
      };
    }).toList();
  }

  Future<void> addExpense(
      String categoryId,
      String categoryName,
      String montant,
      String description,
      DateTime dateDepense,
      String userId) async {
    try {
      // Récupérer l'ID du budget lié à l'utilisateur
      QuerySnapshot<Map<String, dynamic>> budgetSnapshot =
          await FirebaseFirestore.instance
              .collection('budget')
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

      if (budgetSnapshot.docs.isEmpty) {
        print("Aucun budget trouvé pour l'utilisateur");
        return; // Arrêter la fonction si aucun budget n'est trouvé
      }

      // Obtenir le document du budget
      var budgetDoc = budgetSnapshot.docs.first;
      String budgetId = budgetDoc.id;
      DateTime dateDebut = (budgetDoc['dateDebut'] as Timestamp).toDate();
      DateTime dateFin = (budgetDoc['dateFin'] as Timestamp).toDate();

      // Vérifier que la date de la dépense est incluse dans la période du budget
      if (dateDepense.isBefore(dateDebut) || dateDepense.isAfter(dateFin)) {
        print(
            "La date de la dépense n'est pas incluse dans la période du budget.");
        return; // Arrêter la fonction si la date de dépense ne correspond pas
      }

      // Référence à la collection des dépenses dans Firestore
      CollectionReference expensesRef =
          FirebaseFirestore.instance.collection('depense');

      // Ajouter une nouvelle dépense dans Firestore
      await expensesRef.add({
        'userId': userId, // ID de l'utilisateur actuel
        'budgetId': budgetId, // ID du budget lié à la dépense
        'categoryId': categoryId, // ID de la catégorie sélectionnée
        'categoryName':
            categoryName, // Nom de la catégorie pour affichage rapide
        'montant': double.parse(montant), // Montant de la dépense
        'description': description, // Description de la dépense
        'dateDepense': dateDepense, // Date de la dépense
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
  Future<void> _deleteExpense(String expenseId) async {
    await FirebaseFirestore.instance
        .collection('depense')
        .doc(expenseId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dépense supprimée avec succès !')),
    );
    await _loadExpenses();
  }

// Fonction pour afficher un dialogue de mise à jour
  void _showUpdateDialog(Map<String, dynamic> expense) {
    TextEditingController montantController =
        TextEditingController(text: expense['montant'].toString());
    TextEditingController descriptionController =
        TextEditingController(text: expense['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          title: Center(
              child: Text(
            'Mettre à jour la dépense',
            style: TextStyle(fontWeight: FontWeight.w400),
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: montantController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Montant'),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
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
                await _updateExpense(
                    expense['id'],
                    double.parse(montantController.text),
                    descriptionController.text);
                Navigator.of(context).pop();
                setState(() {}); // Rafraîchir la liste après mise à jour
              },
              child: Text(
                'Mettre à jour',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour mettre à jour la dépense
  Future<void> _updateExpense(
      String expenseId, double montant, String description) async {
    await FirebaseFirestore.instance
        .collection('depense')
        .doc(expenseId)
        .update({
      'montant': montant,
      'description': description,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dépense mise à jour avec succès !')),
    );
  }

  // Fonction pour récupérer l'ID du budget et les catégories liées
  Future<List<Map<String, dynamic>>> fetchUserBudgetAndCategories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return []; // Retourner une liste vide si l'utilisateur n'est pas connecté
    }

    // Récupérer l'ID du budget de l'utilisateur
    QuerySnapshot<Map<String, dynamic>> budgetSnapshot = await FirebaseFirestore
        .instance
        .collection('budget')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (budgetSnapshot.docs.isEmpty) {
      return []; // Retourner une liste vide si aucun budget n'est trouvé
    }

    // Obtenir le premier document du snapshot
    QueryDocumentSnapshot<Map<String, dynamic>> budgetDoc =
        budgetSnapshot.docs.first;
    String budgetId = budgetDoc.id;

    // Récupérer les catégories associées à ce budget
    QuerySnapshot<Map<String, dynamic>> categoriesSnapshot =
        await FirebaseFirestore.instance
            .collection('categorie')
            .where('budgetId', isEqualTo: budgetId)
            .get();

    // Convertir les catégories en liste de Map
    return categoriesSnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'nom': doc['nom'],
      };
    }).toList();
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
                    future:
                        fetchUserBudgetAndCategories(), // Fonction personnalisée pour récupérer le budget et les catégories
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: Colors.blueAccent[200],
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Text('Erreur de chargement des catégories');
                      }

                      final List<Map<String, dynamic>> categories =
                          snapshot.data!;

                      if (categories.isEmpty) {
                        return Text('Aucune catégorie disponible');
                      }

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
                            categoryId =
                                value; // Assignation de l'ID de la catégorie sélectionnée
                            categoryName = categories
                                    .firstWhere((cat) => cat['id'] == value)[
                                'nom']; // Récupération du nom de la catégorie
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

                      // Assurez-vous que le widget est encore monté avant d'afficher la snackbar
                      if (mounted) {
                        // Afficher un message de succès
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Dépense ajoutée avec succès !')),
                        );

                        // Réinitialiser les champs du formulaire
                        _montantDepenseController.clear();
                        _descriptionDepenseController.clear();

                        // Fermer le formulaire
                        Navigator.of(context).pop();
                      }
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
                    final date = expense['dateDepense'] as DateTime;
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
                            expense['categoryName'],
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            "Montant: ${expense['montant'].toStringAsFixed(2)} USD",
                          ),
                          leading: Text(formattedDate),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.remove, color: Colors.redAccent),
                                onPressed: () async {
                                  await _deleteExpense(expense['id']);
                                  setState(
                                      () {}); // Actualiser la liste après suppression
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.orangeAccent),
                                onPressed: () {
                                  _showUpdateDialog(expense);
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
