import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to Portrait Only (no auto rotation)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Global Flutter error handling to prevent sudden gray crash screens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("Global Flutter Error: ${details.exceptionAsString()}");
  };

  // Global UI crash error builder - provides a professional user experience instead of ugly red/grey screen
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.temple_hindu_rounded,
                    size: 64,
                    color: Color(0xFF6A1B29),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "దివ్య మందిరం",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B29),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "తాత్కాలిక సాంకేతిక సమస్య ఏర్పడింది.\nదయచేసి యాప్‌ను రీస్టార్ట్ చేయండి లేదా వేచి ఉండండి.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Try to rebuild the app or go back
                    runApp(const DivyaMandirApp());
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                  label: const Text(
                    "తిరిగి ప్రారంభించండి (Restart)",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  // Robust Firebase initialization that handles both Android native and Web correctly
  try {
    if (kIsWeb) {
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
    } else if (Platform.isAndroid) {
      // Explicit options matching google-services.json for Android
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCddRfxd7TofkunPWWTQTtoTb4ilFAUgm0",
          projectId: "sevaapp-af368",
          storageBucket: "sevaapp-af368.firebasestorage.app",
          messagingSenderId: "11804332615",
          appId: "1:11804332615:android:aaa3a59c52786303d6d762",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase init note: $e");
    // Fallback attempt without options if not already initialized
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (_) {}
  }

  runApp(const DivyaMandirApp());
}

class DivyaMandirApp extends StatelessWidget {
  const DivyaMandirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService(),
      builder: (context, _) {
        return MaterialApp(
          title: 'Divya Mandir',
          debugShowCheckedModeBanner: false,
          locale: Locale(LanguageService().currentLanguage),
          // Completely disable scrollbars across the entire app for a pure native Android touch experience
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            scrollbars: false,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          ),
          theme: ThemeData(
            primaryColor: const Color(0xFF6A1B29), // Maroon
            scaffoldBackgroundColor: const Color(0xFFFFFDF8), // Cream White
            // Globally hide Scrollbars in Theme
            scrollbarTheme: const ScrollbarThemeData(
              thickness: WidgetStatePropertyAll(0.0),
              thumbVisibility: WidgetStatePropertyAll(false),
              trackVisibility: WidgetStatePropertyAll(false),
              interactive: false,
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color(0xFF6A1B29),
              secondary: const Color(0xFFF1C40F), // Gold
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
