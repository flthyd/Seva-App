import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../screens/live_darshanam_player_screen.dart';
import '../screens/live_darshanam_home_screen.dart';
import '../services/language_service.dart';

/// Home Page "ప్రత్యక్ష దర్శనం" (Live Darshanam) Section matching user UI screenshot:
/// - Header: [Temple/Aum icon] "ప్రత్యక్ష దర్శనం" + right side warm pill "మరిన్ని →"
/// - Horizontal scrolling row of Live Darshan cards:
///   - Top left badge: "LIVE" (Red pill)
///   - Top right / bottom right badge: Viewer count icon + e.g. "12.4K"
///   - Image thumbnail: Auto extracted from YouTube or custom thumbnail URL
///   - Title: e.g. "శ్రీ వెంకటేశ్వర స్వామి"
///   - Location: e.g. "తిరుమల"
/// - Tapping card opens the Live video player screen with controls!
/// - Entire section can be enabled/disabled from Admin Panel (live_darshanam_settings / global).
class HomeLiveDarshanamSection extends StatelessWidget {
  const HomeLiveDarshanamSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // 1. Check if section is enabled/disabled by Admin
      stream: FirebaseFirestore.instance
          .collection('app_settings')
          .doc('live_darshanam')
          .snapshots(),
      builder: (context, settingsSnapshot) {
        if (settingsSnapshot.hasData && settingsSnapshot.data != null && settingsSnapshot.data!.exists) {
          final settings = settingsSnapshot.data!.data() as Map<String, dynamic>?;
          final isEnabled = settings?['isEnabled'] ?? true;
          if (!isEnabled) {
            return const SizedBox.shrink(); // Section disabled by admin
          }
        }

        // 2. Fetch Active Live Darshan Streams
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('live_darshanam')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            // Default list if Firestore is empty initially
            List<Map<String, dynamic>> items = [];

            if (snapshot.hasData && snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
              items = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  'id': doc.id,
                  'title': data['title'] ?? 'ప్రత్యక్ష దర్శనం',
                  'templeLocation': data['templeLocation'] ?? 'పుణ్యక్షేత్రం',
                  'youtubeUrl': data['youtubeUrl'] ?? '',
                  'customThumbnail': data['customThumbnail'] ?? '',
                  'viewerCount': data['viewerCount'] ?? '10.5K',
                  'isActive': data['isActive'] ?? true,
                };
              }).toList();
            } else {
              // High-quality defaults matching user UI
              items = [
                {
                  'id': 'ttd_live',
                  'title': 'శ్రీ వేంకటేశ్వర స్వామి',
                  'templeLocation': 'తిరుమల',
                  'youtubeUrl': 'https://www.youtube.com/watch?v=live_ttd_stream',
                  'customThumbnail': 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=600&q=80',
                  'viewerCount': '12.4K',
                  'isActive': true,
                },
                {
                  'id': 'srisailam_live',
                  'title': 'శ్రీ శివరాత్రి దేవాలయం',
                  'templeLocation': 'శ్రీశైలం',
                  'youtubeUrl': 'https://www.youtube.com/watch?v=live_srisailam_stream',
                  'customThumbnail': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&q=80',
                  'viewerCount': '8.7K',
                  'isActive': true,
                },
                {
                  'id': 'yadadri_live',
                  'title': 'శ్రీ లక్ష్మీ నరసింహ స్వామి',
                  'templeLocation': 'యాదాద్రి',
                  'youtubeUrl': 'https://www.youtube.com/watch?v=live_yadadri_stream',
                  'customThumbnail': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=600&q=80',
                  'viewerCount': '5.2K',
                  'isActive': true,
                },
              ];
            }

            if (items.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF3), // Warm divine cream container
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TOP HEADER: [Icon] ప్రత్యక్ష దర్శనం ------------ [మరిన్ని →]
                    Row(
                      children: [
                        // Divine Temple Icon
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.temple_hindu_rounded,
                            color: Color(0xFFC0392B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.liveDarshanHeader,
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
                                builder: (_) => const LiveDarshanamHomeScreen(),
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

                    const SizedBox(height: 12),

                    // 2. HORIZONTAL SCROLLING CARDS (Exactly matching the 2 cards shown in user screenshot)
                    SizedBox(
                      height: 186,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildDarshanamCard(context, item);
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

  Widget _buildDarshanamCard(BuildContext context, Map<String, dynamic> item) {
    final youtubeUrl = item['youtubeUrl'] as String? ?? '';
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
    final customThumb = item['customThumbnail'] as String? ?? '';

    // Auto YouTube high-res thumbnail or custom thumbnail fallback
    final thumbnailUrl = customThumb.isNotEmpty
        ? customThumb
        : (videoId != null && videoId.isNotEmpty
            ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
            : 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=600&q=80');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LiveDarshanamPlayerScreen(
              title: item['title'] ?? 'ప్రత్యక్ష దర్శనం',
              templeLocation: item['templeLocation'] ?? 'పుణ్యక్షేత్రం',
              youtubeUrl: youtubeUrl,
              viewerCount: item['viewerCount'],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 174,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail Box with LIVE & Viewers Badges
            Container(
              height: 120,
              width: 174,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF2B1810),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF3E1C1F),
                        alignment: Alignment.center,
                        child: const Icon(Icons.temple_hindu_rounded, size: 40, color: Colors.white54),
                      ),
                    ),

                    // Dark subtle gradient overlay on bottom
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // Top Left: "LIVE" Red Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D20), // Bright Red
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF2D20).withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Bottom Right: Viewers Counter Badge (e.g. 👁 12.4K)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.remove_red_eye_outlined,
                              color: Colors.white,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['viewerCount'] ?? '10K',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 7),

            // Title: e.g. "శ్రీ వెంకటేశ్వర స్వామి"
            Text(
              item['title'] ?? '',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2028),
                height: 1.15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 2),

            // Location: e.g. "తిరుమల"
            Text(
              item['templeLocation'] ?? '',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B6B79),
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static void _showAllLiveDarshanBottomSheet(BuildContext context, List<Map<String, dynamic>> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCF8F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29)),
                  SizedBox(width: 8),
                  Text(
                    "అన్ని ప్రత్యక్ష ప్రసారాలు (All Live Darshanam)",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                  ),
                ],
              ),
              const Divider(height: 20),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, idx) {
                    final it = items[idx];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B29),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.videocam_rounded, color: Colors.white),
                      ),
                      title: Text(it['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${it['templeLocation']} • 👁 ${it['viewerCount']}"),
                      trailing: const Icon(Icons.play_circle_fill, color: Color(0xFFE53935), size: 32),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LiveDarshanamPlayerScreen(
                              title: it['title'] ?? '',
                              templeLocation: it['templeLocation'] ?? '',
                              youtubeUrl: it['youtubeUrl'] ?? '',
                              viewerCount: it['viewerCount'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
