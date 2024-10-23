import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  FirebaseService();

  static FirebaseService get service => FirebaseService();

  FirebaseFirestore get instance => FirebaseFirestore.instance;

  Future<bool> addOrUpdate(String collection, Map<String, dynamic> data) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('USER NOT CONNECTED ');
      return false;
    }
    try {
      // data.addAll({'user': user.uid});
      data['user'] = user.uid;
      await instance.collection(collection).doc(data['id']).set(data);
      return true;
    } on FirebaseException catch (e) {
      print('ECHEC D ENREGRIGREMENT $collection - ${e.message}');
      return false;
    }
  }

  Future<bool> delete(String collection, String id) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('USER NOT CONNECTED ');
      return false;
    }
    try {
      await instance.collection(collection).doc(id).delete();
      return true;
    } on FirebaseException catch (e) {
      print('ECHEC De suppression $collection - ${e.message}');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetch(String collection) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('USER NOT CONNECTED ');
      return [];
    }
    try {
      final result = await instance
          .collection(collection)
          .where('user', isEqualTo: user.uid)
          .get();
      return result.docs.map((e) => e.data()).toList();
    } on FirebaseException catch (e) {
      print('ECHEC DE RECUPERATION $collection - ${e.message}');
      return [];
    }
  }
}

String generateID() {
  const String chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();

  return String.fromCharCodes(
    Iterable.generate(
      15,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}
