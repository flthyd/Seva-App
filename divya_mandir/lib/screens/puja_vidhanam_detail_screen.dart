import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/puja_vidhanam_model.dart';

class PujaVidhanamDetailScreen extends StatefulWidget {
  final PujaVidhanamModel puja;

  const PujaVidhanamDetailScreen({
    super.key,
    required this.puja,
  });

  @override
  State<PujaVidhanamDetailScreen> createState() => _PujaVidhanamDetailScreenState();
}

class _PujaVidhanamDetailScreenState extends State<PujaVidhanamDetailScreen> {
  int _selectedTab = 0; // 0: పరిచయం, 1: సామగ్రి, 2: విధానం, 3: మంత్రాలు, 4: ప్రయోజనాలు
  bool _isFavorite = false;

  final List<Map<String, dynamic>> _tabs = const [
    {'title': 'పరిచయం', 'icon': Icons.description_outlined},
    {'title': 'సామగ్రి', 'icon': Icons.layers_outlined},
    {'title': 'విధానం', 'icon': Icons.format_list_bulleted_rounded},
    {'title': 'మంత్రాలు', 'icon': Icons.local_fire_department_outlined},
    {'title': 'ప్రయోజనాలు', 'icon': Icons.star_border_rounded},
  ];

  void _sharePuja() {
    final text = "🙏 *${widget.puja.title}* 🙏\n\n"
        "${widget.puja.shortDesc}\n\n"
        "ఉత్తమ సమయాలు: ${widget.puja.auspiciousDays}\n\n"
        "📌 *పూజా సామగ్రి:*\n${widget.puja.samagri}\n\n"
        "📖 *పూజా విధానం:*\n${widget.puja.fullVidhanam}\n\n"
        "దివ్య మందిరం (Divya Mandir) భక్తి యాప్ నుండి పొందండి.";
    // ignore: deprecated_member_use
    Share.share(text);
  }

  void _showFullVidhanamDialog(BuildContext context, [String? stepTitle]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      stepTitle ?? "${widget.puja.title} - పూర్తి పూజా విధానం",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B111D),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                widget.puja.fullVidhanam.isNotEmpty
                    ? widget.puja.fullVidhanam
                    : "విధానం వివరాలు త్వరలో నమోదు చేయబడతాయి.",
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF2C1810),
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final puja = widget.puja;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EE), // Cream white divine background
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. TOP HERO IMAGE BANNER (WITH BACK, HEART, SHARE ICONS)
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: const Color(0xFF6B111D),
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.redAccent : Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _isFavorite = !_isFavorite);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isFavorite ? 'ఇష్టమైన పూజలలో చేర్చబడింది' : 'ఇష్టమైన పూజల నుండి తొలగించబడింది'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8, right: 12, left: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                      onPressed: _sharePuja,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildHeroImage(puja),
                      // Top gradient for status bar icons
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                          ),
                        ),
                      ),
                      // Curved bottom white cap matching user screenshot
                      Positioned(
                        bottom: -1,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFBF6EE),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. MAIN CONTENT BODY
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE HEADER WITH OM CIRCLE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Om Badge Circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF68B1F), // Bright auspicious orange/gold
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'ॐ',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  puja.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B111D),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  puja.shortDesc,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF553C35),
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 3 INFO BADGES ROW (5 పూజా విధానాలు, సుమారు 20-30 నిమిషాలు, ఎవరైనా చేయవచ్చు)
                      Row(
                        children: [
                          _buildInfoBadge(
                            icon: Icons.menu_book_rounded,
                            text: '${puja.countText} పూజా విధానాలు',
                          ),
                          const SizedBox(width: 6),
                          _buildInfoBadge(
                            icon: Icons.access_time_rounded,
                            text: puja.duration,
                          ),
                          const SizedBox(width: 6),
                          _buildInfoBadge(
                            icon: Icons.people_alt_rounded,
                            text: puja.targetAudience,
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 5 TAB PILLS (పరిచయం, సామగ్రి, విధానం, మంత్రాలు, ప్రయోజనాలు)
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEFE4D2)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Row(
                          children: List.generate(_tabs.length, (idx) {
                            final tab = _tabs[idx];
                            final isSel = _selectedTab == idx;
                            return Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => setState(() => _selectedTab = idx),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSel ? const Color(0xFF6B111D) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        tab['icon'] as IconData,
                                        size: 16,
                                        color: isSel ? Colors.white : const Color(0xFF5A1D24),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        tab['title'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                          color: isSel ? Colors.white : const Color(0xFF5A1D24),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // DYNAMIC CONTENT BASED ON SELECTED TAB
                      _buildSelectedTabContent(context, puja),

                      const SizedBox(height: 90), // Bottom padding for sticky button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. STICKY BOTTOM BUTTON: [Diya Icon] "పూజా విధానం చదవండి >"
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B111D), // Rich deep maroon
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF6B111D).withValues(alpha: 0.35),
                  ),
                  onPressed: () => _showFullVidhanamDialog(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'పూజా విధానం చదవండి',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent(BuildContext context, PujaVidhanamModel puja) {
    switch (_selectedTab) {
      case 0:
        return _buildParichayamTab(context, puja);
      case 1:
        return _buildSamagriTab(puja);
      case 2:
        return _buildVidhanamTab(context, puja);
      case 3:
        return _buildMantraluTab(puja);
      case 4:
        return _buildPrayojanaluTab(puja);
      default:
        return _buildParichayamTab(context, puja);
    }
  }

  // TAB 0: పూజా పరిచయం (Matches User Screenshot Exactly)
  Widget _buildParichayamTab(BuildContext context, PujaVidhanamModel puja) {
    final parichayamText = puja.parichayam.isNotEmpty
        ? puja.parichayam
        : "${puja.title} విశిష్టమైన పూజ. సకల విఘ్నాలను తొలగించి కార్యసిద్ధిని ప్రసాదిస్తుంది. సర్వ మంగళాలను, ఆయురారోగ్యాలను ప్రసాదించే దివ్య పూజా విధానం.";

    final times = puja.favorableTimes.isNotEmpty
        ? puja.favorableTimes
        : [
            'చవితి తిథి (ప్రత్యేక ఫలితం)',
            'ప్రతి రోజు ఉదయం శుభ సమయం',
            'శుభకార్యాల ప్రారంభంలో',
            'గృహప్రవేశం, విద్యారంభం, వాహన పూజ మొదలైనప్పుడు',
          ];

    final subList = puja.subVidhanalu.isNotEmpty
        ? puja.subVidhanalu
        : [
            SubVidhanamItem(
              number: 1,
              title: 'సాధారణ ${puja.title}',
              subtitle: 'ఇంట్లో ప్రతి రోజు చేసే సరళమైన పూజ',
              localImage: 'assets/images/puja_vidhanam/sub_vidhanam_1.png',
            ),
            SubVidhanamItem(
              number: 2,
              title: 'సంకటహర చతుర్థీ పూజ',
              subtitle: 'విఘ్న నివారణ కోసం చేసే పూజ',
              localImage: 'assets/images/puja_vidhanam/sub_vidhanam_2.png',
            ),
            SubVidhanamItem(
              number: 3,
              title: '${puja.title} అష్టోత్తర శతనామ పూజ',
              subtitle: '108 నామాలతో చేసే విశిష్ట పూజ',
              localImage: 'assets/images/puja_vidhanam/sub_vidhanam_3.png',
            ),
            SubVidhanamItem(
              number: 4,
              title: 'ప్రత్యేక నైవేద్య పూజ',
              subtitle: 'మహానైవేద్యంతో చేసే పూజ',
              localImage: 'assets/images/puja_vidhanam/sub_vidhanam_4.png',
            ),
            SubVidhanamItem(
              number: 5,
              title: '${puja.title} హోమ విధానం',
              subtitle: 'హోమం చేసే సమగ్ర విధానం',
              localImage: 'assets/images/puja_vidhanam/sub_vidhanam_5.png',
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. "పూజా పరిచయం" CARD WITH EMBEDDED SIDE PHOTO
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1E4CE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title with underline accent
              const Text(
                'పూజా పరిచయం',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B111D),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 30,
                height: 2.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE88A22),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              // Text + Side Image
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      parichayamText,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF2C1810),
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 95,
                      height: 88,
                      color: const Color(0xFFFFF3DE),
                      child: Image.asset(
                        'assets/images/puja_vidhanam/ganapati_parichayam.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackThumbnail(puja),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. "పూజ చేయడానికి అనుకూల సమయాలు" CARD WITH CALENDAR ICON
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF1E6), // Peach-cream soft background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF2DFC8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_month_rounded, color: Color(0xFFB83A20), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'పూజ చేయడానికి అనుకూల సమయాలు',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B111D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...times.map(
                (time) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          color: Color(0xFFC0392B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF3E2723),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. "పూజా విధానాల జాబితా" SECTION HEADER WITH LIST ICON
        Row(
          children: const [
            Icon(Icons.format_list_bulleted_rounded, color: Color(0xFF6B111D), size: 20),
            SizedBox(width: 8),
            Text(
              'పూజా విధానాల జాబితా',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B111D),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 4. SUB-VIDHANALU TILES LIST (1 TO 5 TILES MATCHING SCREENSHOT)
        ...subList.map((item) => _buildSubVidhanamTile(context, item)),
      ],
    );
  }

  // Sub-Vidhanam Tile Item Widget (1, 2, 3, 4, 5 numbered badges)
  Widget _buildSubVidhanamTile(BuildContext context, SubVidhanamItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1E4CE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showFullVidhanamDialog(context, item.title),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // Small preview image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 62,
                    height: 48,
                    color: const Color(0xFFFFF3DE),
                    child: item.localImage != null
                        ? Image.asset(
                            item.localImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallbackThumbnail(widget.puja),
                          )
                        : _buildFallbackThumbnail(widget.puja),
                  ),
                ),

                const SizedBox(width: 10),

                // Orange circular number badge
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF68B1F),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${item.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B1417),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B584E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Right navigation chevron in soft circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEFD9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF3DEC0)),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF88222F),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TAB 1: పూజా సామగ్రి
  Widget _buildSamagriTab(PujaVidhanamModel puja) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1E4CE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.layers_rounded, color: Color(0xFF6B111D), size: 20),
              SizedBox(width: 8),
              Text(
                'కావలసిన పూజా సామగ్రి',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6B111D)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            puja.samagri.isNotEmpty ? puja.samagri : "పూజా సామగ్రి వివరాలు త్వరలో...",
            style: const TextStyle(fontSize: 14, color: Color(0xFF2C1810), height: 1.6),
          ),
        ],
      ),
    );
  }

  // TAB 2: విధానం (షోడశోపచారాలు)
  Widget _buildVidhanamTab(BuildContext context, PujaVidhanamModel puja) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1E4CE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'పూర్తి పూజా విధానం',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6B111D)),
              ),
              TextButton(
                onPressed: () => _showFullVidhanamDialog(context),
                child: const Text('వివరంగా చదవండి →'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            puja.fullVidhanam.isNotEmpty ? puja.fullVidhanam : "విధానం వివరాలు త్వరలో...",
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF2C1810), height: 1.6),
          ),
        ],
      ),
    );
  }

  // TAB 3: మంత్రాలు
  Widget _buildMantraluTab(PujaVidhanamModel puja) {
    final mantraText = puja.mantralu.isNotEmpty
        ? puja.mantralu
        : "ఓం గం గణపతయే నమః\nవక్రతుండ మహాకాయ సూర్యకోటి సమప్రభ | నిర్విఘ్నం కురు మే దేవ సర్వకార్యేషు సర్వదా ||";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1D8B4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.local_fire_department_rounded, color: Color(0xFFD35400), size: 20),
              SizedBox(width: 8),
              Text(
                'ముఖ్యమైన పూజా మంత్రాలు',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6B111D)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mantraText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A1016),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 4: ప్రయోజనాలు
  Widget _buildPrayojanaluTab(PujaVidhanamModel puja) {
    final benefitText = puja.prayojanalu.isNotEmpty
        ? puja.prayojanalu
        : "1. సమస్త కార్యసిద్ధి మరియు విఘ్నాల నివారణ.\n2. విద్యా, బుద్ధి, ఆయుష్షు, సంపద మరియు మోక్ష ప్రాప్తి.\n3. గృహంలో శాంతి మరియు శుభ ఫలితాలు.\n4. గ్రహ దోషాల నివారణ.";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1E4CE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.star_rounded, color: Color(0xFFF39C12), size: 20),
              SizedBox(width: 8),
              Text(
                'పూజా ఫలితాలు & ప్రయోజనాలు',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6B111D)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            benefitText,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF2C1810), height: 1.6),
          ),
        ],
      ),
    );
  }

  // Top Hero Image Builder
  Widget _buildHeroImage(PujaVidhanamModel puja) {
    if (puja.heroBannerAsset != null && puja.heroBannerAsset!.isNotEmpty) {
      return Image.asset(
        puja.heroBannerAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackHero(puja),
      );
    }
    return _buildFallbackHero(puja);
  }

  Widget _buildFallbackHero(PujaVidhanamModel puja) {
    if (puja.imageUrl.isNotEmpty && puja.imageUrl.startsWith('http')) {
      return Image.network(
        puja.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultBannerGradient(),
      );
    }
    if (puja.localAssetPath != null && puja.localAssetPath!.isNotEmpty) {
      return Image.asset(
        puja.localAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultBannerGradient(),
      );
    }
    return _buildDefaultBannerGradient();
  }

  Widget _buildDefaultBannerGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5A0D17), Color(0xFF88192A), Color(0xFF3B070E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Icon(Icons.temple_hindu_rounded, size: 70, color: Color(0xFFFFD59E)),
      ),
    );
  }

  Widget _buildFallbackThumbnail(PujaVidhanamModel puja) {
    if (puja.localAssetPath != null && puja.localAssetPath!.isNotEmpty) {
      return Image.asset(
        puja.localAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.temple_hindu_rounded, color: Color(0xFFD35400)),
      );
    }
    return const Icon(Icons.temple_hindu_rounded, color: Color(0xFFD35400));
  }

  // Info Badge Helper (Pill with yellow/peach background)
  Widget _buildInfoBadge({required IconData icon, required String text}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF0DF), // Soft warm peach
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF6DEC4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: const Color(0xFFD35400)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A2818),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
