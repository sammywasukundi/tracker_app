// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? budgetId; // ID du budget à récupérer
  Map<String, dynamic> budget = {};
  List<Map<String, dynamic>> revenus = [];
  List<Map<String, dynamic>> depenses = [];
  bool _isIncomeListVisible = true; // To toggle budget list visibility
  bool _isLoadingIncome = true;
  bool _isExpenseListVisible = true;
  bool _isLoadingExpense = true;
  int revenusCount = 0;

  List<Map<String, dynamic>> budgets = [];

  Future<void> fetchBudgets() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('budget')
            .where('userId', isEqualTo: userId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            budgets = snapshot.docs.map((doc) {
              return {
                'id': doc.id, // ID du document dans Firestore
                'nomBudget': doc['nomBudget'] ?? 'Sans nom',
                'montant': doc['montant'] ?? 0.00, // Montant du budget
              };
            }).toList();
          });
        } else {
          setState(() {
            budgets = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Aucun budget trouvé pour cet utilisateur.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non connecté.')),
        );
      }
    } catch (e) {
      print('Erreur lors de la récupération des budgets : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des budgets.')),
      );
    }
  }

  Future<void> fetchBudgetDetails(String budgetId) async {
    try {
      if (budgetId == null || budgetId.isEmpty) {
        throw Exception('Budget ID is null or empty');
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Utilisateur connecté : ${user.uid}');

        // Récupérer le budget basé sur l'ID de budget spécifié
        DocumentSnapshot budgetSnapshot = await FirebaseFirestore.instance
            .collection('budget')
            .doc(budgetId)
            .get();

        if (budgetSnapshot.exists) {
          print('Budget trouvé : ${budgetSnapshot.data()}');
          Map<String, dynamic> budgetData =
              budgetSnapshot.data() as Map<String, dynamic>;

          // Vérification des champs du document budget
          if (!budgetData.containsKey('nomBudget') ||
              !budgetData.containsKey('montant')) {
            throw Exception("Les données du budget sont incomplètes.");
          }

          // Mettre à jour le budget avec les données récupérées
          setState(() {
            budget = {
              'nomBudget': budgetData['nomBudget'] ?? 'Sans nom',
              'montant': budgetData['montant'] ?? 0,
            };
          });

          // Récupérer les revenus liés au budget (pas besoin de vérifier l'utilisateur)
          QuerySnapshot revenusSnapshot = await FirebaseFirestore.instance
              .collection('Revenus')
              .where('budgetId', isEqualTo: budgetId)
              .get();

          List<Map<String, dynamic>> revenusList =
              revenusSnapshot.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();

          print('Revenus récupérés : $revenusList');

          // Récupérer les dépenses liées au budget (pas besoin de vérifier l'utilisateur)
          QuerySnapshot depensesSnapshot = await FirebaseFirestore.instance
              .collection('depense')
              .where('budgetId', isEqualTo: budgetId)
              .get();

          List<Map<String, dynamic>> depensesList =
              depensesSnapshot.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();

          print('Dépenses récupérées : $depensesList');

          // Mettre à jour l'état pour inclure les revenus et les dépenses récupérés
          setState(() {
            revenus = revenusList;
            depenses = depensesList;
          });
        } else {
          print('Aucun budget trouvé pour cet ID.');
          // Aucune entrée trouvée pour ce budget
          setState(() {
            budget = {
              'nomBudget': 'Sans nom',
              'montant': 0,
            };
            revenus = [];
            depenses = [];
          });
        }
      } else {
        print('Utilisateur non connecté.');
        _showSnackbar('Utilisateur non connecté.');
      }
    } catch (e) {
      print('Erreur lors de la récupération des détails du budget : $e');
      _showSnackbar('Erreur lors de la récupération des détails du budget.');
    }
  }

// Fonction pour afficher le snackbar en dehors de initState()
  void _showSnackbar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBudgets();
    String budgetId = "budgetId";

    fetchBudgetDetails(budgetId); 

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _isLoadingIncome = false;
      });
    });

    Future.delayed(
      Duration(seconds: 2),
      () {
        _isLoadingExpense = false;
      },
    );
  }

  void onBudgetSelected(String budgetId) {
    fetchBudgetDetails(budgetId);
  }

  @override
  Widget build(BuildContext context) {
    double revenusTotal =
        revenus.fold(0.0, (sum, item) => sum + item['montant']);
    double depensesTotal =
        depenses.fold(0.0, (sum, item) => sum + item['montant']);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          children: [
            // Nom du budget en haut
            Text(
              budget['nomBudget'] ?? 'Nom du budget'.toUpperCase(),
              style: GoogleFonts.roboto(
                fontSize: 18.0,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 15),

            // Montant du budget
            Text(
              'Montant total : \$ ${budget['montant']?.toStringAsFixed(2) ?? 'Montant non disponible'}',
              style: GoogleFonts.roboto(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cercle des revenus
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120, 
                          width: 120,
                          child: CircularProgressIndicator(
                            value: (budget['montant'] != null &&
                                    budget['montant'] > 0)
                                ? revenusTotal / budget['montant']
                                : 0.0, 
                            strokeWidth:
                                15, 
                            backgroundColor: Colors.white70,
                            color: Colors.greenAccent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(
                              20.0), 
                          child: Text(
                            '${(budget['montant'] != null && budget['montant'] > 0) ? ((revenusTotal / budget['montant']) * 100).toStringAsFixed(1) : '0.0'}%',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0, 
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 16), 
                    Text(
                      'Revenus : \$${revenusTotal.toStringAsFixed(2)}', 
                      style: GoogleFonts.roboto(
                        fontSize: 14.0, 
                        fontWeight: FontWeight.w300,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),

                // Cercle des dépenses
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120, 
                          width: 120,
                          child: CircularProgressIndicator(
                            value: (budget['montant'] != null &&
                                    budget['montant'] > 0)
                                ? depensesTotal / budget['montant']
                                : 0.0, 
                            strokeWidth:
                                15, 
                            backgroundColor: Colors.white70,
                            color: Colors.redAccent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(
                              20.0), 
                          child: Text(
                            '${(budget['montant'] != null && budget['montant'] > 0) ? ((depensesTotal / budget['montant']) * 100).toStringAsFixed(1) : '0.0'}%',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0, 
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 16), 
                    Text(
                      'Dépenses : \$${depensesTotal.toStringAsFixed(2)}', 
                      style: GoogleFonts.roboto(
                        fontSize: 14.0, 
                        fontWeight: FontWeight.w300,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Liste des budgets
            Expanded(
              child: budgets != null && budgets.isNotEmpty
                  ? ListView.builder(
                      itemCount: budgets.length,
                      itemBuilder: (context, index) {
                        var currentBudget = budgets[index];

                        // Vérifier si currentBudget n'est pas null
                        if (currentBudget == null || currentBudget.isEmpty) {
                          return ListTile(
                            title: Text('Budget non disponible'),
                            subtitle: Text('Montant: \$0.00'),
                          );
                        }

                        String budgetId =
                            currentBudget['nomBudget'] ?? 'ID non disponible';
                        var montant = currentBudget['montant'] != null
                            ? (currentBudget['montant'] is int
                                ? (currentBudget['montant'] as int)
                                    .toDouble()
                                : currentBudget['montant']
                                    as double) 
                            : 0.00;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ListTile(
                              title: Text('Budget $budgetId',style: GoogleFonts.roboto(fontWeight: FontWeight.w400,fontSize: 12.0),),
                              subtitle: Text(
                                  'Montant: \$${montant.toStringAsFixed(2)}',style: GoogleFonts.roboto(fontWeight: FontWeight.w200,fontSize: 12.0),),
                              onTap: () =>
                                  onBudgetSelected(currentBudget['id']),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Aucun budget trouvé.',
                        style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      ),
                    ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes revenus ',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  children: [
                    // Bouton pour afficher ou cacher la liste des budgets
                    IconButton(
                      icon: Icon(
                        _isIncomeListVisible
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _isIncomeListVisible = !_isIncomeListVisible;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            // income List
            // Revenus section
            _isIncomeListVisible
                ? revenus.isNotEmpty
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: ListView.builder(
                            itemCount: revenus.length,
                            itemBuilder: (context, int index) {
                              var revenu = revenus[index];
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Source : ${revenu['source']}',
                                              style: GoogleFonts.roboto(
                                                fontSize: 14.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Montant :\$ ${revenu['montant']}',
                                              style: GoogleFonts.roboto(
                                                fontSize: 14.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontWeight: FontWeight.w300,
                                              ),
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
                      )
                    : _isLoadingIncome
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          )
                        : Center(
                            child: Text(
                              'Aucun revenu trouvé pour ce budget',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                              ),
                            ),
                          )
                : SizedBox.shrink(),
            SizedBox(height: 15),

            // Dépenses section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes depenses ',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isExpenseListVisible
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpenseListVisible = !_isExpenseListVisible;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            // Expense List
            _isExpenseListVisible
                ? depenses.isNotEmpty
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: ListView.builder(
                            itemCount: depenses.length,
                            itemBuilder: (context, int index) {
                              var depense = depenses[index];
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Catégorie : ${depense['categoryName']}',
                                              style: GoogleFonts.roboto(
                                                fontSize: 14.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Montant : \$ ${depense['montant']}',
                                              style: GoogleFonts.roboto(
                                                fontSize: 14.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontWeight: FontWeight.w300,
                                              ),
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
                      )
                    : _isLoadingExpense
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          )
                        : Center(
                            child: Text(
                              'Aucune dépense trouvée pour ce budget',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                              ),
                            ),
                          )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
