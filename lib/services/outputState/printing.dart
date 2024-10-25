// ignore_for_file: prefer_const_constructors

import 'package:budget_app/model/budged.dart';
import 'package:budget_app/model/depense.dart';
import 'package:budget_app/model/revenue.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void printBudgetDatas(BuildContext context, BudgetModel budget, userDetails,
    List<DepenseModel> depenses, List<RevenueModel> revenus) async {
  //String firstName = userDetails['firstName'] ?? 'Prénom non disponible';
  //String lastName = userDetails['lastName'] ?? 'Nom non disponible';
  //String email = userDetails['email'] ?? 'Email non disponible';

  final pdf = pw.Document();

  // Création du contenu du PDF
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête avec le nom de l'utilisateur
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Détails du Budget pour ${userDetails['firstName']} ${userDetails['lastName']}',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                  pw.SizedBox(
                    height: 8.0,
                  ),
                  pw.Text(
                    '${userDetails['email']}',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Informations générales du budget
              pw.Text('Nom du budget : ${budget.nomBudget}'.toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8.0),
              pw.Text(
                  'Montant total du budget : \$ ${budget.montant.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 8.0),
              pw.Text('Date de début : ${budget.dateDebut.toString()}',
                  style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 8.0),
              pw.Text('Date de fin : ${budget.dateFin.toString()}',
                  style: pw.TextStyle(fontSize: 18)),

              pw.SizedBox(height: 20),

              pw.Text(
                'Description du Budget :',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(budget.descriptionBudget),

              pw.SizedBox(height: 20),

              // Section des dépenses
              pw.Text(
                'Liste des Dépenses :',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Vérifier s'il y a des dépenses
              depenses.isNotEmpty
                  ? pw.ListView.builder(
                      itemCount: depenses.length,
                      itemBuilder: (context, index) {
                        final depense = depenses[index];
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 8.0),
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                                        width: 0.5, color: PdfColors.grey))),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Catégorie: ${depense.categoryName}',
                                  style: pw.TextStyle(fontSize: 14),
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  'Montant: \$ ${depense.montant.toStringAsFixed(2)}',
                                  style: pw.TextStyle(fontSize: 14),
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  'Date: ${depense.dateDepense.toString()}',
                                  style: pw.TextStyle(fontSize: 14),
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  'Description: ${depense.description}',
                                  style: pw.TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : pw.Text('Aucune dépense associée à ce budget.',
                      style: pw.TextStyle(fontSize: 14)),

              pw.SizedBox(height: 20),

              // Section des revenus
              pw.Text(
                'Liste des Revenus :',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Vérifier s'il y a des revenus
              revenus.isNotEmpty
                  ? pw.ListView.builder(
                      itemCount: revenus.length,
                      itemBuilder: (context, index) {
                        final revenu = revenus[index];
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 8.0),
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                                        width: 0.5, color: PdfColors.grey))),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Source: ${revenu.source}',
                                  style: pw.TextStyle(fontSize: 14),
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  'Montant: \$ ${revenu.montant.toStringAsFixed(2)}',
                                  style: pw.TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : pw.Text('Aucun revenu associé à ce budget.',
                      style: pw.TextStyle(fontSize: 14)),
            ],
          ),
        );
      },
    ),
  );

  // Impression ou partage du PDF
  final maCondition = await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );

  if (maCondition) {
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          title: Text('Succès'),
          content: Text('Le fichier PDF a été enregistré avec succès!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.blue),),
            ),
          ],
        );
      },
    );
  }
}
