import 'package:flutter/material.dart';
import '../screens/dashboard.dart';
import '../services/language_service.dart';

class HomeDevotionalStoreSection extends StatelessWidget {
  const HomeDevotionalStoreSection({super.key});

  static List<Map<String, String>> get categories => [
    {
      'title': LanguageService().isTelugu ? 'పూజా సామగ్రి' : 'Pooja Items',
      'image': 'assets/images/store/cat_pooja_samagri.png',
      'id': 'pooja_samagri',
    },
    {
      'title': LanguageService().isTelugu ? 'పుస్తకాలు' : 'Books',
      'image': 'assets/images/store/cat_pustakalu.png',
      'id': 'pustakalu',
    },
    {
      'title': LanguageService().isTelugu ? 'విగ్రహాలు' : 'Idols',
      'image': 'assets/images/store/cat_vigrahalu.png',
      'id': 'vigrahalu',
    },
    {
      'title': LanguageService().isTelugu ? 'రుద్రాక్షలు' : 'Rudraksha',
      'image': 'assets/images/store/cat_rudrakshalu.png',
      'id': 'rudrakshalu',
    },
  ];

  void _navigateToStore(BuildContext context, {String? categoryId}) {
    // Switch to Dashboard Tab 4 (Store)
    DashboardScreen.switchTab(context, 4);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4), // Warm divine cream card
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF3E7D3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B29).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header matching user image: "శ్రీ దేవోషనల్ స్టోర్" + "మరిన్ని ➔" pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/store/store_icon.png',
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFFB71C1C),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.devotionalStore,
                    style: const TextStyle(
                      color: Color(0xFF8B181B), // Rich auspicious maroon
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              // "మరిన్ని ➔" pill button
              InkWell(
                onTap: () => _navigateToStore(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2D6), // Soft golden yellow pill
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFE0A3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.seeMore,
                        style: const TextStyle(
                          color: Color(0xFF6A1B29),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF6A1B29),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Category Cards Row exactly as in user screenshot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((cat) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => _navigateToStore(context, categoryId: cat['id']),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category Icon container with soft rounded beige background
                        Container(
                          width: double.infinity,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F3EA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFEFE4D2),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              cat['image']!,
                              width: 62,
                              height: 62,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.category_rounded,
                                color: Color(0xFFC97A1C),
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Label in Telugu
                        Text(
                          cat['title']!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
