import 'package:flutter/material.dart';
import 'package:product_list_app/screens/home_screen.dart';
import 'package:product_list_app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:product_list_app/utilities/screenshotProtectionService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ScreenshotProtectionService.enableProtection();
  final user = FirebaseAuth.instance.currentUser;
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? LoginScreen() : HomeScreen(user: user),
    ),
  );
}
