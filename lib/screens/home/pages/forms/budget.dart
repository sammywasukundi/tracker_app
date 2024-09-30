// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/screens/home/home_page.dart';
import 'package:tracker_app/screens/home/pages/forms/category.dart';

class FormBudget extends StatefulWidget {
  const FormBudget({super.key});

  @override
  State<FormBudget> createState() => _FormBudgetState();
}

class _FormBudgetState extends State<FormBudget> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _dateDebut;
  DateTime? _dateFin;
  final _montant = TextEditingController();
  final _nomBudget = TextEditingController();
  final _descriptionBudget = TextEditingController();

  List<Map<String, dynamic>> budgets = [];
  bool _isBudgetListVisible = true; // To toggle budget list visibility
  

  @override
  void initState() {
    super.initState();
    fetchBudgets();
  }

  Future<void> fetchBudgets() async {
    try {
      // Obtenez l'utilisateur actuellement connecté
      User? user = FirebaseAuth.instance.currentUser;

      // Vérifiez si l'utilisateur est connecté
      if (user != null) {
        String userId = user.uid; // Récupérer l'ID de l'utilisateur

        // Fetch documents from the Firestore collection 'budget' where 'userId' matches the logged-in user
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('budget')
            .where('userId', isEqualTo: userId) // Filtrer par 'userId'
            .get();

        // Vérifier si des documents existent dans la collection
        if (snapshot.docs.isNotEmpty) {
          // Mettre à jour l'état avec la liste des budgets
          setState(() {
            budgets = snapshot.docs.map((doc) {
              return {
                'id': doc.id, // Inclure l'ID du document
                'nomBudget': doc['nomBudget'] ??
                    'Sans nom', // Gérer les champs manquants
                'descriptionBudget':
                    doc['descriptionBudget'] ?? 'Sans description',
              };
            }).toList();
          });
        } else {
          // Gérer le cas où aucun document n'est trouvé
          setState(() {
            budgets = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Aucun budget trouvé pour cet utilisateur.')),
          );
        }
      } else {
        // L'utilisateur n'est pas connecté
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non connecté.')),
        );
      }
    } catch (e) {
      // Gérer les erreurs lors du processus de récupération
      print('Erreur lors de la récupération des budgets : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des budgets.')),
      );
    }
  }

  Future<void> addBudgetWithUserReference(
      String userId,
      DateTime dateDebut,
      DateTime dateFin,
      int montant,
      String nomBudget,
      String descriptionBudget,
      List<String> revenusIds, // Liste d'ID des revenus liés à ce budget
      List<String> categoriesIds // Liste d'ID des catégories liées à ce budget
      ) async {
    try {
      // Création de la collection et ajout du document
      await FirebaseFirestore.instance.collection('budget').add({
        'userId': userId, // Référence à l'utilisateur
        'dateDebut': dateDebut,
        'dateFin': dateFin,
        'montant': montant,
        'nomBudget': nomBudget,
        'descriptionBudget': descriptionBudget,
        'revenus': revenusIds, // Liste d'ID des revenus associés
        'categories': categoriesIds, // Liste d'ID des catégories associées
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Budget ajouté avec succès !");
    } catch (e) {
      print("Erreur lors de l'ajout du budget : $e");
    }
  }

  // Méthode pour afficher le DatePicker et sélectionner la date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime?) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        onDateSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
        //centerTitle: true,
        title: Text(
          'Nouveau budget',
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                // Champ DateDebut
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Date de début',
                          hintStyle: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w300),
                          suffixIcon: Icon(
                            Icons.calendar_month,
                            color: Colors.grey,
                          )),
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, _dateDebut, (selectedDate) {
                        _dateDebut = selectedDate;
                      }),
                      validator: (value) {
                        if (_dateDebut == null) {
                          return 'Veuillez sélectionner la date de début';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                          text: _dateDebut == null
                              ? ''
                              : '${_dateDebut!.day}/${_dateDebut!.month}/${_dateDebut!.year}'),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Champ DateFin
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Date de fin',
                          hintStyle: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w300),
                          suffixIcon: Icon(
                            Icons.calendar_month,
                            color: Colors.grey,
                          )),
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, _dateFin, (selectedDate) {
                        _dateFin = selectedDate;
                      }),
                      validator: (value) {
                        if (_dateFin == null) {
                          return 'Veuillez sélectionner la date de fin';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                          text: _dateFin == null
                              ? ''
                              : '${_dateFin!.day}/${_dateFin!.month}/${_dateFin!.year}'),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          controller: _montant,
                          keyboardType:
                              TextInputType.number, // Clavier numérique
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter
                                .digitsOnly, // Filtrer pour n'accepter que les chiffres
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Montant',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                            suffixIcon: Icon(
                              Icons.money,
                              color: Colors.grey,
                            ), // Icône de montant en suffixe
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Montant requis'
                              : null,
                        ))),
                SizedBox(height: 15),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          controller: _nomBudget,
                          keyboardType: TextInputType.text, // Clavier numérique
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nom d\'affichage du budget',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Nom d\'affichage du budget requis'
                              : null,
                        ))),
                SizedBox(height: 15),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          controller: _descriptionBudget,
                          keyboardType: TextInputType.text, // Clavier numérique
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Description',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ))),
                SizedBox(
                  height: 15,
                ),
                // Bouton de soumission

                Row(
                  children: [
                    // Espace vide pour la moitié gauche de l'écran
                    Expanded(
                      child: Container(),
                    ),

                    // Le bouton à droite
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            // Récupérer l'utilisateur connecté
                            User? user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              // Récupérer le userId (uid de l'utilisateur authentifié)
                              String userId = user.uid;
                              List<String> revenusIds = [
                                'revenuId1',
                                'revenuId2'
                              ];
                              List<String> categoriesIds = [
                                'categorieId1',
                                'categorieId2'
                              ];

                              // Ajouter le budget dans Firestore avec le userId
                              await addBudgetWithUserReference(
                                  userId, // Passer le userId ici
                                  _dateDebut!,
                                  _dateFin!,
                                  int.parse(_montant.text),
                                  _nomBudget.text,
                                  _descriptionBudget.text,
                                  revenusIds,
                                  categoriesIds);

                              // Afficher un message de validation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Formulaire validé et budget ajouté !')),
                              );

                              //_dateDebut.clear();
                              //_dateFin.clear();
                              _montant.clear();
                              _nomBudget.clear();
                              _descriptionBudget.clear();

                              // Naviguer vers la page des catégories
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryScreen(),
                                ),
                              );
                            } else {
                              // L'utilisateur n'est pas authentifié
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Utilisateur non connecté')),
                              );
                            }
                          } catch (e) {
                            // Gérer les erreurs
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur : $e')),
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Créer le budget',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Ajout de la liste des budgets
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mes budgets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        // Bouton pour trier les budgets
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.sort,
                            color: Colors.blueAccent,
                          ),
                          onSelected: (String value) {
                            setState(() {
                              if (value == 'Nom (A-Z)') {
                                budgets.sort((a, b) {
                                  String nomA = a['nomBudget'] ??
                                      ''; // Valeur par défaut si null
                                  String nomB = b['nomBudget'] ?? '';
                                  return nomA.compareTo(nomB);
                                });
                              } else if (value == 'Nom (Z-A)') {
                                budgets.sort((a, b) {
                                  String nomA = a['nomBudget'] ??
                                      ''; // Valeur par défaut si null
                                  String nomB = b['nomBudget'] ?? '';
                                  return nomB.compareTo(nomA);
                                });
                              } else if (value == 'Date croissante') {
                                budgets.sort((a, b) {
                                  DateTime? dateA = a['dateDebut'] != null
                                      ? (a['dateDebut'] as Timestamp).toDate()
                                      : null;
                                  DateTime? dateB = b['dateDebut'] != null
                                      ? (b['dateDebut'] as Timestamp).toDate()
                                      : null;

                                  if (dateA == null)
                                    return 1; // Place les budgets sans date en dernier
                                  if (dateB == null) return -1;
                                  return dateA.compareTo(dateB);
                                });
                              } else if (value == 'Date décroissante') {
                                budgets.sort((a, b) {
                                  DateTime? dateA = a['dateDebut'] != null
                                      ? (a['dateDebut'] as Timestamp).toDate()
                                      : null;
                                  DateTime? dateB = b['dateDebut'] != null
                                      ? (b['dateDebut'] as Timestamp).toDate()
                                      : null;

                                  if (dateA == null)
                                    return 1; // Place les budgets sans date en dernier
                                  if (dateB == null) return -1;
                                  return dateB.compareTo(dateA);
                                });
                              } else if (value == 'Durée') {
                                budgets.sort((a, b) {
                                  DateTime? dateDebutA = a['dateDebut'] != null
                                      ? (a['dateDebut'] as Timestamp).toDate()
                                      : null;
                                  DateTime? dateFinA = a['dateFin'] != null
                                      ? (a['dateFin'] as Timestamp).toDate()
                                      : null;
                                  DateTime? dateDebutB = b['dateDebut'] != null
                                      ? (b['dateDebut'] as Timestamp).toDate()
                                      : null;
                                  DateTime? dateFinB = b['dateFin'] != null
                                      ? (b['dateFin'] as Timestamp).toDate()
                                      : null;

                                  if (dateDebutA == null || dateFinA == null)
                                    return 1; // Ignore si pas de dates
                                  if (dateDebutB == null || dateFinB == null)
                                    return -1;

                                  int dureeA =
                                      dateFinA.difference(dateDebutA).inDays;
                                  int dureeB =
                                      dateFinB.difference(dateDebutB).inDays;
                                  return dureeA.compareTo(dureeB);
                                });
                              }
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                value: 'Nom (A-Z)',
                                child: Text('Nom (A-Z)'),
                              ),
                              PopupMenuItem(
                                value: 'Nom (Z-A)',
                                child: Text('Nom (Z-A)'),
                              ),
                              PopupMenuItem(
                                value: 'Date croissante',
                                child: Text('Date croissante'),
                              ),
                              PopupMenuItem(
                                value: 'Date décroissante',
                                child: Text('Date décroissante'),
                              ),
                              PopupMenuItem(
                                value: 'Durée',
                                child: Text('Durée'),
                              ),
                            ];
                          },
                        ),
                        // Bouton pour afficher ou cacher la liste des budgets
                        IconButton(
                          icon: Icon(
                            _isBudgetListVisible
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              _isBudgetListVisible = !_isBudgetListVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // Budget List
                _isBudgetListVisible
                    ? budgets.isNotEmpty
                        ? Container(
                            height: 210, // Ajuster la hauteur selon les besoins
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: ListView.builder(
                                itemCount: budgets.length,
                                itemBuilder: (context, index) {
                                  final budget = budgets[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        ), // Réduire la marge verticale et ajouter une marge horizontale
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          4.0), // Bordure arrondie
                                      side: BorderSide(
                                          color: Colors.transparent,
                                          width:
                                              2.0), // Couleur et largeur de la bordure
                                    ),
                                    color: Colors
                                        .grey[100], // Couleur de fond du card
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal:
                                            12.0, // Diminuer le padding horizontal
                                        vertical:
                                            8.0, // Diminuer le padding vertical
                                      ),
                                      title: Text(
                                        budget['nomBudget'] ??
                                            'Nom non disponible',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize:
                                              16.0, // Diminuer la taille du texte
                                          color: Colors
                                              .black87, // Couleur du texte
                                        ),
                                      ),
                                      subtitle: Text(
                                        budget['descriptionBudget'] ??
                                            'Pas de description',
                                        style: TextStyle(
                                          fontSize:
                                              14.0, // Diminuer la taille du sous-titre
                                          color: Colors.grey[
                                              700], // Couleur du sous-titre
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.arrow_forward,
                                            color: Colors.blueAccent,
                                            size: 20.0), // Icone plus petit
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomePage(
                                                  budgetId: budget['id']),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(Icons
                                .hourglass_empty)) // Afficher si la liste est vide
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
