import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase/firebase_service.dart';

class DepenseModel {
  String id = '';
  String budgetId = '', categorieId = '', categoryName = '';
  DateTime dateDepense = DateTime.now();
  String description = '';
  double montant = 0;
  String userId = '';

  DepenseModel();
  DepenseModel.avecParametre({
    required this.id,
    required this.budgetId,
    required this.categorieId,
    required this.categoryName,
    required this.dateDepense,
    required this.description,
    required this.montant,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'budgetId': budgetId,
        'categorieId': categorieId,
        'categoryName': categoryName,
        'dateDepense': dateDepense,
        'description': description,
        'montant': montant,
        'userId': userId
      };

  factory DepenseModel.fromMap(Map<String, dynamic> data) =>
      DepenseModel.avecParametre(
          id: data['id'],
          budgetId: data['budgetId'],
          categorieId: data['categorieId'],
          categoryName: data['categoryName'],
          dateDepense: (data['dateDepense'] as Timestamp).toDate(),
          description: data['description'],
          montant: double.parse(data['montant'].toString()),
          userId: data['userId']);
  static const collection = 'depenseCollection';
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

  static Future<List<DepenseModel>> get getList async {
    return (await FirebaseService.service.fetch(collection)).map(
      (e) {
        return DepenseModel.fromMap(e);
      },
    ).toList();
  }
}
