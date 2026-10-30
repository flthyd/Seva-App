import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Check onboarding completion and login state
    Future.delayed(const Duration(milliseconds: 2300), () async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

      // If user hasn't seen onboarding yet, take them through Onboarding Screens
      if (!hasCompletedOnboarding) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
          return;
        }
      }

      // If logged in, navigate straight to Dashboard
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
          return;
        }
      }

      // If onboarding completed but signed out, navigate to Login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B29),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Exact High-Res Rich Devotional Splash Background (from Reference 1. Splash Screen)
          Image.asset(
            'assets/images/onboarding/splash_screen_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF6A1B29),
            ),
          ),

          // Smooth fade in
          FadeTransition(
            opacity: _fadeAnimation,
            child: const SizedBox.expand(),
          ),
        ],
      ),
    );
  }
}
