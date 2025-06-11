import 'package:flutter/material.dart';
import 'package:product_list_app/screens/home_screen.dart';
import 'package:product_list_app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final user = FirebaseAuth.instance.currentUser;
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? LoginScreen() : HomeScreen(user: user),
    ),
  );
}
