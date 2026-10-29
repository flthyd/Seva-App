import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/temple_model.dart';

class TempleDetailScreen extends StatefulWidget {
  final TempleModel temple;

  const TempleDetailScreen({super.key, required this.temple});

  @override
  State<TempleDetailScreen> createState() => _TempleDetailScreenState();
}

class _TempleDetailScreenState extends State<TempleDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(BuildContext context, String urlString, String label) async {
    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label అందుబాటులో లేదు.')),
      );
      return;
    }
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$urlString తెరవలేకపోయాము.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<String> _getAllImages() {
    List<String> list = [];
    if (widget.temple.images.isNotEmpty) {
      list.addAll(widget.temple.images);
    } else if (widget.temple.imageUrl.isNotEmpty) {
      list.add(widget.temple.imageUrl);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final temple = widget.temple;
    final allImages = _getAllImages();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. DIVINE APP BAR WITH IMAGE SLIDER (SWIPEABLE SLIDES)
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF6A1B29),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                temple.nameTelugu,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(color: Colors.black87, blurRadius: 6),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // IMAGE SLIDER / CAROUSEL
                  if (allImages.length > 1)
                    PageView.builder(
                      controller: _pageController,
                      itemCount: allImages.length,
                      onPageChanged: (idx) {
                        setState(() => _currentImageIndex = idx);
                      },
                      itemBuilder: (context, index) {
                        return _buildSingleImage(allImages[index]);
                      },
                    )
                  else if (allImages.length == 1)
                    _buildSingleImage(allImages.first)
                  else
                    _buildFallbackHeaderAsset(),

                  // Dark gradient bottom overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),

                  // Slide indicators (dots) and Counter Badge
                  if (allImages.length > 1)
                    Positioned(
                      bottom: 48,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(allImages.length, (idx) {
                          final isSelected = _currentImageIndex == idx;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isSelected ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF1C40F) : Colors.white60,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),

                  // Photo counter badge (e.g. 1 / 4)
                  if (allImages.length > 1)
                    Positioned(
                      top: 45,
                      right: 56,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white30, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 13, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              "${_currentImageIndex + 1}/${allImages.length}",
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'షేర్ చేయండి',
                onPressed: () {},
              ),
            ],
          ),

          // 2. MAIN TEMPLE INFORMATION CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Deity + Location card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF0DEC5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    temple.nameTelugu,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6A1B29),
                                    ),
                                  ),
                                  if (temple.nameEnglish.isNotEmpty)
                                    Text(
                                      temple.nameEnglish,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0E8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFFB299)),
                              ),
                              child: Text(
                                temple.state,
                                style: const TextStyle(
                                  color: Color(0xFFD32F2F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (temple.deity.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.spa_rounded, color: Color(0xFFE67E22), size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "ప్రధాన దైవం: ${temple.deity}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (temple.district.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Color(0xFFE53935), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "జిల్లా / ప్రాంతం: ${temple.district}",
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // QUICK ACTION BUTTONS (ONLINE BOOKINGS & GOOGLE MAPS)
                  Row(
                    children: [
                      // Online Bookings Button
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B29),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                          ),
                          onPressed: () => _openUrl(
                            context,
                            temple.onlineBookingUrl,
                            'ఆన్‌లైన్ బుకింగ్ లింక్',
                          ),
                          icon: const Icon(Icons.confirmation_number_rounded, size: 20),
                          label: const Text(
                            "ఆన్‌లైన్ దర్శనం బుకింగ్",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Google Maps Route Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF3E0),
                          foregroundColor: const Color(0xFFE65100),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFFFFB74D)),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _openUrl(
                          context,
                          temple.googleMapsUrl.isNotEmpty
                              ? temple.googleMapsUrl
                              : "https://maps.google.com/?q=${Uri.encodeComponent('${temple.nameTelugu} Temple')}",
                          'గూగుల్ మ్యాప్స్ రూట్',
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_rounded, size: 20),
                            SizedBox(width: 6),
                            Text("రూట్ మ్యాప్", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3. TEMPLE HISTORY STORY (స్థల పురాణం / చరిత్ర)
                  _buildSectionCard(
                    title: "ఆలయ చరిత్ర & స్థల పురాణం",
                    icon: Icons.history_edu_rounded,
                    content: temple.historyStory.isNotEmpty
                        ? temple.historyStory
                        : "ఈ పుణ్యక్షేత్రం యొక్క సమగ్ర స్థల పురాణం త్వరలోనే నవీకరించబడుతుంది.",
                  ),

                  const SizedBox(height: 14),

                  // 4. DARSHAN TIMINGS (దర్శన సమయాలు)
                  _buildSectionCard(
                    title: "దర్శన వేళలు & సమాచారం",
                    icon: Icons.access_time_rounded,
                    content: temple.timings,
                  ),

                  const SizedBox(height: 14),

                  // 5. SPECIAL SEVAS & FESTIVALS (విశిష్ట సేవలు & ఉత్సవాలు)
                  if (temple.specialSevas.isNotEmpty)
                    _buildSectionCard(
                      title: "ప్రత్యేక సేవలు & ఉత్సవాలు",
                      icon: Icons.celebration_rounded,
                      content: temple.specialSevas,
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0DEC5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF6A1B29), size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B29),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackHeaderAsset(),
      );
    } else if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackHeaderAsset(),
      );
    }
    return _buildFallbackHeaderAsset();
  }

  Widget _buildFallbackHeaderAsset() {
    if (widget.temple.assetPath.isNotEmpty) {
      return Image.asset(
        widget.temple.assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildHeaderPlaceholder(),
      );
    }
    return _buildHeaderPlaceholder();
  }

  Widget _buildHeaderPlaceholder() {
    return Container(
      color: const Color(0xFF5A141A),
      child: const Center(
        child: Icon(
          Icons.temple_hindu_rounded,
          size: 70,
          color: Colors.white38,
        ),
      ),
    );
  }
}
