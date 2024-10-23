// ignore_for_file: prefer_const_constructors

import 'package:budget_app/model/budged.dart';
import 'package:budget_app/model/categorie.dart';
import 'package:budget_app/model/depense.dart';
import 'package:budget_app/services/firebase/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:tracker_app/screens/home/home_page.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  String? categoryId;
  String? categoryName;
  DateTime? selectedDate;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _montantDepenseController =
      TextEditingController();
  final TextEditingController _descriptionDepenseController =
      TextEditingController();

  String? selectedCategory;

  //late String budgetId;

  List<DepenseModel> expenseList = [];
  int expenseCount = 0;

  String? userId;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<List<DepenseModel>> fetchExpenses() async {
    var snapshot = await DepenseModel.getList;

    if (snapshot.isEmpty) {
      print("Aucune dépense trouvée pour cet utilisateur.");
    } else {
      print("Dépenses trouvées: ${snapshot.length}");
    }

    List<DepenseModel> expenseList = snapshot;

    // Mettez à jour le nombre de dépenses après avoir construit la liste
    expenseCount = expenseList.length;
    print(
        "Total des dépenses trouvées: $expenseCount"); // Affichez le nombre total

    return expenseList; // Retournez la liste des dépenses
  }

  String? selectedBudgetId;

  Future<void> addExpense(DepenseModel depense) async {
    try {
      await depense.add();

      print("Dépense ajoutée avec succès !");
    } catch (e) {
      print("Erreur lors de l'ajout de la dépense : $e");
    }

    await _loadExpenses();
  }

  Future<void> deleteExpense(DepenseModel depense) async {
    try {
      await depense.delete();
      expenseList = await DepenseModel.getList;
      if (mounted) setState(() {});

      print("Dépense supprimée avec succès !");
    } catch (e) {
      print("Erreur lors de la suppression de la dépense : $e");
    }
  }

  void _showUpdateExpenseDialog(BuildContext context, DepenseModel depense) {
    TextEditingController montantController =
        TextEditingController(text: depense.montant.toString());
    TextEditingController descriptionController =
        TextEditingController(text: depense.description);

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
                await updateExpense(depense
                  ..montant = double.parse(montantController.text)
                  ..description = descriptionController.text);
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateExpense(DepenseModel expense) async {
    try {
      await expense.add();
      expenseList = await DepenseModel.getList;
      if (mounted) setState(() {});
      print("Dépense mise à jour avec succès !");
    } catch (e) {
      print("Erreur lors de la mise à jour de la dépense : $e");
    }
  }

  Future<void> _loadExpenses() async {
    try {
      final snapshot = await DepenseModel.getList;

      setState(() {
        expenseList = snapshot;
      });
    } catch (e) {
      print("Erreur lors du chargement des dépenses : $e");
    }
  }

  // Fonction pour récupérer l'ID du budget et les catégories liées
  Future<List<CategorieModel>> fetchAllCategories() async {
    try {
      return await CategorieModel.getList; // Retourner la liste des catégories
    } catch (e) {
      print("Erreur lors de la récupération des catégories : $e");
      throw Exception("Erreur de récupération des catégories");
    }
  }

  List<BudgetModel> budgets = [];

  Future<void> fetchBudgets() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("Aucun utilisateur connecté.");
      return;
    }

    try {
      final snapshot = await BudgetModel.getList;

      // Stocker les budgets dans la liste
      setState(() {
        budgets = snapshot;
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
                  FutureBuilder<List<CategorieModel>>(
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

                      final List<CategorieModel> categories = snapshot.data!;

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id, // ID de la catégorie
                            child: Text(category.nom), // Nom de la catégorie
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            categoryId = value;
                            categoryName = categories
                                .firstWhere((cat) => cat.id == value)
                                .nom;
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
                          return DropdownMenuItem<String>(
                            value: budgetDoc.id,
                            child: FittedBox(
                              fit: BoxFit
                                  .scaleDown, // Réduire le texte si nécessaire
                              child: Text(
                                budgetDoc.nomBudget,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                      final expense = DepenseModel.avecParametre(
                          id: generateID(),
                          budgetId: selectedBudgetId!,
                          categorieId: categoryId!,
                          categoryName: categoryName!,
                          dateDepense: date,
                          description: description,
                          montant: double.parse(montant),
                          userId: userId);
                      await addExpense(
                          expense); // Inclure l'ID du budget sélectionné

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
        expenseList.sort((a, b) => (a.categoryName).compareTo(b.categoryName));
      } else if (criterion == 'montant_asc') {
        expenseList.sort((a, b) => (a.montant).compareTo(b.montant));
      } else if (criterion == 'montant_desc') {
        expenseList.sort((a, b) => (b.montant).compareTo(a.montant));
      } else if (criterion == 'date') {
        expenseList.sort((a, b) => (b.dateDepense).compareTo(a.dateDepense));
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
                          '${expenseList.length} dépenses ajoutées',
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
                            _sortExpenses(value);
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
                    String? expenseId = expense.id;
                    print("Dépense à l'index $index: $expense");

                    final date = (expense.dateDepense);
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
                            expense.categoryName,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            "Montant: \$ ${expense.montant.toStringAsFixed(2)}",
                          ),
                          leading: Text(formattedDate),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.remove, color: Colors.redAccent),
                                onPressed: () async {
                                  await deleteExpense(expense);
                                  setState(
                                      () {}); // Actualiser la liste après suppression
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.orangeAccent),
                                onPressed: () {
                                  // Appeler la fonction de mise à jour
                                  _showUpdateExpenseDialog(context, expense);
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
