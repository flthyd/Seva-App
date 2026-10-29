import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/panchangam_models.dart';
import '../services/telugu_panchangam_service.dart';
import '../screens/panchangam_screen.dart';
import '../services/language_service.dart';

/// A dynamic Home Page Panchangam & Calendar Card matching the exact uploaded UI redesign:
/// - Top Bar: [Om/Swastik/Sun Icon] "నేటి పంచాంగం" with soft peach/gold rounded pill "వివరాలు →"
/// - Middle Row:
///   - Left side: Wall Calendar card with deep maroon top curved banner showing Telugu Day ("బుధవారం"),
///     big day number ("21"), month & year ("అక్టోబర్ 2026"), and Tithi details ("ఆశ్వయుజ శుక్ల పంచమి").
///   - Right side: Clean, elegant 4 vertical rows of Panchanga Angas (తిథి, నక్షత్రం, యోగం, కరణం)
///     with colored circular icons and single-line clean labels.
/// - Bottom Row: 4 Sun & Moon times:
///   - సూర్యోదయం, సూర్యాస్తమయం, చంద్రోదయం, చంద్రాస్తమయం in clean rounded white cards.
/// - Bottom Action Button: Full width soft peach/gold button "దిన సమయాలు & శుభ ముహూర్తాలు →"
class HomeDailyPanchangamCard extends StatelessWidget {
  const HomeDailyPanchangamCard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthNameTelugu = _getTeluguMonthName(now.month);
    final dayNameTelugu = _getTeluguDayName(now.weekday);

    return StreamBuilder<DocumentSnapshot>(
      // Listen to today's panchangam override from Firestore if admin updated special details
      stream: FirebaseFirestore.instance
          .collection('daily_panchangam')
          .doc(DateFormat('yyyy-MM-dd').format(now))
          .snapshots(),
      builder: (context, snapshot) {
        // Calculate dynamic real-time astronomical Panchangam data for today
        final service = TeluguPanchangamService();
        DailyPanchangam p = service.calculatePanchangam(now);

        // Check if admin provided dynamic overrides in Firestore for today
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            p = DailyPanchangam(
              date: p.date,
              dayName: data['dayName'] ?? p.dayName,
              teluguMonth: data['teluguMonth'] ?? p.teluguMonth,
              samvatsaram: data['samvatsaram'] ?? p.samvatsaram,
              ayanam: data['ayanam'] ?? p.ayanam,
              ruthuvu: data['ruthuvu'] ?? p.ruthuvu,
              paksham: data['paksham'] ?? p.paksham,
              tithi: data['tithi'] ?? p.tithi,
              tithiEndTime: data['tithiEndTime'] ?? p.tithiEndTime,
              nextTithi: data['nextTithi'] ?? p.nextTithi,
              nakshatram: data['nakshatram'] ?? p.nakshatram,
              nakshatramEndTime: data['nakshatramEndTime'] ?? p.nakshatramEndTime,
              nextNakshatram: data['nextNakshatram'] ?? p.nextNakshatram,
              yogam: data['yogam'] ?? p.yogam,
              yogamEndTime: data['yogamEndTime'] ?? p.yogamEndTime,
              nextYogam: data['nextYogam'] ?? p.nextYogam,
              karanam: data['karanam'] ?? p.karanam,
              karanamEndTime: data['karanamEndTime'] ?? p.karanamEndTime,
              nextKaranam: data['nextKaranam'] ?? p.nextKaranam,
              suryodayam: data['suryodayam'] ?? p.suryodayam,
              suryastamayam: data['suryastamayam'] ?? p.suryastamayam,
              chandrodayam: data['chandrodayam'] ?? p.chandrodayam,
              chandrastamayam: data['chandrastamayam'] ?? p.chandrastamayam,
              rahukalam: data['rahukalam'] ?? p.rahukalam,
              yamagandam: data['yamagandam'] ?? p.yamagandam,
              gulikakalam: data['gulikakalam'] ?? p.gulikakalam,
              abhijitMuhurtham: data['abhijitMuhurtham'] ?? p.abhijitMuhurtham,
              amruthaKalam: data['amruthaKalam'] ?? p.amruthaKalam,
              nishiVaaram: data['nishiVaaram'] ?? p.nishiVaaram,
              varjyam: data['varjyam'] ?? p.varjyam,
              durmuhurtham: data['durmuhurtham'] ?? p.durmuhurtham,
              vivahaMuhurtham: data['vivahaMuhurtham'] ?? p.vivahaMuhurtham,
              gruhaPravesham: data['gruhaPravesham'] ?? p.gruhaPravesham,
              vahanaKonugolu: data['vahanaKonugolu'] ?? p.vahanaKonugolu,
              vyaparaPrarambham: data['vyaparaPrarambham'] ?? p.vyaparaPrarambham,
              vratamName: data['vratamName'] ?? p.vratamName,
              festivalName: data['festivalName'] ?? p.festivalName,
              specialNote: data['specialNote'] ?? p.specialNote,
              cityName: data['cityName'] ?? p.cityName,
            );
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF3), // Warm divine cream container
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF1E4CE), // Soft golden border
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. TOP HEADER: [Swastik/Divine icon] నేటి పంచాంగం -------- [వివరాలు →]
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Divine Orange/Red Icon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFE65100),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Title
                    const Text(
                      'నేటి పంచాంగం',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B111D),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    // Warm Peach/Gold Pill Button: "వివరాలు →"
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PanchangamScreen(initialDate: now),
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
                          children: const [
                            Text(
                              'వివరాలు',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF752408),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
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

                // 2. MIDDLE ROW: [Tear-off Calendar Card on Left] + [4 Clean Angas on Right]
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LEFT: Wall Calendar Flip Card
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PanchangamScreen(initialDate: now),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: _buildLeftCalendarCard(
                          dayName: dayNameTelugu,
                          dayNumber: now.day.toString(),
                          monthYear: '$monthNameTelugu ${now.year}',
                          subDetails: '${p.teluguMonth.replaceAll(" మాసం", "")} ${p.paksham.replaceAll(" పక్షం", "")}\n${p.tithi}',
                        ),
                      ),

                      const SizedBox(width: 12),

                      // RIGHT: 4 Clean Rows of Panchanga Angas
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 1. తిథి
                            _buildAngaDetailRow(
                              iconWidget: const Icon(Icons.nightlight_round, color: Color(0xFFF59E0B), size: 16),
                              iconBg: const Color(0xFFFFFBEB),
                              title: 'తిథి',
                              content: '${p.paksham.replaceAll(" పక్షం", "")} ${p.tithi} ${p.tithiEndTime}',
                            ),
                            const SizedBox(height: 6),

                            // 2. నక్షత్రం
                            _buildAngaDetailRow(
                              iconWidget: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 17),
                              iconBg: const Color(0xFFFFFBEB),
                              title: 'నక్షత్రం',
                              content: '${p.nakshatram} ${p.nakshatramEndTime}',
                            ),
                            const SizedBox(height: 6),

                            // 3. యోగం
                            _buildAngaDetailRow(
                              iconWidget: const Icon(Icons.self_improvement_rounded, color: Color(0xFFF59E0B), size: 17),
                              iconBg: const Color(0xFFFFFBEB),
                              title: 'యోగం',
                              content: '${p.yogam} ${p.yogamEndTime}',
                            ),
                            const SizedBox(height: 6),

                            // 4. కరణం
                            _buildAngaDetailRow(
                              iconWidget: const Icon(Icons.all_inclusive_rounded, color: Color(0xFFF59E0B), size: 16),
                              iconBg: const Color(0xFFFFFBEB),
                              title: 'కరణం',
                              content: '${p.karanam} ${p.karanamEndTime}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 3. BOTTOM 4 SUN & MOON TIMES: సూర్యోదయం, సూర్యాస్తమయం, చంద్రోదయం, చంద్రాస్తమయం
                Row(
                  children: [
                    // 1. సూర్యోదయం
                    Expanded(
                      child: _buildTimeCard(
                        iconWidget: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFF9800), size: 21),
                        title: 'సూర్యోదయం',
                        time: p.suryodayam,
                      ),
                    ),
                    const SizedBox(width: 6),

                    // 2. సూర్యాస్తమయం
                    Expanded(
                      child: _buildTimeCard(
                        iconWidget: const Icon(Icons.wb_twilight_rounded, color: Color(0xFFFF7043), size: 21),
                        title: 'సూర్యాస్తమయం',
                        time: p.suryastamayam,
                      ),
                    ),
                    const SizedBox(width: 6),

                    // 3. చంద్రోదయం
                    Expanded(
                      child: _buildTimeCard(
                        iconWidget: const Icon(Icons.brightness_medium_rounded, color: Color(0xFF818CF8), size: 20),
                        title: 'చంద్రోదయం',
                        time: p.chandrodayam,
                      ),
                    ),
                    const SizedBox(width: 6),

                    // 4. చంద్రాస్తమయం
                    Expanded(
                      child: _buildTimeCard(
                        iconWidget: const Icon(Icons.nightlight_round, color: Color(0xFFA78BFA), size: 19),
                        title: 'చంద్రాస్తమయం',
                        time: p.chandrastamayam,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 4. BOTTOM FULL-WIDTH BUTTON: "దిన సమయాలు & శుభ ముహూర్తాలు →"
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PanchangamScreen(initialDate: now),
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
                          AppStrings.auspiciousTimings,
                          style: const TextStyle(
                            fontSize: 13.5,
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
      },
    );
  }

  // --- Left Side Tear-off Calendar Card Widget ---
  static Widget _buildLeftCalendarCard({
    required String dayName,
    required String dayNumber,
    required String monthYear,
    required String subDetails,
  }) {
    return Container(
      width: 114,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADCC6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Deep maroon top curved banner with dual hanging rings and Weekday Name
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7A1521), Color(0xFF560812)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Two gold hanging clips/rings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGoldRing(),
                    _buildGoldRing(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dayName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // Calendar Card Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Day number (e.g. 21)
                  Text(
                    dayNumber,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6B111D),
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Month Year (e.g. అక్టోబర్ 2026)
                  Text(
                    monthYear,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2028),
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  // Telugu Month & Tithi details (e.g. ఆశ్వయుజ శుక్ల పంచమి)
                  Text(
                    subDetails,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5565),
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildGoldRing() {
    return Container(
      width: 5,
      height: 7,
      decoration: BoxDecoration(
        color: const Color(0xFFF1C40F),
        borderRadius: BorderRadius.circular(2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }

  // --- Right Side Anga Row Widget ---
  static Widget _buildAngaDetailRow({
    required Widget iconWidget,
    required Color iconBg,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3ECE0), width: 1),
      ),
      child: Row(
        children: [
          // Circle icon
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
          const SizedBox(width: 8),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E242B),
            ),
          ),
          const SizedBox(width: 8),

          // Content
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3F4654),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // --- Bottom Sun & Moon Time Card ---
  static Widget _buildTimeCard({
    required Widget iconWidget,
    required String title,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3ECE0), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 22, child: Center(child: iconWidget)),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5565),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2028),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static String _getTeluguMonthName(int month) {
    const months = [
      'జనవరి', 'ఫిబ్రవరి', 'మార్చి', 'ఏప్రిల్', 'మే', 'జూన్',
      'జూలై', 'ఆగస్టు', 'సెప్టెంబర్', 'అక్టోబర్', 'నవంబర్', 'డిసెంబర్'
    ];
    return months[month - 1];
  }

  static String _getTeluguDayName(int weekday) {
    const days = [
      'సోమవారం', 'మంగళవారం', 'బుధవారం', 'గురువారం',
      'శుక్రవారం', 'శనివారం', 'ఆదివారం'
    ];
    return days[weekday - 1];
  }
}
