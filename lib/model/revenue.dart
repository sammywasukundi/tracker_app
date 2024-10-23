import '../services/firebase/firebase_service.dart';

class RevenueModel {
  String id = '';
  String budgetId = '';
  double montant = 0;
  String source = '';

  RevenueModel();
  RevenueModel.avecParametre(
      {required this.id,
      required this.budgetId,
      required this.montant,
      required this.source});

  Map<String, dynamic> toMap() => {
        'id': id,
        'budgetId': budgetId,
        'montant': montant,
        'source': source,
      };

  factory RevenueModel.fromMap(Map<String, dynamic> data) {
    return RevenueModel.avecParametre(
        id: data['id'],
        budgetId: data['budgetId'],
        montant: double.parse(data['montant'].toString()),
        source: data['source']);
  }

  static const collection = 'revenueCollection';
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

  static Future<List<RevenueModel>> get getList async {
    return (await FirebaseService.service.fetch(collection)).map(
      (e) {
        return RevenueModel.fromMap(e);
      },
    ).toList();
  }
}
