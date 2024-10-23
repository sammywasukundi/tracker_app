import 'package:budget_app/services/firebase/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  String id = '';
  DateTime dateDebut = DateTime.now();
  DateTime dateFin = DateTime.now();
  double montant = 0;
  String nomBudget = '';
  String descriptionBudget = '';
  List<String> revenusIds = [];
  List<String> categories = [];
  List<String> depense = [];
  // DateTime createdAt = ;

  BudgetModel();
  BudgetModel.avecParametre({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
    required this.montant,
    required this.nomBudget,
    required this.descriptionBudget,
    required this.revenusIds,
    required this.categories,
    required this.depense,
    // required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'dateDebut': dateDebut,
        'dateFin': dateFin,
        'montant': montant,
        'nomBudget': nomBudget,
        'descriptionBudget': descriptionBudget,
        'revenus': revenusIds,
        'categories': categories,
        'depenses': depense,
        // 'createdAt': FieldValue.serverTimestamp(),
      };

  factory BudgetModel.froMap(Map<String, dynamic> data) =>
      BudgetModel.avecParametre(
        id: data['id'],
        dateDebut: (data['dateDebut'] as Timestamp).toDate(),
        dateFin: (data['dateFin'] as Timestamp).toDate(),
        montant: double.parse(data['montant'].toString()),
        nomBudget: data['nomBudget'],
        descriptionBudget: data['descriptionBudget'],
        revenusIds: (data['revenus'] as List).cast<String>(),
        categories: (data['categories'] as List).cast<String>(),
        depense: (data['depenses'] as List).cast<String>(),
      );

  static const collection = 'budgetCollection';
  Future<bool> add() async {
    try {
      return FirebaseService.service.addOrUpdate(collection, toMap());
    } catch (e) {
      throw UnimplementedError();
    }
  }

  Future<bool> delete() async {
    try {
      return FirebaseService.service.delete(collection, id);
    } catch (e) {
      throw UnimplementedError();
    }
  }

  static Future<List<BudgetModel>> get getList async {
    return (await FirebaseService.service.fetch(collection)).map(
      (e) {
        return BudgetModel.froMap(e);
      },
    ).toList();
  }
}
