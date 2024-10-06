// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

//import 'package:expense_tracker/data/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // final double? totalBudget;
  // final double? totalIncome;
  // final double? totalExpenses;

  // MainScreen({
  //   Key? key,
  //   this.totalBudget,
  //   this.totalIncome,
  //   this.totalExpenses,
  // }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String budgetId; // ID du budget à récupérer
  Map<String, dynamic> budget = {};

  Future<void> fetchBudgetAmount(String budgetId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        //String userId = user.uid;

        // Récupérer le budget basé sur l'ID de budget spécifié
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('budget')
            .doc(budgetId) // Utilisation de l'ID du budget
            .get();

        if (snapshot.exists) {
          setState(() {
            budget = snapshot.data()
                as Map<String, dynamic>; // Récupérer les données du document
          });
        } else {
          // Aucune entrée trouvée
          setState(() {
            budget = {
              'montant': 0
            }; // Valeur par défaut si aucun budget n'est trouvé
          });
        }
      } else {
        // Utilisateur non connecté
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

  @override
  void initState() {
    super.initState();

    // Initialisez budgetId avec l'ID du budget que vous voulez récupérer
    //budgetId = 'votre_budget_id'; // Remplacez par l'ID réel
    fetchBudgetAmount(budgetId); // Passez l'ID du budget
  }

  void onBudgetSelected(String budgetId) {
    fetchBudgetAmount(budgetId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 142, 163, 199),
                    Color.fromARGB(255, 107, 149, 221),
                    Color.fromARGB(255, 162, 187, 231),
                  ],
                  transform: GradientRotation(pi / 4),
                ),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.grey.shade300,
                    offset: const Offset(5, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Budget total',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$ ${budget['montant']?.toStringAsFixed(2) ?? 'Montant non disponible'}', // Utiliser la variable 'budget' pour afficher le montant
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: const BoxDecoration(
                                color: Colors.white30,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.arrow_down,
                                  size: 12,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Revenus',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  //'\$ ${widget.totalIncome?.toStringAsFixed(2) ?? '0.00'}',
                                  'okay',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: const BoxDecoration(
                                color: Colors.white30,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.arrow_up,
                                  size: 12,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dépenses',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  //'\$ ${widget.totalExpenses?.toStringAsFixed(2) ?? '0.00'}',
                                  'ok',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: budget.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        'Budget ${budget[index]['id']}'), // Afficher l'ID ou un autre détail
                    subtitle: Text(
                        'Montant: \$${budget[index]['montant'].toStringAsFixed(2)}'), // Afficher le montant
                    onTap: () => onBudgetSelected(
                        budget[index]['id']), // Sélectionner le budget
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
