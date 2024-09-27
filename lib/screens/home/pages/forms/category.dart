// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tracker_app/screens/home/home_page.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  void _showCategoryFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une catégorie'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Nom de la catégorie
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Nom de la catégorie',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                        ),
                        suffixIcon: Icon(
                          Icons.category,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Nom de la catégorie requis'
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Description de la dépense
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
                        hintText: 'Description de la catégorie',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
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
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  // Logique pour ajouter la catégorie
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Catégorie ajoutée !')),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Ajouter',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
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
                    Text(
                      'Revenu disponible',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
                  itemCount: 2,
                  itemBuilder: (context, int i) {
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
                              // Colonne pour Category expense et montant
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: () {
                                          _showCategoryFormDialog(context);
                                        },
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        'Category expense',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Montant prévus: ',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        '50 USD',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Colonne pour la date et bouton de modification
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const SizedBox(
                                      height:
                                          8), // Espace entre la date et le bouton
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.orangeAccent,
                                    ),
                                    onPressed: () {
                                      // Action de modification
                                      //_showEditDialog(context);
                                      _showCategoryFormDialog(context);
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
              // Espacement entre les deux ListViews
              SizedBox(height: 16.0), // Espace vertical entre les deux listes

              // Deuxième titre et ListView
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dépenses par catégorie',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                      onPressed: () {
                        // Action pour ajouter une dépense par catégorie
                        _showCategoryFormDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              // Deuxième ListView
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, int i) {
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
                              // Colonne pour Category expense et montant
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: () {
                                          _showCategoryFormDialog(context);
                                        },
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        'Category expense',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Montant prévus: ',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        '50 USD',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Colonne pour la date et bouton de modification
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const SizedBox(
                                      height:
                                          8), // Espace entre la date et le bouton
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.orangeAccent,
                                    ),
                                    onPressed: () {
                                      // Action de modification
                                      //_showEditDialog(context);
                                      _showCategoryFormDialog(context);
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
                MaterialPageRoute(builder: (context) => HomePage()),
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
