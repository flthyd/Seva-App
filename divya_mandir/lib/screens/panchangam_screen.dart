import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../models/panchangam_models.dart';
import '../services/telugu_panchangam_service.dart';
import 'telugu_calendar_screen.dart';

class PanchangamScreen extends StatefulWidget {
  final DateTime? initialDate;
  const PanchangamScreen({super.key, this.initialDate});

  @override
  State<PanchangamScreen> createState() => _PanchangamScreenState();
}

class _PanchangamScreenState extends State<PanchangamScreen> {
  final TeluguPanchangamService _service = TeluguPanchangamService();

  late DateTime _selectedDate;
  int _activeTopTab = 0; // 0: నేటి పంచాంగం, 1: నెలవారీ, 2: పండుగలు, 3: వ్రతాలు, 4: శుభ ముహూర్తాలు

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime(2026, 10, 21);
    final now = DateTime.now();
    if (now.year == 2026 && widget.initialDate == null) {
      _selectedDate = now;
    }
  }

  void _changeDate(int deltaDays) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: deltaDays));
    });
  }

  @override
  Widget build(BuildContext context) {
    final panchangam = _service.calculatePanchangam(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A101C), // Deep divine maroon
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'పంచాంగం',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: false,
        actions: [
          // City Selector Pill
          GestureDetector(
            onTap: () => _openCitySelector(context),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 14, color: Color(0xFFF1C40F)),
                  const SizedBox(width: 4),
                  Text(
                    "${panchangam.cityName}, ${_service.selectedCity.state}",
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white70),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Share Button
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            onPressed: () => _sharePanchangam(panchangam),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Top Navigation Pills Bar
          _buildTopTabsBar(),

          // Main Tab Body
          Expanded(
            child: _buildCurrentTabBody(panchangam),
          ),
        ],
      ),
    );
  }

  // TOP HORIZONTAL PILLS BAR (నేటి పంచాంగం, నెలవారీ, పండుగలు, వ్రతాలు, శుభ ముహూర్తాలు)
  Widget _buildTopTabsBar() {
    final tabs = ['నేటి పంచాంగం', 'నెలవారీ', 'పండుగలు', 'వ్రతాలు', 'శుభ ముహూర్తాలు'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _activeTopTab == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _activeTopTab = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFF2ECE4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF3C2025),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCurrentTabBody(DailyPanchangam panchangam) {
    if (_activeTopTab == 0) {
      return _buildTodayPanchangamView(panchangam);
    } else if (_activeTopTab == 1) {
      return _buildMonthlyView();
    } else if (_activeTopTab == 2) {
      return _buildFestivalsView();
    } else if (_activeTopTab == 3) {
      return _buildVratasView();
    } else {
      return _buildShubhaMuhurthamsView(panchangam);
    }
  }

  // ============================================================
  // TAB 1: నేటి పంచాంగం (MATCHING EXACT UPLOADED IMAGE LAYOUT)
  // ============================================================
  Widget _buildTodayPanchangamView(DailyPanchangam panchangam) {
    final monthNameTelugu = _getTeluguMonthName(panchangam.date.month);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HERO VEDIC BANNER CARD
          _buildHeroBannerCard(panchangam, monthNameTelugu),
          const SizedBox(height: 12),

          // 2. 4 PANCHANGA ANGAS (తిథి, నక్షత్రం, యోగం, కరణం)
          _buildFourAngasGrid(panchangam),
          const SizedBox(height: 12),

          // 3. SOLAR & LUNAR TIMES ROW (సూర్యోదయం, సూర్యాస్తమయం, చంద్రోదయం, చంద్రాస్తమయం)
          _buildSunMoonTimesCard(panchangam),
          const SizedBox(height: 14),

          // 4. దిన సమయాలు (రాహుకాలం, యమగండం, గుళికకాలం, అభిజిత్, బ్రహ్మ ముహూర్తం)
          _buildDinaSamayaluCard(panchangam),
          const SizedBox(height: 14),

          // 5. శుభ ముహూర్తాలు (వివాహం, గృహప్రవేశం, నామకరణం)
          _buildShubhaMuhurthaluCard(panchangam),
          const SizedBox(height: 14),

          // 6. BOTTOM DUAL COLUMNS (నేటి ముఖ్యమైన పండుగలు & నేటి వ్రతాలు)
          _buildBottomFestivalsAndVratamsRow(panchangam),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 1. HERO VEDIC BANNER CARD
  Widget _buildHeroBannerCard(DailyPanchangam panchangam, String monthNameTelugu) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('settings').doc('panchangam_quote').snapshots(),
      builder: (context, snapshot) {
        String samvatsaramText = "శ్రీ విశ్వావసు నామ సంవత్సరం";
        String quoteTitle = "“ఓం నమో వేంకటేశాయ”";
        String quoteSub = "“ధర్మో రక్షతి రక్షితః\nధర్మాన్ని రక్షిస్తే అది మనల్ని కాపాడుతుంది.”";

        if (snapshot.hasData && snapshot.data!.exists) {
          final d = snapshot.data!.data() as Map<String, dynamic>?;
          if (d != null) {
            if (d['samvatsaram'] != null && (d['samvatsaram'] as String).isNotEmpty) {
              samvatsaramText = d['samvatsaram'];
            }
            if (d['quote_title'] != null && (d['quote_title'] as String).isNotEmpty) {
              quoteTitle = d['quote_title'];
            }
            if (d['quote_sub'] != null && (d['quote_sub'] as String).isNotEmpty) {
              quoteSub = d['quote_sub'];
            }
          }
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1609766857041-ed402ea8069a?q=80&w=1200&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A1B29).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF3E0812).withValues(alpha: 0.95),
                  const Color(0xFF5A101C).withValues(alpha: 0.85),
                  const Color(0xFF5A101C).withValues(alpha: 0.50),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 0.80, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Year Title
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFF1C40F), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "$samvatsaramText • ${panchangam.ayanam}",
                      style: const TextStyle(
                        color: Color(0xFFFDE8BA),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // White Date Badge Card
                    Container(
                      width: 105,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            panchangam.dayName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A101C),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${panchangam.date.day}",
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB91C1C),
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "$monthNameTelugu ${panchangam.date.year}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${panchangam.teluguMonth.replaceAll(' మాసం', '')} ${panchangam.paksham.replaceAll(' పక్షం', '')}",
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Quotes & Significance
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quoteTitle,
                            style: const TextStyle(
                              color: Color(0xFFFDE8BA),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            quoteSub,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.white70, size: 24),
                                onPressed: () => _changeDate(-1),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.arrow_circle_right_outlined, color: Colors.white70, size: 24),
                                onPressed: () => _changeDate(1),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. 4 PANCHANGA ANGAS
  Widget _buildFourAngasGrid(DailyPanchangam panchangam) {
    return Row(
      children: [
        _buildAngaCard(
          icon: Icons.nightlight_round,
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          title: "తిథి",
          value: "${panchangam.paksham.replaceAll(' పక్షం', '')} ${panchangam.tithi}",
          time: panchangam.tithiEndTime,
        ),
        const SizedBox(width: 8),
        _buildAngaCard(
          icon: Icons.star_rounded,
          iconBg: const Color(0xFFFFEDD5),
          iconColor: const Color(0xFFEA580C),
          title: "నక్షత్రం",
          value: panchangam.nakshatram,
          time: panchangam.nakshatramEndTime,
        ),
        const SizedBox(width: 8),
        _buildAngaCard(
          icon: Icons.auto_awesome,
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFB45309),
          title: "యోగం",
          value: panchangam.yogam,
          time: panchangam.yogamEndTime,
        ),
        const SizedBox(width: 8),
        _buildAngaCard(
          icon: Icons.flare_rounded,
          iconBg: const Color(0xFFFFEDD5),
          iconColor: const Color(0xFFC2410C),
          title: "కరణం",
          value: panchangam.karanam,
          time: panchangam.karanamEndTime,
        ),
      ],
    );
  }

  Widget _buildAngaCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String time,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, size: 12, color: iconColor),
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7F1D1D), // Dark maroon
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              time,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B7280)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 3. SOLAR & LUNAR TIMES CARD
  Widget _buildSunMoonTimesCard(DailyPanchangam panchangam) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSunMoonCol(Icons.wb_sunny_rounded, Colors.orange, "సూర్యోదయం", panchangam.suryodayam),
          _buildDivider(),
          _buildSunMoonCol(Icons.wb_twilight_rounded, Colors.deepOrange, "సూర్యాస్తమయం", panchangam.suryastamayam),
          _buildDivider(),
          _buildSunMoonCol(Icons.nightlight_round, Colors.indigo, "చంద్రోదయం", panchangam.chandrodayam),
          _buildDivider(),
          _buildSunMoonCol(Icons.bedtime_outlined, Colors.purple, "చంద్రాస్తమయం", panchangam.chandrastamayam),
        ],
      ),
    );
  }

  Widget _buildSunMoonCol(IconData icon, Color color, String title, String time) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(fontSize: 10.5, color: Color(0xFF4B5563))),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 26, color: Colors.grey.shade200);
  }

  // 4. దిన సమయాలు
  Widget _buildDinaSamayaluCard(DailyPanchangam panchangam) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.access_time_filled, color: Color(0xFF6A1B29), size: 18),
                  SizedBox(width: 6),
                  Text(
                    "దిన సమయాలు",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  _showTimingDetailsModal(context, panchangam);
                },
                child: Row(
                  children: const [
                    Text("మరిన్ని వివరాలు", style: TextStyle(fontSize: 11.5, color: Color(0xFF6A1B29), fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 16, color: Color(0xFF6A1B29)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 1: రాహుకాలం, యమగండం, గుళికకాలం
          Row(
            children: [
              _buildSamayamPill(
                icon: Icons.radio_button_checked,
                iconColor: Colors.red,
                bg: const Color(0xFFFFF0ED),
                title: "రాహుకాలం",
                time: panchangam.rahukalam,
              ),
              const SizedBox(width: 8),
              _buildSamayamPill(
                icon: Icons.mood_bad_rounded,
                iconColor: Colors.deepOrange,
                bg: const Color(0xFFFFF5EE),
                title: "యమగండం",
                time: panchangam.yamagandam,
              ),
              const SizedBox(width: 8),
              _buildSamayamPill(
                icon: Icons.self_improvement,
                iconColor: Colors.purple,
                bg: const Color(0xFFF6F0FF),
                title: "గుళికకాలం",
                time: panchangam.gulikakalam,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: అభిజిత్ ముహూర్తం, బ్రహ్మ ముహూర్తం
          Row(
            children: [
              _buildSamayamPill(
                icon: Icons.notifications_active,
                iconColor: Colors.amber.shade800,
                bg: const Color(0xFFFFF9EC),
                title: "అభిజిత్ ముహూర్తం",
                time: panchangam.abhijitMuhurtham,
              ),
              const SizedBox(width: 8),
              _buildSamayamPill(
                icon: Icons.wb_twilight,
                iconColor: Colors.pink,
                bg: const Color(0xFFFFF0F5),
                title: "బ్రహ్మ ముహూర్తం",
                time: "04:20 AM – 05:12 AM",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSamayamPill({
    required IconData icon,
    required Color iconColor,
    required Color bg,
    required String title,
    required String time,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: iconColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              time,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 5. శుభ ముహూర్తాలు
  Widget _buildShubhaMuhurthaluCard(DailyPanchangam panchangam) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_today_rounded, color: Color(0xFF6A1B29), size: 18),
                  SizedBox(width: 6),
                  Text(
                    "శుభ ముహూర్తాలు",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _activeTopTab = 4);
                },
                child: Row(
                  children: const [
                    Text("మరిన్ని", style: TextStyle(fontSize: 11.5, color: Color(0xFF6A1B29), fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 16, color: Color(0xFF6A1B29)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildMuhurthamBox(
                icon: Icons.all_inclusive,
                iconColor: Colors.green,
                bg: const Color(0xFFF0FDF4),
                title: "వివాహ ముహూర్తం",
                time1: "07:12 AM – 08:24 AM",
                time2: "10:36 AM – 11:48 AM",
              ),
              const SizedBox(width: 8),
              _buildMuhurthamBox(
                icon: Icons.home_rounded,
                iconColor: Colors.red,
                bg: const Color(0xFFFFF1F2),
                title: "గృహప్రవేశ ముహూర్తం",
                time1: "09:12 AM – 10:24 AM",
                time2: "01:36 PM – 03:18 PM",
              ),
              const SizedBox(width: 8),
              _buildMuhurthamBox(
                icon: Icons.child_care_rounded,
                iconColor: Colors.purple,
                bg: const Color(0xFFFAF5FF),
                title: "నామకరణ ముహూర్తం",
                time1: "06:24 AM – 07:48 AM",
                time2: "11:12 AM – 12:36 PM",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMuhurthamBox({
    required IconData icon,
    required Color iconColor,
    required Color bg,
    required String title,
    required String time1,
    required String time2,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              time1,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
            ),
            Text(
              time2,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // 6. BOTTOM DUAL COLUMNS (నేటి ముఖ్యమైన పండుగలు & నేటి వ్రతాలు)
  Widget _buildBottomFestivalsAndVratamsRow(DailyPanchangam panchangam) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column 1: పండుగలు
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.temple_hindu, color: Color(0xFFD97706), size: 16),
                      SizedBox(width: 4),
                      Text("నేటి పండుగలు", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _activeTopTab = 2),
                    child: const Text("అన్నీ →", style: TextStyle(fontSize: 11, color: Color(0xFF6A1B29), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildMiniFestivalCard(
                title: "వరలక్ష్మీ వ్రతం",
                badges: ["పండుగ", "వ్రతం"],
                desc: "మహాలక్ష్మీ అమ్మవారిని ఆరాధించే ప్రత్యేక వ్రతం.",
                imageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=600&auto=format&fit=crop',
              ),
              const SizedBox(height: 8),
              _buildMiniFestivalCard(
                title: "సంకష్టహర చతుర్థి",
                badges: ["వ్రతం"],
                desc: "శ్రీ గణపతిని ఆరాధించే శుభదినం.",
                imageUrl: 'https://images.unsplash.com/photo-1608755728617-aefab37d45f6?q=80&w=600&auto=format&fit=crop',
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Column 2: వ్రతాలు
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.spa, color: Color(0xFFD97706), size: 16),
                      SizedBox(width: 4),
                      Text("నేటి వ్రతాలు", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _activeTopTab = 3),
                    child: const Text("అన్నీ →", style: TextStyle(fontSize: 11, color: Color(0xFF6A1B29), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildMiniFestivalCard(
                title: "ప్రదోష వ్రతం",
                badges: ["వ్రతం"],
                desc: "సాయంత్రం శివాన్ని ఆరాధించే శుభదినం.",
                imageUrl: 'https://images.unsplash.com/photo-1608755728617-aefab37d45f6?q=80&w=600&auto=format&fit=crop',
              ),
              const SizedBox(height: 8),
              _buildMiniFestivalCard(
                title: "స్కంద పంచమి",
                badges: ["వ్రతం"],
                desc: "స్కంద (సుబ్రహ్మణ్య స్వామి) ఆరాధనకు శుభదినం.",
                imageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=600&auto=format&fit=crop',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniFestivalCard({
    required String title,
    required List<String> badges,
    required String desc,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 44,
                height: 44,
                color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                child: const Icon(Icons.temple_hindu, color: Color(0xFF6A1B29), size: 22),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: badges.map((b) {
                    return Container(
                      margin: const EdgeInsets.only(right: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        b,
                        style: TextStyle(fontSize: 8.5, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  // ============================================================
  // OTHER SUB TABS (నెలవారీ, పండుగలు, వ్రతాలు, శుభ ముహూర్తాలు)
  // ============================================================
  Widget _buildMonthlyView() {
    return const TeluguCalendarScreen(initialSubTab: 0, showAppBar: false);
  }

  Widget _buildFestivalsView() {
    return const TeluguCalendarScreen(initialSubTab: 2, showAppBar: false);
  }

  Widget _buildVratasView() {
    return const TeluguCalendarScreen(initialSubTab: 3, showAppBar: false);
  }

  Widget _buildShubhaMuhurthamsView(DailyPanchangam panchangam) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "శుభ ముహూర్తాలు (Auspicious Timings)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
          ),
          const SizedBox(height: 12),
          _buildDetailedMuhurthamCard(
            title: "వివాహ ముహూర్తం",
            subtitle: "లగ్న పత్రిక, నిశ్చితార్థం & వివాహ కార్యాలకు శుభం",
            times: ["07:12 AM – 08:24 AM", "10:36 AM – 11:48 AM"],
            icon: Icons.all_inclusive,
            color: Colors.green,
          ),
          _buildDetailedMuhurthamCard(
            title: "గృహప్రవేశం & శంకుస్థాపన",
            subtitle: "నూతన గృహ ప్రవేశం, భూమి పూజకు అనుకూలం",
            times: ["09:12 AM – 10:24 AM", "01:36 PM – 03:18 PM"],
            icon: Icons.home_rounded,
            color: Colors.red,
          ),
          _buildDetailedMuhurthamCard(
            title: "వాహన కొనుగోలు",
            subtitle: "కొత్త వాహనం డెలివరీ & పూజకు శుభ సమయం",
            times: ["01:12 PM – 02:24 PM"],
            icon: Icons.directions_car_rounded,
            color: Colors.blue,
          ),
          _buildDetailedMuhurthamCard(
            title: "వ్యాపార ప్రారంభం & ఒప్పందాలు",
            subtitle: "నూతన వ్యాపారం, దుకాణ ప్రారంభం, ఒప్పందాలకు అనుకూలం",
            times: ["04:36 PM – 05:48 PM"],
            icon: Icons.storefront_rounded,
            color: Colors.amber.shade900,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMuhurthamCard({
    required String title,
    required String subtitle,
    required List<String> times,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: times.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF1DECB)),
                      ),
                      child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCitySelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("ప్రాంతం ఎంచుకోండి", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
          content: SizedBox(
            width: 320,
            height: 380,
            child: ListView.builder(
              itemCount: _service.popularCities.length,
              itemBuilder: (c, i) {
                final city = _service.popularCities[i];
                final isSelected = city.name == _service.selectedCity.name;
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Color(0xFF6A1B29)),
                  title: Text("${city.name} (${city.state})", style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() {
                      _service.setSelectedCity(city);
                    });
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showTimingDetailsModal(BuildContext context, DailyPanchangam p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("దిన సమయాల పూర్తి వివరాలు", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
              const Divider(height: 16),
              Text("సూర్యోదయం: ${p.suryodayam} | సూర్యాస్తమయం: ${p.suryastamayam}"),
              const SizedBox(height: 6),
              Text("చంద్రోదయం: ${p.chandrodayam} | చంద్రాస్తమయం: ${p.chandrastamayam}"),
              const SizedBox(height: 6),
              Text("రాహుకాలం: ${p.rahukalam}"),
              const SizedBox(height: 6),
              Text("యమగండం: ${p.yamagandam}"),
              const SizedBox(height: 6),
              Text("గుళికకాలం: ${p.gulikakalam}"),
              const SizedBox(height: 6),
              Text("అభిజిత్ ముహూర్తం: ${p.abhijitMuhurtham}"),
              const SizedBox(height: 6),
              Text("అమృత కాలం: ${p.amruthaKalam}"),
              const SizedBox(height: 6),
              Text("నిశీథ కాలం: ${p.nishiVaaram}"),
              const SizedBox(height: 14),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("సరే (OK)", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sharePanchangam(DailyPanchangam p) {
    final monthNameTelugu = _getTeluguMonthName(p.date.month);
    final text = """
🌸 శ్రీ దివ్య మందిరం - నేటి పంచాంగం 🌸
📅 తేదీ: ${p.date.day} $monthNameTelugu ${p.date.year} (${p.dayName})
📍 ప్రాంతం: ${p.cityName}

✨ తిథి: ${p.paksham} ${p.tithi} ${p.tithiEndTime}
⭐ నక్షత్రం: ${p.nakshatram} ${p.nakshatramEndTime}
☀️ సూర్యోదయం: ${p.suryodayam} | సూర్యాస్తమయం: ${p.suryastamayam}
⚠️ రాహుకాలం: ${p.rahukalam}
⚠️ యమగండం: ${p.yamagandam}
🌟 అభిజిత్ ముహూర్తం: ${p.abhijitMuhurtham}
${p.vratamName != null ? '🔔 వ్రతం: ${p.vratamName}\n' : ''}${p.festivalName != null ? '🎉 పండుగ: ${p.festivalName}\n' : ''}
దివ్య మందిర్ యాప్ డౌన్‌లోడ్ చేసుకోండి.
""";
    Share.share(text);
  }

  String _getTeluguMonthName(int month) {
    const months = [
      'జనవరి', 'ఫిబ్రవరి', 'మార్చి', 'ఏప్రిల్', 'మే', 'జూన్',
      'జూలై', 'ఆగస్టు', 'సెప్టెంబర్', 'అక్టోబర్', 'నవంబర్', 'డిసెంబర్'
    ];
    return months[month - 1];
  }
}
