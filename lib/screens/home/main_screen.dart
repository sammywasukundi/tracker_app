// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool _isLoadingIncome = false;
  bool _isExpenseListVisible = true;
  bool _isLoadingExpense = false;
  int revenusCount = 0;

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

          // Récupérer les revenus liés au budget
          QuerySnapshot revenusSnapshot = await FirebaseFirestore.instance
              .collection('Revenus')
              .where('budgetId', isEqualTo: budgetId)
              .where('userId',
                  isEqualTo: user.uid) // Vérifier l'utilisateur connecté
              .get();

          List<Map<String, dynamic>> revenusList =
              revenusSnapshot.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();

          print('Revenus récupérés : $revenusList');

          // Récupérer les dépenses liées au budget
          QuerySnapshot depensesSnapshot = await FirebaseFirestore.instance
              .collection('depense')
              .where('budgetId', isEqualTo: budgetId)
              .where('userId',
                  isEqualTo: user.uid) // Vérifier l'utilisateur connecté
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

    String budgetId = "budgetId";

    fetchBudgetDetails(budgetId); // Passez l'ID du budget
    //fetchRevenus(budgetId);

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _isLoadingIncome = false;
      });
    });

    Future.delayed(
      Duration(seconds: 5),
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
              budget['nomBudget'] ?? 'Nom du budget',
              style: TextStyle(
                fontSize: 20.0,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // Montant du budget
            Text(
              '\$ ${budget['montant']?.toStringAsFixed(2) ?? 'Montant non disponible'}',
              style: TextStyle(
                fontSize: 25.0,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Cercles côte à côte pour les revenus et les dépenses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cercle des revenus
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: (budget['montant'] != null &&
                                  budget['montant'] > 0)
                              ? revenusTotal / budget['montant']
                              : 0.0, // Valeur par défaut si revenusTotal ou montant est nul
                          strokeWidth: 10,
                          backgroundColor: Colors.white30,
                          color: Colors.greenAccent,
                        ),
                        Text(
                          '${(budget['montant'] != null && budget['montant'] > 0) ? ((revenusTotal / budget['montant']) * 100).toStringAsFixed(1) : '0.0'}%',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Revenus',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
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
                        CircularProgressIndicator(
                          value: (budget['montant'] != null &&
                                  budget['montant'] > 0)
                              ? depensesTotal / budget['montant']
                              : 0.0, // Valeur par défaut si depensesTotal ou montant est nul
                          strokeWidth: 10,
                          backgroundColor: Colors.white30,
                          color: Colors.redAccent,
                        ),
                        Text(
                          '${(budget['montant'] != null && budget['montant'] > 0) ? ((depensesTotal / budget['montant']) * 100).toStringAsFixed(1) : '0.0'}%',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dépenses',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // const SizedBox(height: 20),

            // // Liste des budgets
            // Expanded(
            //   child: budget != null && budget.isNotEmpty
            //       ? ListView.builder(
            //           itemCount: budget.length,
            //           itemBuilder: (context, index) {
            //             var currentBudget = budget[index];
            //             return ListTile(
            //               title: Text(
            //                   'Budget ${currentBudget['budgetId'] ?? 'ID non disponible'}'),
            //               subtitle: Text(
            //                 'Montant: \$${(currentBudget['montant'] != null) ? currentBudget['montant'].toStringAsFixed(2) : '0.00'}',
            //               ),
            //               onTap: () => onBudgetSelected(currentBudget['id']),
            //             );
            //           },
            //         )
            //       : Center(
            //           child: Text(
            //             'Aucun budget trouvé.',
            //             style: TextStyle(fontSize: 16.0, color: Colors.grey),
            //           ),
            //         ),
            // ),

            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes revenus ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
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
            // Budget List
            _isIncomeListVisible
                ? revenus.isNotEmpty
                    ? SizedBox(
                        height: 210, // Ajuster la hauteur selon les besoins
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
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
                          ))
                        : Center(
                            child: Text(
                            'Aucun revenu trouvé pour ce budget',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ))
                : SizedBox.shrink(),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes depenses ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    // Bouton pour afficher ou cacher la liste des budgets
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
            // expense List
            _isExpenseListVisible
                ? depenses.isNotEmpty
                    ? SizedBox(
                        height: 210, // Ajuster la hauteur selon les besoins
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
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
                                              'Source : ${depense['source']}',
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
                                              'Montant : ${depense['montant']} USD',
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
                          ))
                        : Center(
                            child: Text(
                            'Aucune dépense trouvée pour ce budget',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ))
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
