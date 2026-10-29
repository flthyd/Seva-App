import 'package:flutter/material.dart';
import '../services/language_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = LanguageService().currentLanguage; // 'te' or 'en'
  }

  void _saveAndContinue() async {
    await LanguageService().setLanguage(_selectedCode);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedCode == 'te'
                ? 'తెలుగు భాష విజయవంతంగా ఎంచుకోబడింది!'
                : 'English language selected successfully!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const maroonColor = Color(0xFF6A1B29);
    const maroonDark = Color(0xFF4A1A22);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F0), // Divine cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonDark, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LanguageService().isTelugu ? 'యాప్ భాషను ఎంచుకోండి' : 'Choose App Language',
          style: const TextStyle(
            color: maroonDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Center App Title: "✨ Seva App" (No bells)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.auto_awesome, color: maroonColor, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Seva App',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: maroonColor,
                                  letterSpacing: 1.2,
                                  fontFamily: 'serif',
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.auto_awesome, color: maroonColor, size: 22),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '—  S E V A  —',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: maroonColor,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title Header with diamond accents: ❖ యాప్ భాషను ఎంచుకోండి ❖
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.diamond_rounded, color: maroonColor, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          LanguageService().isTelugu ? 'యాప్ భాషను ఎంచుకోండి' : 'Choose App Language',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: maroonDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.diamond_rounded, color: maroonColor, size: 14),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose your preferred language',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A6855),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // The 2 Language Cards (Telugu "తె" & English "EN")
                    Row(
                      children: [
                        // Card 1: Telugu (తెలుగు - "తె")
                        Expanded(
                          child: _buildLanguageCard(
                            badgeText: 'తె',
                            title: 'తెలుగు',
                            englishSubtitle: 'Telugu',
                            isSelected: _selectedCode == 'te',
                            maroonColor: maroonColor,
                            onTap: () {
                              setState(() {
                                _selectedCode = 'te';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Card 2: English (English - "EN")
                        Expanded(
                          child: _buildLanguageCard(
                            badgeText: 'EN',
                            title: 'English',
                            englishSubtitle: 'ఇంగ్లీష్',
                            isSelected: _selectedCode == 'en',
                            maroonColor: maroonColor,
                            onTap: () {
                              setState(() {
                                _selectedCode = 'en';
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Devotional Quote
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 25, height: 1, color: maroonColor.withValues(alpha: 0.5)),
                  const SizedBox(width: 6),
                  const Icon(Icons.auto_awesome, color: maroonColor, size: 14),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: Text(
                      'One Nation, Many Languages, One Devotion',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B4E38),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.auto_awesome, color: maroonColor, size: 14),
                  const SizedBox(width: 6),
                  Container(width: 25, height: 1, color: maroonColor.withValues(alpha: 0.5)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Maroon Rounded Gradient Button: "కొనసాగించండి" / "Continue"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: InkWell(
                onTap: _saveAndContinue,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B181B), Color(0xFF6A1B29)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: maroonColor.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _selectedCode == 'te' ? 'కొనసాగించండి' : 'Continue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required String badgeText,
    required String title,
    required String englishSubtitle,
    required bool isSelected,
    required Color maroonColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 125,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF9F9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? maroonColor : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? maroonColor.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Selected Checkmark Badge (top right)
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: maroonColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),

            // Card Content: Badge ("తె" or "EN") + Name + Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
              child: Row(
                children: [
                  // Circular Badge with letter/word "తె" / "EN"
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? maroonColor : const Color(0xFFF5EBEB),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? maroonColor : const Color(0xFFD9B9BD),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: badgeText.length > 2 ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : maroonColor,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Language Text & Subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? maroonColor : const Color(0xFF2C3E50),
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          englishSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? maroonColor.withValues(alpha: 0.8) : Colors.grey.shade600,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(width: 12, height: 1, color: maroonColor.withValues(alpha: 0.5)),
                            const SizedBox(width: 3),
                            Icon(Icons.star, color: maroonColor, size: 9),
                            const SizedBox(width: 3),
                            Container(width: 12, height: 1, color: maroonColor.withValues(alpha: 0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
