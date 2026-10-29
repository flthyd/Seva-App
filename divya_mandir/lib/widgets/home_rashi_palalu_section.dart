import 'package:flutter/material.dart';
import '../screens/know_your_rashi_screen.dart';
import '../screens/rashi_palalu_detail_screen.dart';
import '../services/language_service.dart';

/// Home Page "రాశిఫలాలు" Section matching user UI screenshot:
/// - Header: [Sun/Zodiac Icon] "రాశిఫలాలు" + Right side pill "మరిన్ని →"
/// - 2 Rows x 5 Columns of Cute Colorful Zodiac Icons matching user image exactly:
///   - Row 1: మేష (Aries), వృషభ (Taurus), మిథున (Gemini), కర్కాటక (Cancer), సింహ (Leo)
///   - Row 2: కన్య (Virgo), తులా (Libra), వృశ్చిక (Scorpio), ధనుస్సు (Sagittarius), మకర (Capricorn)
/// - Prominent Button: "✨ మీ రాశిని తెలుసుకోండి (Know Your Rashi) 🔍"
/// - Bottom Full-width Golden Button: "ఈ రోజు రాశిఫలాలు చూడండి →"
class HomeRashiPalaluSection extends StatelessWidget {
  const HomeRashiPalaluSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTelugu = LanguageService().isTelugu;
    final homeRashis = [
      // Row 1
      _HomeRashiItem(id: 'mesha', name: isTelugu ? 'మేష' : 'Aries', assetPath: 'assets/images/rashi/mesha.png'),
      _HomeRashiItem(id: 'vrushabha', name: isTelugu ? 'వృషభ' : 'Taurus', assetPath: 'assets/images/rashi/vrushabha.png'),
      _HomeRashiItem(id: 'mithuna', name: isTelugu ? 'మిథున' : 'Gemini', assetPath: 'assets/images/rashi/mithuna.png'),
      _HomeRashiItem(id: 'karkataka', name: isTelugu ? 'కర్కాటక' : 'Cancer', assetPath: 'assets/images/rashi/karkataka.png'),
      _HomeRashiItem(id: 'simha', name: isTelugu ? 'సింహ' : 'Leo', assetPath: 'assets/images/rashi/simha.png'),
      // Row 2
      _HomeRashiItem(id: 'kanya', name: isTelugu ? 'కన్య' : 'Virgo', assetPath: 'assets/images/rashi/kanya.png'),
      _HomeRashiItem(id: 'tula', name: isTelugu ? 'తులా' : 'Libra', assetPath: 'assets/images/rashi/tula.png'),
      _HomeRashiItem(id: 'vruschika', name: isTelugu ? 'వృశ్చిక' : 'Scorpio', assetPath: 'assets/images/rashi/vruschika.png'),
      _HomeRashiItem(id: 'dhanussu', name: isTelugu ? 'ధనుస్సు' : 'Sagittarius', assetPath: 'assets/images/rashi/dhanussu.png'),
      _HomeRashiItem(id: 'makara', name: isTelugu ? 'మకర' : 'Capricorn', assetPath: 'assets/images/rashi/makara.png'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF3), // Warm divine ivory cream background
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF1E4CE),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A5A20).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER: [Sun Icon] రాశిఫలాలు ------------ [మరిన్ని →]
            Row(
              children: [
                // Divine Sun Zodiac Icon
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.brightness_7_rounded,
                    color: Color(0xFFE65100),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.rashiPalaluHeader,
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
                        builder: (_) => const RashiPalaluDetailScreen(initialRashiId: 'mesha'),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEFD9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1D8B4), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.seeMore,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF752408),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: Color(0xFF752408),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 2. 2 ROWS X 5 COLUMNS RASHI GRID (Matching user image icons exactly)
            // Row 1
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: homeRashis.sublist(0, 5).map((r) => _buildRashiCell(context, r)).toList(),
            ),
            const SizedBox(height: 12),

            // Row 2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: homeRashis.sublist(5, 10).map((r) => _buildRashiCell(context, r)).toList(),
            ),

            const SizedBox(height: 14),

            // 3. "KNOW YOUR RASHI" (మీ రాశిని తెలుసుకోండి) PROMINENT BUTTON
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KnowYourRashiScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1EB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFCCBC), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFD84315), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.knowYourRashi,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF861B2E),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.search_rounded, size: 16, color: Color(0xFF861B2E)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 4. BOTTOM FULL-WIDTH BUTTON: "ఈ రోజు రాశిఫలాలు చూడండి →"
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RashiPalaluDetailScreen(initialRashiId: 'mesha'),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFDE8C7), Color(0xFFF8DCAD)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEED09D), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A5A20).withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.todayRashiPalalu,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B1B29),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Color(0xFF6B1B29),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRashiCell(BuildContext context, _HomeRashiItem r) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RashiPalaluDetailScreen(initialRashiId: r.id),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pastel Rounded Icon Box matching user uploaded image exactly
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                r.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFFFF0ED),
                  child: const Center(
                    child: Icon(Icons.stars_rounded, color: Color(0xFFE53935), size: 24),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Rashi Telugu Name
          Text(
            r.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2028),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeRashiItem {
  final String id;
  final String name;
  final String assetPath;

  const _HomeRashiItem({
    required this.id,
    required this.name,
    required this.assetPath,
  });
}
