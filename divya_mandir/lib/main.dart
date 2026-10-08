import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBL0ucvw6HiBr0N7QqdfJprZG_qQ2VNLnY",
        authDomain: "sevaapp-af368.firebaseapp.com",
        projectId: "sevaapp-af368",
        storageBucket: "sevaapp-af368.firebasestorage.app",
        messagingSenderId: "11804332615",
        appId: "1:11804332615:web:a38c1eefe4531b84d6d762",
      ),
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  runApp(const DivyaMandirApp());
}

class DivyaMandirApp extends StatelessWidget {
  const DivyaMandirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divya Mandir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6A1B29), // Maroon
        scaffoldBackgroundColor: const Color(0xFFFFFDF8), // Cream White
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF6A1B29),
          secondary: const Color(0xFFF1C40F), // Gold
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

