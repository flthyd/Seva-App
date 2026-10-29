import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puja_vidhanam_model.dart';
import '../data/telugu_puja_vidhanam_data.dart';
import 'puja_vidhanam_detail_screen.dart';

class PujaVidhanamListScreen extends StatefulWidget {
  const PujaVidhanamListScreen({super.key});

  @override
  State<PujaVidhanamListScreen> createState() => _PujaVidhanamListScreenState();
}

class _PujaVidhanamListScreenState extends State<PujaVidhanamListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'అన్నీ';

  // Category filter items with matching icons from user screenshot
  final List<Map<String, dynamic>> _filterTabs = const [
    {'title': 'అన్నీ', 'icon': Icons.check},
    {'title': 'నిత్య పూజ', 'icon': Icons.wb_sunny_rounded},
    {'title': 'వ్రతం', 'icon': Icons.filter_vintage_rounded},
    {'title': 'సాయంత్రం', 'icon': Icons.nights_stay_rounded},
    {'title': 'మందిర పూజ', 'icon': Icons.temple_hindu_rounded},
    {'title': 'గ్రహ శాంతి', 'icon': Icons.stars_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EE), // Cream white divine background
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('puja_vidhanam')
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          List<PujaVidhanamModel> list = [];

          if (snapshot.hasData && snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
            list = snapshot.data!.docs.map((doc) {
              return PujaVidhanamModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            }).toList();
          }

          if (list.isEmpty) {
            list = List<PujaVidhanamModel>.from(TeluguPujaVidhanamData.get30DefaultPujas());
          }

          // Sort by order
          list.sort((a, b) => a.order.compareTo(b.order));

          // Filter by category & search query
          final filtered = list.where((p) {
            final matchesCat = (_selectedCategory == 'అన్నీ' ||
                p.category == _selectedCategory ||
                (_selectedCategory == 'మందిర పూజ' && (p.category == 'పండుగ పూజ' || p.category == 'నిత్య పూజ')) ||
                (_selectedCategory == 'సాయంత్రం' && (p.title.contains('ప్రదోష') || p.title.contains('హారతి') || p.title.contains('తులసి'))));
            
            final q = _searchQuery.toLowerCase().trim();
            final matchesQuery = q.isEmpty ||
                p.title.toLowerCase().contains(q) ||
                p.deity.toLowerCase().contains(q) ||
                p.shortDesc.toLowerCase().contains(q) ||
                p.tag.toLowerCase().contains(q) ||
                p.samagri.toLowerCase().contains(q);
            return matchesCat && matchesQuery;
          }).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. TOP APP BAR WITH TEMPLE & BELLS BACKGROUND MATCHING SCREENSHOT
              SliverAppBar(
                expandedHeight: 105,
                pinned: true,
                backgroundColor: const Color(0xFF6B111D), // Rich deep maroon
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Header image with temple gopuram & gold bells
                      Image.asset(
                        'assets/images/puja_vidhanam/puja_header_banner.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                        errorBuilder: (_, __, _) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF5A0D17), Color(0xFF88192A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay to guarantee crisp text readability on the left
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF5A0D17).withValues(alpha: 0.95),
                              const Color(0xFF5A0D17).withValues(alpha: 0.70),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                      // Header Texts in Telugu matching screenshot
                      Positioned(
                        left: 56,
                        bottom: 16,
                        right: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'నిత్య పూజా విధానాలు',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'దినచర్యలో చేయదగిన పూజా విధానాలు',
                              style: TextStyle(
                                color: Color(0xFFFFDAB9),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. SEARCH BAR & FILTER TABS (PINNED / FLOATING)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Search Bar with Voice Mic & Red Magnifier Icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE8DCC8),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF7A1B27),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                onChanged: (val) => setState(() => _searchQuery = val),
                                style: const TextStyle(fontSize: 13.5, color: Color(0xFF2C1810)),
                                decoration: const InputDecoration(
                                  hintText: 'పూజ పేరు లేదా దేవుని పేరుతో వెతకండి...',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF8C7A6B),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            // Voice Mic Icon with soft circle background
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9EAE1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.mic_none_rounded,
                                  color: Color(0xFF7A1B27),
                                  size: 20,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('వాయిస్ శోధన త్వరలో అందుబాటులోకి వస్తుంది...'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Tabs matching screenshot
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: _filterTabs.length,
                        itemBuilder: (context, idx) {
                          final tab = _filterTabs[idx];
                          final title = tab['title'] as String;
                          final icon = tab['icon'] as IconData;
                          final isSelected = title == _selectedCategory;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() => _selectedCategory = title);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF6B111D) // Active dark maroon
                                      : const Color(0xFFFDEFD9), // Soft peach pill
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6B111D)
                                        : const Color(0xFFF2DFC4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      icon,
                                      size: 15,
                                      color: isSelected ? Colors.white : const Color(0xFFD35400),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      title,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : const Color(0xFF5A1D24),
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // 3. PUJA CARDS LIST (VERTICAL LIST MATCHING USER SCREENSHOT)
              filtered.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            const Text(
                              'పూజా విధానాలు ఏవీ లభించలేదు.',
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 2, 14, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, idx) {
                            final puja = filtered[idx];
                            return _buildPujaCard(context, puja);
                          },
                          childCount: filtered.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  // Card Widget matching exact design in screenshot:
  // - White card with rounded corners (r=18)
  // - Left: God / Deity Thumbnail Image (w=100, h=82, r=14)
  // - Center:
  //   - Tag chip: [Sun icon] "విఘ్న నివారణ కోసం" (Soft peach-red background)
  //   - Title: "గణపతి పూజ" (Bold maroon 16px)
  //   - Subtitle: "సమస్త కార్య విజయం, విఘ్నాల నివారణకు గణపతి పూజ విధానం."
  //   - Bottom: [Book icon] "5 పూజా విధానాలు"
  // - Right: Circular arrow button (">") in soft cream circle
  Widget _buildPujaCard(BuildContext context, PujaVidhanamModel puja) {
    final tagText = puja.tag.isNotEmpty
        ? puja.tag
        : (puja.deity.isNotEmpty ? '${puja.deity} అనుగ్రహం కోసం' : 'దివ్య పూజ');
    final count = puja.countText > 0 ? puja.countText : (puja.steps.isNotEmpty ? puja.steps.length : 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF1E4CE),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A5A20).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Thumbnail Image on the left
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 98,
                    height: 80,
                    color: const Color(0xFFFFF3DE),
                    child: _buildThumbnail(puja),
                  ),
                ),

                const SizedBox(width: 12),

                // 2. Middle Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tag chip (e.g., [Sun] "విఘ్న నివారణ కోసం")
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDEEE3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.brightness_7_rounded,
                              size: 11,
                              color: Color(0xFFD35400),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                tagText,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB84500),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Puja Title
                      Text(
                        puja.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B1417),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Short Description
                      Text(
                        puja.shortDesc,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B584E),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Book Icon & Count (e.g. [📖] 5 పూజా విధానాలు)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            size: 13,
                            color: Color(0xFFC04B1A),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$count పూజా విధానాలు',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC04B1A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // 3. Right Circular Navigation Arrow Button (">")
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEFD9), // Warm peach circle
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF3DEC0),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF88222F),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(PujaVidhanamModel puja) {
    // 1. If uploaded network image is available in Firestore
    if (puja.imageUrl.isNotEmpty && puja.imageUrl.startsWith('http')) {
      return Image.network(
        puja.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, _) => _buildFallbackAsset(puja),
      );
    }
    // 2. Otherwise use local asset
    return _buildFallbackAsset(puja);
  }

  Widget _buildFallbackAsset(PujaVidhanamModel puja) {
    if (puja.localAssetPath != null && puja.localAssetPath!.isNotEmpty) {
      return Image.asset(
        puja.localAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, _) => const Icon(
          Icons.temple_hindu_rounded,
          color: Color(0xFFD35400),
          size: 38,
        ),
      );
    }
    return const Icon(
      Icons.temple_hindu_rounded,
      color: Color(0xFFD35400),
      size: 38,
    );
  }
}
