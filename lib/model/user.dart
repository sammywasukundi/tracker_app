import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase/firebase_service.dart';

class UserModel {
  String id = '';
  String email = '';
  String password = '';
  String profile = '';
  String fName = '';
  String lName = '';
  DateTime createAt = DateTime.now();

  UserModel();
  UserModel.avecParametre({
    required this.id,
    required this.email,
    required this.password,
    required this.profile,
    required this.fName,
    required this.lName,
    required this.createAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'password': password,
        'profile': profile,
        'fName': fName,
        'lName': lName,
        'createAt': createAt,
      };

  factory UserModel.fromMap(Map<String, dynamic> data) =>
      UserModel.avecParametre(
          id: data['id'],
          email: data['email'],
          password: data['password'],
          profile: data['profile'],
          fName: data['fName'],
          lName: data['pName'],
          createAt: (data['createAt'] as Timestamp).toDate());

  static const collection = 'userCollection';
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

  static Future<List<UserModel>> get getList async {
    return (await FirebaseService.service.fetch(collection)).map(
      (e) {
        return UserModel.fromMap(e);
      },
    ).toList();
  }
}
