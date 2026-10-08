import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBL0ucvw6HiBr0N7QqdfJprZG_qQ2VNLnY',
      authDomain: 'sevaapp-af368.firebaseapp.com',
      projectId: 'sevaapp-af368',
      storageBucket: 'sevaapp-af368.firebasestorage.app',
      messagingSenderId: '11804332615',
      appId: '1:11804332615:web:a38c1eefe4531b84d6d762',
    ),
  );
  
  String out = '--- GODS ---\n';
  final gods = await FirebaseFirestore.instance.collection('gods').get();
  for (var doc in gods.docs) {
    out += '\ => \\n';
  }

  out += '\n--- FLOWERS ---\n';
  final flowers = await FirebaseFirestore.instance.collection('flowers').get();
  for (var doc in flowers.docs) {
    out += '\ => \\n';
  }
  
  print("DATA DUMP:\n\");
}
