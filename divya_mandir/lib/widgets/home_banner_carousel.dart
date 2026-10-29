import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/dashboard.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({Key? key}) : super(key: key);

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_itemCount > 1 && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _itemCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Handle banner or button tap
  void _handleBannerTap(Map<String, dynamic> data) async {
    final actionType = data['action_type'] as String? ?? 'none';
    final actionTarget = data['action_target'] as String? ?? '';

    if (actionType == 'tab') {
      int targetIndex = 2; // default pooja
      if (actionTarget == 'home') {
        targetIndex = 0;
      } else if (actionTarget == 'status') {
        targetIndex = 1;
      } else if (actionTarget == 'pooja') {
        targetIndex = 2;
      } else if (actionTarget == 'music') {
        targetIndex = 3;
      } else if (actionTarget == 'panchangam') {
        targetIndex = 4;
      }
      DashboardScreen.switchTab(context, targetIndex);
    } else if (actionType == 'url') {
      if (actionTarget.isNotEmpty) {
        try {
          final uri = Uri.parse(actionTarget);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          debugPrint("Failed to launch URL: $e");
        }
      }
    }
  }

  // Default fallback banners matching user aesthetic
  List<Map<String, dynamic>> _getDefaultBanners() {
    return [
      {
        'tag': 'నేటి దైవ సందేశం',
        'title': 'ఓం నమో వేంకటేశాయ',
        'subtitle': '“భక్తి ఉన్న హృదయంలో ఎప్పుడూ దేవుడు ఉంటాడు.”',
        'button_text': 'శ్లోకం వినండి',
        'action_type': 'tab',
        'action_target': 'music',
        'image_url': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?q=80&w=1200&auto=format&fit=crop',
      },
      {
        'tag': 'నిత్య ఆరాధన',
        'title': 'ఓం నమః శివాయ',
        'subtitle': '“సర్వ మంగళ మాంగల్యే శివే సర్వార్థ సాధికే”',
        'button_text': 'పూజ చేయండి',
        'action_type': 'tab',
        'action_target': 'pooja',
        'image_url': 'https://images.unsplash.com/photo-1608755728617-aefab37d45f6?q=80&w=1200&auto=format&fit=crop',
      },
      {
        'tag': 'లక్ష్మీ కటాక్షం',
        'title': 'శ్రీ మహాలక్ష్మీ నమః',
        'subtitle': '“సర్వ సంపదలు, శాంతి సౌభాగ్యాలు ప్రసాదించే తల్లి”',
        'button_text': 'పంచాంగం చూడండి',
        'action_type': 'tab',
        'action_target': 'panchangam',
        'image_url': 'https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=1200&auto=format&fit=crop',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('home_banners').orderBy('order').snapshots(),
      builder: (context, snapshot) {
        List<Map<String, dynamic>> banners = [];
        final now = DateTime.now();

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final isActive = data['is_active'] != false;
            if (!isActive) continue;

            final hasSchedule = data['has_schedule'] == true;
            if (hasSchedule) {
              final start = (data['start_date'] as Timestamp?)?.toDate();
              final end = (data['end_date'] as Timestamp?)?.toDate();
              if (start != null && now.isBefore(start)) continue;
              if (end != null && now.isAfter(end)) continue;
            }

            banners.add(data);
          }
        }

        // If no active banners from Firestore yet, use fallback sample banners
        if (banners.isEmpty) {
          banners = _getDefaultBanners();
        }

        _itemCount = banners.length;

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              height: 168,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6A1B29).withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Carousel View
                    PageView.builder(
                      controller: _pageController,
                      itemCount: banners.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildBannerItem(banners[index]);
                      },
                    ),

                    // Dot Indicators at bottom
                    if (banners.length > 1)
                      Positioned(
                        bottom: 10,
                        right: 18,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(banners.length, (index) {
                            final isSelected = _currentPage == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isSelected ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF1C40F) // Gold pill
                                    : Colors.white.withOpacity(0.65), // Translucent dot
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBannerItem(Map<String, dynamic> data) {
    final imageUrl = data['image_url'] as String? ?? '';
    final tag = data['tag'] as String? ?? '';
    final title = data['title'] as String? ?? '';
    final subtitle = data['subtitle'] as String? ?? '';
    final buttonText = data['button_text'] as String? ?? '';

    return GestureDetector(
      onTap: () => _handleBannerTap(data),
      child: Container(
        color: const Color(0xFF4A0E18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF5A1522),
                  child: const Center(
                    child: Icon(Icons.temple_hindu, color: Colors.white38, size: 50),
                  ),
                ),
              ),

            // Deep Maroon / Golden Gradient Overlay to ensure text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF380812).withOpacity(0.96),
                    const Color(0xFF4E0E1B).withOpacity(0.85),
                    const Color(0xFF4E0E1B).withOpacity(0.40),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 0.70, 1.0],
                ),
              ),
            ),

            // Content Overlay
            Padding(
              padding: const EdgeInsets.only(left: 18.0, top: 14.0, bottom: 12.0, right: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pre-title / Tag with sparkle icon
                  if (tag.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFF7D070),
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          tag,
                          style: const TextStyle(
                            color: Color(0xFFF7D070),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),

                  // Main Heading / Title in Telugu
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Subtitle / Devotional Quote
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 11.5,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Action Button (Play / Explore Capsule)
                  if (buttonText.isNotEmpty)
                    InkWell(
                      onTap: () => _handleBannerTap(data),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.only(left: 3, right: 14, top: 3, bottom: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8C1D2F), Color(0xFF5B0E1B)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFF1C40F).withOpacity(0.7),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Circular Golden Button with Play Icon
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFFE082), Color(0xFFF1C40F)],
                                ),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 18,
                                color: Color(0xFF4A0E18),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              buttonText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
