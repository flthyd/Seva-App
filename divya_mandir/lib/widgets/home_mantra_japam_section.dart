import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mantra_model.dart';
import '../data/telugu_mantra_data.dart';
import '../screens/mantra_japam_player_screen.dart';
import '../screens/mantra_list_screen.dart';
import '../services/language_service.dart';

/// "మంత్ర జపం" (Mantra Japam) Home Page Section
/// Exactly matches user screenshot (media_1793010168904_6519793c.png):
/// - Header: [Chakra Logo] "మంత్ర జపం" ------------ [మరిన్ని →]
/// - Card Container:
///   - Top Circle: Om "ॐ" in soft red/pink circular glow badge
///   - Mantra Name: "ఓం నమః శివాయ"
///   - Counter & Stepper: [-]   0 / 108   [+]
///   - Big Button: "జపం ప్రారంభించండి" (Dark Maroon Rounded Pill)
class HomeMantraJapamSection extends StatefulWidget {
  const HomeMantraJapamSection({super.key});

  @override
  State<HomeMantraJapamSection> createState() => _HomeMantraJapamSectionState();
}

class _HomeMantraJapamSectionState extends State<HomeMantraJapamSection> {
  int _currentCount = 0;
  final int _targetCount = 108;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // Check if section is enabled in admin settings
      stream: FirebaseFirestore.instance.collection('app_settings').doc('mantra_japam').snapshots(),
      builder: (context, settingsSnap) {
        if (settingsSnap.hasData && settingsSnap.data != null && settingsSnap.data!.exists) {
          final settings = settingsSnap.data!.data() as Map<String, dynamic>?;
          final isEnabled = settings?['isEnabled'] ?? true;
          if (!isEnabled) {
            return const SizedBox.shrink();
          }
        }

        // Fetch Featured or First Mantra
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('mantralu')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snap) {
            MantraModel currentMantra = TeluguMantraData.getDefaultMantras().first;

            if (snap.hasData && snap.data != null && snap.data!.docs.isNotEmpty) {
              final list = snap.data!.docs.map((doc) {
                return MantraModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();
              if (list.isNotEmpty) {
                currentMantra = list.first;
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
                    // 1. TOP HEADER: [Icon] మంత్ర జపం ------------ [మరిన్ని →]
                    Row(
                      children: [
                        // Divine Logo from user screenshot
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset(
                            'assets/images/mantra_japam/mantra_header_icon.png',
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
                          AppStrings.mantraJapamHeader,
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
                                builder: (_) => const MantraListScreen(),
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

                    // 2. INNER WHITE CARD CONTAINER (Matching user UI screenshot)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFF4ECE1), width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Om Badge in Circle Glow
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFCE4D6),
                                  const Color(0xFFF8D7DA).withValues(alpha: 0.6),
                                  Colors.white,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8A1E2B).withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "ॐ",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8A1E2B),
                                height: 1.1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Mantra Name: "ఓం నమః శివాయ"
                          Text(
                            currentMantra.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E272E),
                              letterSpacing: -0.2,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Stepper Row: [-]   0 / 108   [+]
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Minus Button
                              InkWell(
                                onTap: () {
                                  if (_currentCount > 0) {
                                    HapticFeedback.lightImpact();
                                    setState(() => _currentCount--);
                                  }
                                },
                                borderRadius: BorderRadius.circular(22),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFADBD8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.remove,
                                    color: Color(0xFF78281F),
                                    size: 24,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 28),

                              // Counter Display: 0 / 108
                              Text(
                                "$_currentCount / $_targetCount",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C1810),
                                  letterSpacing: 0.5,
                                ),
                              ),

                              const SizedBox(width: 28),

                              // Plus Button (Dark Red/Maroon Circle)
                              InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  setState(() {
                                    _currentCount++;
                                  });
                                  if (_currentCount >= _targetCount) {
                                    _celebrateHomeCompletion(context, currentMantra);
                                  }
                                },
                                borderRadius: BorderRadius.circular(22),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF8A1E2B), // Exact maroon tone
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Rounded Pill Button: "జపం ప్రారంభించండి"
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B111D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MantraJapamPlayerScreen(
                                      mantra: currentMantra,
                                      initialTarget: _targetCount,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                AppStrings.startJapam,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  void _celebrateHomeCompletion(BuildContext context, MantraModel mantra) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFFBF4),
        title: const Text("జపం పూర్తయింది! 🙏", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
        content: Text("మీరు '${mantra.name}' జపాన్ని $_targetCount సార్లు పూర్తి చేశారు. సర్వమంగళం భవతు."),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _currentCount = 0);
            },
            child: const Text("సరే", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
