// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'dart:convert'; // Pour utf8.encode et base64Encode/base64Decode
import 'dart:typed_data'; // Pour Uint8List
import 'package:pointycastle/export.dart' as pc;
import 'package:encrypt/encrypt.dart' as encrypt;

// Clé de 24 caractères (192 bits) pour 3DES
final key = encrypt.Key.fromUtf8('abcdefghijklmnopqrstuvwx'); // 24 caractères
final iv = encrypt.IV.fromLength(8); // IV de 8 octets pour 3DES

// Fonction pour générer les paramètres de 3DES avec padding
pc.PaddedBlockCipherParameters<pc.CipherParameters, pc.CipherParameters>
    _generate3DESParams(encrypt.Key key, encrypt.IV iv) {
  return pc.PaddedBlockCipherParameters<pc.CipherParameters,
      pc.CipherParameters>(
    pc.ParametersWithIV<pc.KeyParameter>(
      pc.KeyParameter(key.bytes), // Utilisation de KeyParameter pour la clé
      iv.bytes, // IV de 8 octets
    ),
    null, // Pas de paramètres supplémentaires
  );
}

// Fonction de chiffrement 3DES
String encryptData(String data) {
  final params = _generate3DESParams(key, iv);
  final cipher = pc.PaddedBlockCipher('DESede/CBC/PKCS7')
    ..init(true, params); // true pour chiffrer

  final input =
      Uint8List.fromList(utf8.encode(data)); // Convertir le texte en octets
  final encrypted = cipher.process(input); // Chiffrement

  // Combiner l'IV et les données chiffrées
  final combined = iv.bytes + encrypted;

  return base64Encode(
      combined); // Retourner les données chiffrées encodées en Base64
}

// Fonction de déchiffrement 3DES
String decryptData(String encryptedWithIV) {
  try {
    final decoded = base64Decode(encryptedWithIV);

    print('Longueur des données décodées : ${decoded.length}'); // Debug

    // Vérifier que les données sont suffisamment longues pour contenir l'IV (8 octets) et des données chiffrées
    if (decoded.length <= 8) {
      throw RangeError('Les données sont trop courtes pour déchiffrer.');
    }

    // Extraire l'IV (les 8 premiers octets) et les données chiffrées (le reste)
    final iv = Uint8List.fromList(decoded.sublist(0, 8));
    final encryptedData = decoded.sublist(8);

    print('IV (vecteur d\'initialisation) : ${iv.length} octets'); // Debug
    print('Données chiffrées : ${encryptedData.length} octets'); // Debug

    // Générer les paramètres pour le déchiffrement
    final params = _generate3DESParams(key, encrypt.IV(iv));
    final cipher = pc.PaddedBlockCipher('DESede/CBC/PKCS7')
      ..init(false, params); // false pour déchiffrer

    // Déchiffrement des données
    final decrypted = cipher.process(encryptedData);
    return utf8.decode(decrypted); // Retourner le texte déchiffré
  } catch (e) {
    print('Erreur lors du déchiffrement : $e');
    return 'Erreur de déchiffrement';
  }
}

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  Future<List<Map<String, String>>> fetchRevenus() async {
    List<Map<String, String>> revenus = [];
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Revenus').get();

    snapshot.docs.forEach((doc) {
      revenus.add({
        'id': doc.id,
        'source': doc['source'],
      });
    });

    return revenus;
  }

  Future<void> _addTransaction({
    required String revenuId,
    required double montant,
    required String description,
    required DateTime date,
  }) async {
    try {
      // Chiffrement des données sensibles (montant et description)
      String encryptedMontant = encryptData(montant.toString());
      String encryptedDescription = encryptData(description);

      await FirebaseFirestore.instance.collection('transaction').add({
        'revenuId': revenuId,
        'montant': encryptedMontant,
        'description': encryptedDescription,
        'date': date,
        'createdAt':
            FieldValue.serverTimestamp(), // Suivre le temps de création
      });

      print('Transaction ajoutée avec succès');
    } catch (e) {
      print('Erreur lors de l\'ajout de la transaction: $e');
    }
  }

  Future<List<Map<String, String>>> fetchTransactions() async {
    List<Map<String, String>> transactions = [];

    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('transaction').get();

    for (var doc in snapshot.docs) {
      String decryptedMontant = decryptData(doc['montant']);
      String decryptedDescription = decryptData(doc['description']);
      String revenuId = doc['revenuId'];

      DocumentSnapshot revenuDoc = await FirebaseFirestore.instance
          .collection('Revenus')
          .doc(revenuId)
          .get();
      String revenuName = revenuDoc['source'];

      transactions.add({
        'montant': decryptedMontant,
        'description': decryptedDescription,
        'date': doc['date'].toDate().toString(),
        'revenu': revenuName,
      });
    }

    return transactions;
  }

  void _showTransactionDialog(
      BuildContext context, List<Map<String, String>> revenusList) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _montantController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    DateTime? _selectedDate;
    String? _selectedRevenuId;

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            title: Text('Ajouter une transaction'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // DropdownButton pour choisir parmi les revenus avec ID
                  DropdownButtonFormField<String>(
                    value: _selectedRevenuId,
                    decoration: InputDecoration(
                      labelText: 'Sélectionner un revenu',
                      border: OutlineInputBorder(),
                    ),
                    items: revenusList.map<DropdownMenuItem<String>>(
                      (Map<String, String> revenu) {
                        return DropdownMenuItem<String>(
                          value: revenu['id'],
                          // Utilise une valeur par défaut si 'source' est null
                          child: Text(revenu['source'] ??
                              'Source inconnue'), // Remplace 'source inconnue' par ce que tu juges approprié
                        );
                      },
                    ).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRevenuId = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner un revenu';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _montantController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Montant',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un montant';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Sélecteur de date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Aucune date sélectionnée'
                              : 'Date sélectionnée: ${_selectedDate!.toLocal()}'
                                  .split(' ')[0],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () {
                          _selectDate(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialogue
                },
                child: Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Veuillez sélectionner une date'),
                      ));
                      return;
                    }

                    // Appel de la fonction pour ajouter la transaction
                    _addTransaction(
                      revenuId: _selectedRevenuId!,
                      montant: double.parse(_montantController.text),
                      description: _descriptionController.text,
                      date: _selectedDate!,
                    );

                    // Fermer le dialogue après soumission
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Ajouter',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, String>>>(
        future:
            fetchTransactions(), // Appelle la fonction pour récupérer les transactions
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.blueAccent,)); // En attente des données
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: const Text(
                'De quelle manière\ncomptez-vous payer ?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            // Transactions récupérées et prêtes à être affichées
            final transactions = snapshot.data!;

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return Container(
                  margin: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10), // Ajoute de l'espace entre les éléments
                  decoration: BoxDecoration(
                    color: Colors.grey[50], // Couleur de fond
                    borderRadius: BorderRadius.circular(3.0), // Coins arrondis
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: Offset(0, 3), // Déplacement de l'ombre
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      'Montant: ${transaction['montant']} USD',
                      style: TextStyle(
                          fontWeight:
                              FontWeight.bold), // Met le montant en gras
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${transaction['description']}'),
                        SizedBox(
                            height:
                                4), // Espace entre la description et la source de revenu
                        Text(
                            'Source de revenu: ${transaction['revenu'] ?? 'Non spécifié'}'), // Source de revenu
                      ],
                    ),
                    trailing: Text(
                        'Date: ${transaction['date']}'), // Formatage de la date
                  ),
                );
              },
            );
          }
        },
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
            onPressed: () async {
              List<Map<String, String>> revenusList =
                  await fetchRevenus(); // Récupérer les revenus depuis Firestore
              _showTransactionDialog(context,
                  revenusList); // Passer la liste des revenus à la fonction
            },
            label: Text(
              'Ajouter',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.5,
                  color: Colors.white),
            ),
            icon: Icon(Icons.add, size: 24, color: Colors.white),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Positionnement en bas à droite
    );
  }
}