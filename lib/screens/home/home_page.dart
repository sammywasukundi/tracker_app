import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Récupération de l'utilisateur actuel
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Affichage de l'email ou d'un texte par défaut si l'utilisateur est null
            Text('Connected as ${user?.email ?? 'Null'}'),
            const SizedBox(height: 20),
            MaterialButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              color: Colors.blueAccent[400],
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
