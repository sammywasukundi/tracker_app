// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _dateDebut;

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
          'Ajouter une dépense',
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
                          hintText: 'Date d\'ajout de la dépense',
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
                          return 'Veuillez sélectionner la date d\'ajout de la dépense';
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      keyboardType:
                          TextInputType.text, // Clavier de texte standard
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Description de la dépense', // Libellé pour décrire la dépense
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                        ),
                        suffixIcon: Icon(
                          Icons
                              .description, // Icône pour illustrer une description
                          color: Colors.grey,
                        ), // Icône de description en suffixe
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Description requise'
                          : null, // Message d'erreur si la description est vide
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
                        backgroundColor:
                            Colors.blueAccent, // Couleur de fond bleue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              4), // Petite bordure arrondie
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12), // Padding interne
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Formulaire validé !')),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Ajouter le dépense',
                          style: TextStyle(
                              color: Colors.white, // Couleur du texte
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
