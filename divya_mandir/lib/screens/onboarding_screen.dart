import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = const [
    {
      'artwork': 'assets/images/onboarding/artwork_temple_family.png',
      'title': 'దేవాలయాల\nవిశేషాలు',
      'subtitle': 'ప్రసిద్ధ దేవాలయాల వివరాలు,\nదర్శన సమయాలు, సేవలు తెలుసుకోండి.',
    },
    {
      'artwork': 'assets/images/onboarding/artwork_pooja_deepam.png',
      'title': 'నిత్య పూజా\nవిధానాలు',
      'subtitle': 'ఇంటి వద్ద చేయగలిగే పూజా విధానాలు,\nమంత్రాలు, ఆధ్యాత్మిక సమాచారం.',
    },
    {
      'artwork': 'assets/images/onboarding/artwork_bhakti_cards.png',
      'title': 'భక్తి కంటెంట్\nఎప్పుడూ మీతో',
      'subtitle': 'పాటలు, మంత్రాలు, కథలు, గ్రంథాలు,\nవాల్‌పేపర్లు మరియు మరెన్నో.',
    },
    {
      'artwork': 'assets/images/onboarding/artwork_seva_app_hand.png',
      'title': 'దైవ సేవ\nఇప్పుడే ప్రారంభించండి',
      'subtitle': 'ఆధ్యాత్మిక ప్రయాణం కోసం\nSeva App మీకు తోడుగా.',
    },
  ];

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);
    } catch (_) {}

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _onNext() {
    if (_currentPage == _pages.length - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE), // Cream warm devotional background
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _pages.length - 1)
                    GestureDetector(
                      onTap: _completeOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7E9D4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF8B2B38),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 32),
                ],
              ),
            ),

            // PageView with Artwork & Telugu Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // Artwork Image Container
                        Container(
                          height: 290,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              item['artwork']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title in Maroon Telugu Font
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A1B29),
                            height: 1.25,
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          item['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.brown.shade700,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area: Dots & Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: _currentPage == _pages.length - 1
                  ? _buildFinalButton()
                  : _buildDotsAndArrow(),
            ),
          ],
        ),
      ),
    );
  }

  // Dots indicator on left, circular maroon arrow button on right
  Widget _buildDotsAndArrow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dots
        Row(
          children: List.generate(_pages.length, (index) {
            final isSelected = index == _currentPage;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              width: isSelected ? 8 : 7,
              height: isSelected ? 8 : 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF7A1B29)
                    : const Color(0xFFDCC8B3),
              ),
            );
          }),
        ),

        // Maroon Circular Arrow Button
        GestureDetector(
          onTap: _onNext,
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF7A1B29),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x337A1B29),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  // Full-width "ప్రారంభించండి →" pill button on the final page (Onboarding 4)
  Widget _buildFinalButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dots centered
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (index) {
            final isSelected = index == _currentPage;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 8 : 7,
              height: isSelected ? 8 : 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF7A1B29)
                    : const Color(0xFFDCC8B3),
              ),
            );
          }),
        ),
        const SizedBox(height: 18),

        // Wide Maroon Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _completeOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A1B29),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ప్రారంభించండి',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
