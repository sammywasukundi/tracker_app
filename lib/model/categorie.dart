import '../services/firebase/firebase_service.dart';

class CategorieModel {
  String id = '';
  String description = '';
  String userId = '';
  String nom = '';

  CategorieModel();
  CategorieModel.avecParametre({
    required this.id,
    required this.description,
    required this.userId,
    required this.nom,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'userId': userId,
        'nom': nom,
      };

  factory CategorieModel.fromMap(Map<String, dynamic> data) =>
      CategorieModel.avecParametre(
        id: data['id'],
        description: data['description'],
        userId: data['userId'],
        nom: data['nom'],
      );

  static const collection = 'categorieCollection';
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

  static Future<List<CategorieModel>> get getList async {
    return (await FirebaseService.service.fetch(collection)).map(
      (e) {
        return CategorieModel.fromMap(e);
      },
    ).toList();
  }
}
