import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/live_darshanam_models.dart';
import 'live_darshanam_player_screen.dart';
import 'modern_temple_search_screen.dart';
import 'all_temples_list_screen.dart';

class LiveDarshanamHomeScreen extends StatefulWidget {
  const LiveDarshanamHomeScreen({super.key});

  @override
  State<LiveDarshanamHomeScreen> createState() => _LiveDarshanamHomeScreenState();
}

class _LiveDarshanamHomeScreenState extends State<LiveDarshanamHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  String _selectedStateFilter = 'అన్నీ'; // అన్నీ, తెలంగాణ, ఆంధ్రప్రదేశ్, ఉత్తర భారతదేశం
  String _searchQuery = '';
  final Set<String> _favoriteIds = {};

  // Default Temples Data
  final List<TempleDarshanModel> _defaultTemples = [
    TempleDarshanModel(
      id: 'ttd_tirumala',
      name: 'శ్రీ వేంకటేశ్వర స్వామి',
      templeLocation: 'తిరుమల, తిరుపతి',
      state: 'ఆంధ్రప్రదేశ్',
      youtubeUrl: 'https://www.youtube.com/watch?v=live_ttd_stream',
      bannerImage: 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=800&q=80',
      deityImage: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
      viewerCount: '12.4K',
      isLive: true,
      description: 'కలియుగ ప్రత్యక్ష దైవమైన శ్రీ వేంకటేశ్వర స్వామి వారి పరమ పవిత్ర సన్నిధి.',
    ),
    TempleDarshanModel(
      id: 'srisailam_temple',
      name: 'శ్రీశైలం మల్లికార్జున స్వామి',
      templeLocation: 'శ్రీశైలం',
      state: 'ఆంధ్రప్రదేశ్',
      youtubeUrl: 'https://www.youtube.com/watch?v=live_srisailam_stream',
      bannerImage: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
      deityImage: 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=800&q=80',
      viewerCount: '8.7K',
      isLive: true,
      description: 'ద్వాదశ జ్యోతిర్లింగాలలో మరియు అష్టాదశ శక్తిపీఠాలలో ఒకటైన దివ్య క్షేత్రం.',
    ),
    TempleDarshanModel(
      id: 'bhadrachalam_temple',
      name: 'శ్రీ రాముని స్వామి',
      templeLocation: 'భద్రాచలం',
      state: 'తెలంగాణ',
      youtubeUrl: 'https://www.youtube.com/watch?v=live_bhadrachalam_stream',
      bannerImage: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
      deityImage: 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=800&q=80',
      viewerCount: '6.5K',
      isLive: true,
      description: 'భక్త రామదాసు నిర్మించిన దక్షిణ అయోధ్య శ్రీ సీతారామచంద్ర స్వామి ఆలయం.',
    ),
    TempleDarshanModel(
      id: 'yadadri_temple',
      name: 'శ్రీ లక్ష్మీ నరసింహ స్వామి',
      templeLocation: 'యాదగిరిగుట్ట',
      state: 'తెలంగాణ',
      youtubeUrl: 'https://www.youtube.com/watch?v=live_yadadri_stream',
      bannerImage: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
      deityImage: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
      viewerCount: '5.2K',
      isLive: true,
      description: 'పంచ నారసింహ క్షేత్రమైన యాదగిరిగుట్ట దివ్య పుణ్యక్షేత్రం.',
    ),
    TempleDarshanModel(
      id: 'kanakadurgamma_temple',
      name: 'శ్రీ కనకదుర్గమ్మ దేవాలయం',
      templeLocation: 'విజయవాడ',
      state: 'ఆంధ్రప్రదేశ్',
      youtubeUrl: 'https://www.youtube.com/watch?v=live_durga_stream',
      bannerImage: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
      deityImage: 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=800&q=80',
      viewerCount: '7.8K',
      isLive: true,
      description: 'ఇంద్రకీలాద్రిపై కొలువైన జగన్మాత శ్రీ కనకదుర్గమ్మ దివ్య సన్నిధి.',
    ),
    TempleDarshanModel(
      id: 'kashi_temple',
      name: 'శ్రీ అన్నపూర్ణేశ్వరి & విశ్వనాథ',
      templeLocation: 'కాశీ (వారణాసి)',
      state: 'ఉత్తర భారతదేశం',
      youtubeUrl: 'https://www.youtube.com/watch?v=live_kashi_stream',
      bannerImage: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
      deityImage: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
      viewerCount: '15.1K',
      isLive: true,
      description: 'గంగా నదీ తీరాన వెలసిన పరమేశ్వరుని మోక్ష క్షేత్రం కాశీ విశ్వనాథ్.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('live_darshanam').snapshots(),
      builder: (context, snapshot) {
        List<TempleDarshanModel> temples = [];
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
          temples = snapshot.data!.docs.map((doc) {
            return TempleDarshanModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();
        } else {
          temples = _defaultTemples;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFCF7EE),
          appBar: AppBar(
            backgroundColor: const Color(0xFF6A1B29), // Deep divine maroon
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'లైవ్ దర్శనం',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, size: 24),
                tooltip: 'దేవాలయం వెతకండి',
                onPressed: () => _openSearchScreen(context, temples),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_outline_rounded, size: 23),
                tooltip: 'నా ఇష్టమైనవి',
                onPressed: () => _openFavoritesScreen(context, temples),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 23),
                tooltip: 'సెట్టింగ్స్',
                onPressed: () => _openSettingsScreen(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP HERO FEATURED LIVE BANNER (TTD Venkateswara Swamy / Featured)
                _buildHeroLiveBanner(context, temples.first),

                const SizedBox(height: 14),

                // 2. 4 QUICK ACTION MODULE PILLS (లైవ్ దర్శనం, దేవాలయాలు, హారతులు, సుప్రభాతం)
                _buildQuickActionPills(context, temples),

                const SizedBox(height: 16),

                // 3. ప్రసిద్ధ దేవాలయాలు (Famous Temples Horizontal Carousel)
                _buildSectionHeader(
                  title: 'ప్రసిద్ధ దేవాలయాలు',
                  onMoreTap: () => _openAllTemplesScreen(context, temples),
                ),
                const SizedBox(height: 10),
                _buildFamousTemplesCarousel(context, temples),

                const SizedBox(height: 18),

                // 4. ఇప్పుడు లైవ్‌లో (Active Live Darshan Grid / Cards)
                _buildSectionHeader(
                  title: 'ఇప్పుడు లైవ్‌లో',
                  onMoreTap: () => _openAllTemplesScreen(context, temples),
                ),
                const SizedBox(height: 10),
                _buildNowLiveRow(context, temples),

                const SizedBox(height: 20),

                // 5. దేవాలయాల జాబితా (FILTERABLE TEMPLE LIST: అన్నీ, తెలంగాణ, ఆంధ్రప్రదేశ్, ఉత్తర భారతదేశం)
                _buildFilterableTemplesSection(context, temples),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 1. HERO FEATURED LIVE BANNER ---
  Widget _buildHeroLiveBanner(BuildContext context, TempleDarshanModel temple) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              temple.bannerImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF5A101C)),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Top Left "LIVE" Badge
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2D20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, color: Colors.white, size: 8),
                    SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),

            // Center Play Icon Button
            Center(
              child: GestureDetector(
                onTap: () => _playLive(context, temple),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 10),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF6A1B29),
                    size: 38,
                  ),
                ),
              ),
            ),

            // Bottom Title & Dots
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temple.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${temple.templeLocation} • 👁 ${temple.viewerCount} వీక్షిస్తున్నారు",
                        style: const TextStyle(color: Color(0xFFFDE8C7), fontSize: 12),
                      ),
                    ],
                  ),
                  // Dots
                  Row(
                    children: List.generate(
                      4,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: i == 0 ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == 0 ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(3),
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
  }

  // --- 2. 4 QUICK ACTION MODULE PILLS ---
  Widget _buildQuickActionPills(BuildContext context, List<TempleDarshanModel> temples) {
    final actions = [
      {'title': 'లైవ్ దర్శనం', 'icon': Icons.smart_display_rounded, 'color': const Color(0xFFFF6D00)},
      {'title': 'దేవాలయాలు', 'icon': Icons.temple_hindu_rounded, 'color': const Color(0xFFE53935)},
      {'title': 'హారతులు', 'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFF8E24AA)},
      {'title': 'సుప్రభాతం', 'icon': Icons.wb_twilight_rounded, 'color': const Color(0xFFF39C12)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((act) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (act['title'] == 'దేవాలయాలు') {
                  _openAllTemplesScreen(context, temples);
                } else if (act['title'] == 'హారతులు') {
                  _openAartisScreen(context, temples.first);
                } else if (act['title'] == 'సుప్రభాతం') {
                  _openScheduleScreen(context, temples.first);
                }
              },
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: (act['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: (act['color'] as Color).withValues(alpha: 0.3)),
                    ),
                    child: Icon(act['icon'] as IconData, color: act['color'] as Color, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    act['title'] as String,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2028),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 3. FAMOUS TEMPLES CAROUSEL ---
  Widget _buildFamousTemplesCarousel(BuildContext context, List<TempleDarshanModel> temples) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: temples.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final t = temples[i];
          return GestureDetector(
            onTap: () => _openTempleDetails(context, t),
            child: Column(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFECD8B8), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      t.bannerImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 78,
                  child: Text(
                    t.templeLocation.split(',').first,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 4. NOW LIVE HORIZONTAL ROW ---
  Widget _buildNowLiveRow(BuildContext context, List<TempleDarshanModel> temples) {
    final liveTemples = temples.where((t) => t.isLive).toList();

    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: liveTemples.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, idx) {
          final t = liveTemples[idx];
          return GestureDetector(
            onTap: () => _playLive(context, t),
            child: SizedBox(
              width: 174,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Thumbnail
                  Container(
                    height: 120,
                    width: 174,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
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
                            t.bannerImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF5A101C)),
                          ),
                          // Live pill
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF2D20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "LIVE",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          // Viewers pill
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "👁 ${t.viewerCount}",
                                style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B2028)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    t.templeLocation,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF5B6B79), fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 5. FILTERABLE TEMPLES SECTION (దేవాలయాల సమగ్ర జాబితా) ---
  Widget _buildFilterableTemplesSection(BuildContext context, List<TempleDarshanModel> temples) {
    final filterStates = ['అన్నీ', 'తెలంగాణ', 'ఆంధ్రప్రదేశ్', 'ఉత్తర భారతదేశం'];

    final filtered = temples.where((t) {
      if (_selectedStateFilter == 'అన్నీ') return true;
      return t.state.contains(_selectedStateFilter);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "దేవాలయాల దర్శన సమాచారం",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF5A141A)),
          ),
          const SizedBox(height: 10),

          // State Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterStates.map((st) {
                final isSel = _selectedStateFilter == st;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStateFilter = st),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF6A1B29) : const Color(0xFFEDE4D5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      st,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                        color: isSel ? Colors.white : const Color(0xFF333333),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // List of Filtered Temples
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final t = filtered[idx];
              final isFav = _favoriteIds.contains(t.id);

              return InkWell(
                onTap: () => _openTempleDetails(context, t),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEFE6D6), width: 1),
                  ),
                  child: Row(
                    children: [
                      // Temple Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          t.bannerImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, width: 60, height: 60),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1B2028)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.templeLocation,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF5B6B79)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "LIVE",
                                    style: TextStyle(color: Colors.red, fontSize: 9.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text("👁 ${t.viewerCount}", style: const TextStyle(fontSize: 11, color: Colors.black54)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Fav icon & Chevron
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? Colors.red : Colors.grey,
                          size: 22,
                        ),
                        onPressed: () => _toggleFavorite(t.id),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onMoreTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF5A141A)),
          ),
          InkWell(
            onTap: onMoreTap,
            child: Row(
              children: const [
                Text('మరిన్ని', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF752408))),
                SizedBox(width: 3),
                Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF752408)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NAVIGATION MODALS / SCREENS ---

  void _playLive(BuildContext context, TempleDarshanModel t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveDarshanamPlayerScreen(
          title: t.name,
          templeLocation: t.templeLocation,
          youtubeUrl: t.youtubeUrl,
          viewerCount: t.viewerCount,
        ),
      ),
    );
  }

  // SCREEN 3: TEMPLE DETAILS
  void _openTempleDetails(BuildContext context, TempleDarshanModel t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFDF8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Top Banner with back & fav
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      image: DecorationImage(image: NetworkImage(t.bannerImage), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(t.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5A101C))),
                    const SizedBox(height: 3),
                    Text(t.templeLocation, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 14),

                    // Quick buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _playLive(context, t);
                            },
                            icon: const Icon(Icons.smart_display_rounded, color: Colors.white),
                            label: const Text("లైవ్ దర్శనం", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _buildDetailOptionTile("దర్శన సమయాలు (Schedule)", Icons.schedule_rounded, () {
                      _openScheduleScreen(context, t);
                    }),
                    _buildDetailOptionTile("హారతి వివరాలు (Aartis)", Icons.local_fire_department_rounded, () {
                      _openAartisScreen(context, t);
                    }),
                    _buildDetailOptionTile("పూజా సేవలు (Pooja Sevas)", Icons.all_inclusive_rounded, () {
                      _openPoojaSevasScreen(context, t);
                    }),
                    _buildDetailOptionTile("ప్రసాదం వివరాలు (Prasadam)", Icons.restaurant_rounded, () {
                      _openPrasadamScreen(context, t);
                    }),
                    const SizedBox(height: 12),
                    const Text("క్షేత్ర మహత్యం (About Temple):", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(t.description, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailOptionTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: const Color(0xFFF9EEDD), child: Icon(icon, color: const Color(0xFF6A1B29))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // SCREEN 5: DARSHAN SCHEDULE
  void _openScheduleScreen(BuildContext context, TempleDarshanModel t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCF8F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${t.name} - దర్శనం సమయాలు", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
              const Divider(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: t.schedules.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final s = t.schedules[i];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.circle, color: Color(0xFFE53935), size: 10),
                      title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(s.time, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6A1B29))),
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

  // SCREEN 6: AARTIS & SEVAS
  void _openAartisScreen(BuildContext context, TempleDarshanModel t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCF8F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${t.name} - హారతులు & సేవలు", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
              const Divider(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: t.aartis.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final a = t.aartis[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(a.icon, style: const TextStyle(fontSize: 22)),
                      title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(a.time, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
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

  // SCREEN 7: POOJA SEVAS
  void _openPoojaSevasScreen(BuildContext context, TempleDarshanModel t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCF8F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${t.name} - పూజా సేవలు", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
              const Divider(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: t.poojaSevas.length,
                  itemBuilder: (_, i) {
                    final p = t.poojaSevas[i];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(p.category),
                        trailing: Text("₹ ${p.price}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      ),
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

  // SCREEN 8: PRASADAM BOOKING
  void _openPrasadamScreen(BuildContext context, TempleDarshanModel t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCF8F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${t.name} - దివ్య ప్రసాదాలు", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
              const Divider(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: t.prasadams.length,
                  itemBuilder: (_, i) {
                    final pr = t.prasadams[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.circle, color: Color(0xFFF59E0B), size: 14),
                      title: Text(pr.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("యూనిట్: ${pr.unit}"),
                      trailing: Text("₹ ${pr.price}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6A1B29))),
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

  // SCREEN 12: SEARCH SCREEN
  void _openSearchScreen(BuildContext context, List<TempleDarshanModel> temples) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModernTempleSearchScreen(temples: temples),
      ),
    );
  }

  // SCREEN 9: FAVORITES SCREEN
  void _openFavoritesScreen(BuildContext context, List<TempleDarshanModel> temples) {
    final favs = temples.where((t) => _favoriteIds.contains(t.id)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCF8F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("నా ఇష్టమైన దేవాలయాలు (Favorites)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
              const Divider(height: 16),
              favs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text("ఇంకా ఇష్టమైన దేవాలయాలను జోడించలేదు.")),
                    )
                  : Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: favs.length,
                        itemBuilder: (_, i) {
                          final f = favs[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(f.templeLocation),
                            trailing: const Icon(Icons.play_circle_fill, color: Color(0xFFFF2D20), size: 30),
                            onTap: () {
                              Navigator.pop(ctx);
                              _playLive(context, f);
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

  // SCREEN 13: SETTINGS
  void _openSettingsScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCF8F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("లైవ్ దర్శనం సెట్టింగ్స్", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
              const Divider(height: 16),
              SwitchListTile(
                title: const Text("డేటా సేవర్ మోడ్ (Auto 360p)"),
                value: false,
                onChanged: (v) {},
              ),
              SwitchListTile(
                title: const Text("ఆడియో మాత్రమే ప్లే (Audio Only)"),
                value: false,
                onChanged: (v) {},
              ),
              SwitchListTile(
                title: const Text("లైవ్ నోటిఫికేషన్లు (Live Alerts)"),
                value: true,
                onChanged: (v) {},
              ),
            ],
          ),
        );
      },
    );
  }

  // SCREEN 2: ALL TEMPLES LIST
  void _openAllTemplesScreen(BuildContext context, List<TempleDarshanModel> temples) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllTemplesListScreen(temples: temples),
      ),
    );
  }
}

// Search Delegate for Screen 12
class TempleSearchDelegate extends SearchDelegate {
  final List<TempleDarshanModel> temples;

  TempleSearchDelegate({required this.temples});

  @override
  String get searchFieldLabel => 'దేవాలయం పేరు వెతకండి...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = temples.where((t) {
      final q = query.toLowerCase().trim();
      return t.name.toLowerCase().contains(q) || t.templeLocation.toLowerCase().contains(q);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final t = results[i];
        return ListTile(
          leading: const Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29)),
          title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(t.templeLocation),
          trailing: const Icon(Icons.play_circle_fill, color: Colors.red),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LiveDarshanamPlayerScreen(
                  title: t.name,
                  templeLocation: t.templeLocation,
                  youtubeUrl: t.youtubeUrl,
                  viewerCount: t.viewerCount,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
