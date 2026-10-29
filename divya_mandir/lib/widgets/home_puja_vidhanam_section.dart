import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puja_vidhanam_model.dart';
import '../data/telugu_puja_vidhanam_data.dart';
import '../screens/puja_vidhanam_detail_screen.dart';
import '../screens/puja_vidhanam_list_screen.dart';
import '../services/language_service.dart';

/// "పూజా విధానం" (Puja Vidhanam) Home Page Section
/// Exactly matches user screenshot (media_1793018648027_75c2fb1d.png):
/// - Header: [Sitting Deity Idol Icon] "పూజా విధానం" (No "మరిన్ని" in user screenshot, but clickable or header expandable)
/// - 4 Rounded Square Tiles matching the cropped icons:
///   1. గణపతి పూజ
///   2. శివ పూజ
///   3. లక్ష్మీ పూజ
///   4. సాయి పూజ
/// - Scrollable or tappable horizontally for more pujas
class HomePujaVidhanamSection extends StatelessWidget {
  const HomePujaVidhanamSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // 1. Check if section is enabled in admin settings
      stream: FirebaseFirestore.instance.collection('app_settings').doc('puja_vidhanam').snapshots(),
      builder: (context, settingsSnap) {
        if (settingsSnap.hasData && settingsSnap.data != null && settingsSnap.data!.exists) {
          final settings = settingsSnap.data!.data() as Map<String, dynamic>?;
          final isEnabled = settings?['isEnabled'] ?? true;
          if (!isEnabled) {
            return const SizedBox.shrink();
          }
        }

        // 2. Fetch Puja Vidhanam List
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('puja_vidhanam')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snap) {
            List<PujaVidhanamModel> list = [];

            if (snap.hasData && snap.data != null && snap.data!.docs.isNotEmpty) {
              list = snap.data!.docs.map((doc) {
                return PujaVidhanamModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();
            }

            // Fallback to preloaded Telugu Pujas if Firestore is empty
            if (list.isEmpty) {
              list = List<PujaVidhanamModel>.from(TeluguPujaVidhanamData.get30DefaultPujas());
            }

            // Sort: items with custom positive order come by order asc, otherwise latest uploads first
            list.sort((a, b) {
              if (a.order > 0 && b.order > 0) {
                return a.order.compareTo(b.order);
              }
              if (a.order > 0) return -1;
              if (b.order > 0) return 1;
              return 0; // maintain descending snapshot order (latest uploads first)
            });

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
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TOP HEADER: [Idol Logo] పూజా విధానం -------- [మరిన్ని →]
                    Row(
                      children: [
                        // Divine Sitting Deity Logo from user screenshot
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset(
                            'assets/images/puja_vidhanam/puja_header_icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.temple_hindu_rounded,
                              color: Color(0xFFE65100),
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.pujaVidhanamHeader,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B111D),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PujaVidhanamListScreen(),
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

                    const SizedBox(height: 14),

                    // 2. HORIZONTAL LIST OF PUJA ICONS MATCHING SCREENSHOT
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (context, idx) {
                          final puja = list[idx];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PujaVidhanamDetailScreen(puja: puja),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  // Rounded square card with edge-to-edge image (no inside padding)
                                  Container(
                                    width: 76,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3DE), // Exact warm peach tone
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFF6E7CF),
                                        width: 1,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: _buildTileImage(puja),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Title in selected language or Telugu
                                  SizedBox(
                                    width: 78,
                                    child: Text(
                                      LanguageService().isTelugu
                                          ? puja.title
                                          : (puja.id == 'ganapati'
                                              ? 'Ganapati Puja'
                                              : (puja.id == 'shiva'
                                                  ? 'Shiva Puja'
                                                  : (puja.id == 'lakshmi'
                                                      ? 'Lakshmi Puja'
                                                      : (puja.id == 'sai'
                                                          ? 'Sai Puja'
                                                          : puja.title)))),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E272E),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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

  Widget _buildTileImage(PujaVidhanamModel puja) {
    if (puja.imageUrl.isNotEmpty && puja.imageUrl.startsWith('http')) {
      return Image.network(
        puja.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackAsset(puja),
      );
    }
    return _buildFallbackAsset(puja);
  }

  Widget _buildFallbackAsset(PujaVidhanamModel puja) {
    if (puja.localAssetPath != null && puja.localAssetPath!.isNotEmpty) {
      return Image.asset(
        puja.localAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(
          Icons.temple_hindu_rounded,
          color: Color(0xFF8A1E2B),
          size: 38,
        ),
      );
    }
    return const Icon(
      Icons.temple_hindu_rounded,
      color: Color(0xFF8A1E2B),
      size: 38,
    );
  }
}
