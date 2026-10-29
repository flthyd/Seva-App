import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/katha_model.dart';
import '../data/telugu_kathalu_data.dart';
import '../screens/katha_detail_screen.dart';
import '../screens/kathalu_list_screen.dart';
import '../services/language_service.dart';

/// "నేటి కథ" (Daily Sacred Story) Home Page Section matching user UI screenshot:
/// - Header: [Rangoli/Chakra Logo] "నేటి కథ" ------------ [మరిన్ని →]
/// - Banner Card:
///   - Top Image (Krishna Murali art banner matching screenshot)
///   - Title: "శ్రీ కృష్ణ జనన కథ"
///   - Subtitle: "శ్రీ కృష్ణుడు జననం, గోకులం, బాలలీలలు, ఆధునిక జీవనంలో సందేశం."
///   - Rounded Orange Gradient Button: "కథ చదవండి →"
/// - Tap button opens KathaDetailScreen
/// - Tap "మరిన్ని →" opens KathaluListScreen (All previous stories)
class HomeNetiKathaSection extends StatelessWidget {
  const HomeNetiKathaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // 1. Check if section is enabled/disabled by Admin
      stream: FirebaseFirestore.instance.collection('app_settings').doc('neti_katha').snapshots(),
      builder: (context, settingsSnap) {
        if (settingsSnap.hasData && settingsSnap.data != null && settingsSnap.data!.exists) {
          final settings = settingsSnap.data!.data() as Map<String, dynamic>?;
          final isEnabled = settings?['isEnabled'] ?? true;
          if (!isEnabled) {
            return const SizedBox.shrink(); // Section disabled by admin
          }
        }

        // 2. Fetch Story from Firestore based on Today's Date or Latest Story
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('neti_kathalu')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snap) {
            KathaModel currentKatha = TeluguKathaluData.get10PreloadedKathalu().first;

            if (snap.hasData && snap.data != null && snap.data!.docs.isNotEmpty) {
              final list = snap.data!.docs.map((doc) {
                return KathaModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();

              // Today's formatted date string: YYYY-MM-DD
              final now = DateTime.now();
              final todayStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

              // Priority 1: Exact match with today's scheduled date
              final todayDateMatch = list.where((k) {
                final d = k.date.trim();
                return d == todayStr;
              }).toList();

              // Priority 2: Admin explicitly toggled "isFeaturedToday"
              final featuredList = list.where((k) => k.isFeaturedToday).toList();

              if (todayDateMatch.isNotEmpty) {
                currentKatha = todayDateMatch.first;
              } else if (featuredList.isNotEmpty) {
                currentKatha = featuredList.first;
              } else if (list.isNotEmpty) {
                // Priority 3: Default to latest story (by date descending or created order)
                list.sort((a, b) => b.date.compareTo(a.date));
                currentKatha = list.first;
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF4), // Warm divine cream container
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF1E4CE),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A5A20).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TOP HEADER: [Icon] నేటి కథ ------------ [మరిన్ని →]
                    Row(
                      children: [
                        // Divine Rangoli/Chakra Logo from user screenshot
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset(
                            'assets/images/neti_katha/katha_header_icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.flare_rounded,
                              color: Color(0xFFE65100),
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.netiKatha,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B111D),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Spacer(),
                        // Warm Pill: "మరిన్ని →"
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const KathaluListScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDEFD9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF0D5AC),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppStrings.seeMore,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6A1B29),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                  color: Color(0xFF6A1B29),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 2. STORY BANNER IMAGE (Matching screenshot curved top corners)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 125,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5A141A),
                        ),
                        child: _buildBanner(currentKatha),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3. TITLE & SUBTITLE
                    Text(
                      currentKatha.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2028),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentKatha.shortSummary,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF5A6E85),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 14),

                    // 4. ORANGE GRADIENT ACTION BUTTON: "కథ చదవండి →"
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KathaDetailScreen(katha: currentKatha),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFD35400),
                              Color(0xFFE67E22),
                              Color(0xFFD35400),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD35400).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.readStory,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBanner(KathaModel katha) {
    if (katha.assetPath.isNotEmpty) {
      return Image.asset(
        katha.assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(katha),
      );
    }
    return _buildFallback(katha);
  }

  Widget _buildFallback(KathaModel katha) {
    if (katha.imageUrl.isNotEmpty && katha.imageUrl.startsWith('http')) {
      return Image.network(
        katha.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF6A1B29),
          child: const Center(child: Icon(Icons.menu_book, color: Colors.white30, size: 40)),
        ),
      );
    }
    return Container(
      color: const Color(0xFF6A1B29),
      child: const Center(child: Icon(Icons.menu_book, color: Colors.white30, size: 40)),
    );
  }
}
