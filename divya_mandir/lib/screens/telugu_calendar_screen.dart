import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/panchangam_models.dart';
import '../services/telugu_panchangam_service.dart';

class TeluguCalendarScreen extends StatefulWidget {
  final int initialSubTab; // 0: మాసం, 1: రోజు, 2: పండుగలు, 3: వ్రతాలు
  final bool showAppBar;
  const TeluguCalendarScreen({
    super.key,
    this.initialSubTab = 0,
    this.showAppBar = true,
  });

  @override
  State<TeluguCalendarScreen> createState() => _TeluguCalendarScreenState();
}

class _TeluguCalendarScreenState extends State<TeluguCalendarScreen> {
  final TeluguPanchangamService _service = TeluguPanchangamService();

  late int _selectedTab; // 0: మాసం, 1: రోజు, 2: పండుగలు, 3: వ్రతాలు
  late DateTime _selectedDate;
  late DateTime _displayMonth;

  int _dailyPanchangamSubTab = 0; // 0: పంచాంగం, 1: దిన సమయాలు, 2: శుభ సమయాలు
  String _festivalCategoryFilter = 'అన్నీ'; // అన్నీ, పండుగలు, వ్రతాలు, ప్రత్యేక దినాలు

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialSubTab;
    _selectedDate = DateTime(2026, 10, 21); // Default aligning with sample UI date or now
    // If today is in 2026 or later, can use now or October 2026
    final now = DateTime.now();
    if (now.year == 2026) {
      _selectedDate = now;
    }
    _displayMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final panchangam = _service.calculatePanchangam(_selectedDate);

    if (!widget.showAppBar) {
      return Container(
        color: const Color(0xFFFFFDF8),
        child: _buildCurrentTabView(panchangam),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF7EE),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'తెలుగు క్యాలెండర్',
          style: TextStyle(
            color: Color(0xFF1B2028),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: Color(0xFF6A1B29)),
            tooltip: 'నా క్యాలెండర్ (సేవ్ చేసినవి)',
            onPressed: () => _openBookmarksDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF6A1B29)),
            tooltip: 'పంచాంగం షేర్',
            onPressed: () => _openShareModal(context, panchangam),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF6A1B29)),
            tooltip: 'రిమైండర్లు',
            onPressed: () => _openRemindersDialog(context),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFFFCF7EE),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
            child: Row(
              children: [
                _buildTopTabItem('మాసం', 0),
                _buildTopTabItem('రోజు', 1),
                _buildTopTabItem('పండుగలు', 2),
                _buildTopTabItem('వ్రతాలు', 3),
              ],
            ),
          ),
        ),
      ),
      body: _buildCurrentTabView(panchangam),
    );
  }

  Widget _buildTopTabItem(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            if (index == 3) {
              _festivalCategoryFilter = 'వ్రతాలు';
            } else if (index == 2) {
              _festivalCategoryFilter = 'అన్నీ';
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFF4ECE1),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF4A1A22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabView(DailyPanchangam panchangam) {
    switch (_selectedTab) {
      case 0:
        return _buildMonthlyCalendarView(panchangam);
      case 1:
        return _buildDailyPanchangamView(panchangam);
      case 2:
      case 3:
        return _buildFestivalsAndVratasView();
      default:
        return _buildMonthlyCalendarView(panchangam);
    }
  }

  // ==========================================
  // VIEW 1: మాసం (MONTHLY CALENDAR VIEW)
  // ==========================================
  Widget _buildMonthlyCalendarView(DailyPanchangam panchangam) {
    final monthNameTelugu = _getTeluguMonthName(_displayMonth.month);
    final monthFestivals = _service.getAllFestivalsForMonth(_displayMonth.year, _displayMonth.month);
    final festivalDays = monthFestivals.map((f) => f.date.day).toSet();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Column(
          children: [
            // Month & Year Selector Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF6A1B29), size: 28),
                  onPressed: () => _changeMonth(-1),
                ),
                GestureDetector(
                  onTap: _pickMonthYear,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$monthNameTelugu ${_displayMonth.year}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1810),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6A1B29)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF6A1B29), size: 28),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Weekday Headers (ఆది, సోమ, మంగళ, బుధ, గురు, శుక్ర, శని)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF4EA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Expanded(child: Text('ఆది', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(child: Text('సోమ', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(child: Text('మంగళ', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(child: Text('బుధ', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(child: Text('గురు', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(child: Text('శుక్ర', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(child: Text('శని', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Calendar Days Grid
            _buildDaysGrid(festivalDays),

            const SizedBox(height: 14),

            // Bottom Selected Date Detail Card (Matching Sample Screen 1)
            _buildSelectedDatePreviewCard(panchangam),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysGrid(Set<int> festivalDays) {
    final firstDayOfMonth = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 for Sunday, 1 for Monday...

    final prevMonthDays = DateTime(_displayMonth.year, _displayMonth.month, 0).day;

    List<Widget> dayWidgets = [];

    // Previous month trailing days
    for (int i = startWeekday - 1; i >= 0; i--) {
      final day = prevMonthDays - i;
      dayWidgets.add(
        Center(
          child: Text(
            "$day",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ),
      );
    }

    // Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayMonth.year, _displayMonth.month, day);
      final isSelected = date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final isSunday = date.weekday % 7 == 0;
      final hasFestival = festivalDays.contains(day);

      dayWidgets.add(
        GestureDetector(
          onTap: () => _onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6A1B29) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: const Color(0xFFF1C40F), width: 1.2)
                  : (hasFestival
                      ? Border.all(color: const Color(0xFF6A1B29).withValues(alpha: 0.25), width: 1)
                      : null),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$day",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isSunday ? Colors.red.shade700 : const Color(0xFF1F2937)),
                  ),
                ),
                if (hasFestival)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF1C40F) : const Color(0xFF6A1B29),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.15,
      children: dayWidgets,
    );
  }

  Widget _buildSelectedDatePreviewCard(DailyPanchangam panchangam) {
    final monthNameTelugu = _getTeluguMonthName(panchangam.date.month);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Warm light peach-cream
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1DECB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${panchangam.date.day}",
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$monthNameTelugu ${panchangam.date.year}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1810),
                    ),
                  ),
                  Text(
                    panchangam.dayName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (panchangam.vratamName != null || panchangam.festivalName != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6A1B29).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    panchangam.vratamName ?? panchangam.festivalName!,
                    style: const TextStyle(
                      color: Color(0xFF6A1B29),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 22),

          // Tithi, Nakshatram, Yogam, Karanam Row Items
          _buildPanchangamSummaryRow(Icons.local_fire_department, "తిథి", "${panchangam.paksham} ${panchangam.tithi} ${panchangam.tithiEndTime}"),
          const SizedBox(height: 8),
          _buildPanchangamSummaryRow(Icons.star, "నక్షత్రం", "${panchangam.nakshatram} ${panchangam.nakshatramEndTime}"),
          const SizedBox(height: 8),
          _buildPanchangamSummaryRow(Icons.auto_awesome, "యోగం", "${panchangam.yogam} ${panchangam.yogamEndTime}"),
          const SizedBox(height: 8),
          _buildPanchangamSummaryRow(Icons.flare, "కరణం", "${panchangam.karanam} ${panchangam.karanamEndTime}"),

          const SizedBox(height: 16),

          // CTA Button: నేటి పూర్తి వివరాలు చూడండి →
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFBE4C8),
              foregroundColor: const Color(0xFF6A1B29),
              elevation: 0,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            ),
            onPressed: () {
              setState(() {
                _selectedTab = 1; // switch to daily view
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "నేటి పూర్తి వివరాలు చూడండి",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangamSummaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFE65100)),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1810),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 2: రోజు (DAILY DETAILED PANCHANGAM VIEW)
  // ==========================================
  Widget _buildDailyPanchangamView(DailyPanchangam panchangam) {
    final monthNameTelugu = _getTeluguMonthName(panchangam.date.month);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Date Navigation & Temple Illustration Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            color: const Color(0xFFFCF7EE),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF6A1B29)),
                  onPressed: () {
                    _onDateSelected(_selectedDate.subtract(const Duration(days: 1)));
                  },
                ),
                Column(
                  children: [
                    Text(
                      "${panchangam.date.day} $monthNameTelugu ${panchangam.date.year}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                      ),
                    ),
                    Text(
                      panchangam.dayName,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF6A1B29), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF6A1B29)),
                  onPressed: () {
                    _onDateSelected(_selectedDate.add(const Duration(days: 1)));
                  },
                ),
              ],
            ),
          ),

          // Temple Artwork Banner
          Container(
            height: 110,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1609766857041-ed402ea8069a?q=80&w=1200&auto=format&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4A101C).withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(14),
              alignment: Alignment.bottomLeft,
              child: Text(
                "${panchangam.samvatsaram} • ${panchangam.ayanam}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),

          // 3 Sub-tabs (పంచాంగం, దిన సమయాలు, శుభ సమయాలు)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Row(
              children: [
                _buildDailySubTabButton('పంచాంగం', 0),
                _buildDailySubTabButton('దిన సమయాలు', 1),
                _buildDailySubTabButton('శుభ సమయాలు', 2),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            child: _buildDailySubTabContent(panchangam),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDailySubTabButton(String label, int index) {
    final isSelected = _dailyPanchangamSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _dailyPanchangamSubTab = index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFF0E5D8),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF4A1A22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailySubTabContent(DailyPanchangam panchangam) {
    switch (_dailyPanchangamSubTab) {
      case 0:
        return _buildPanchangamDetailsList(panchangam);
      case 1:
        return _buildDinaSamayaluList(panchangam);
      case 2:
        return _buildShubhaSamayaluList(panchangam);
      default:
        return _buildPanchangamDetailsList(panchangam);
    }
  }

  // 2.A: పంచాంగం డీటైల్స్ లిస్ట్
  Widget _buildPanchangamDetailsList(DailyPanchangam panchangam) {
    return Column(
      children: [
        _buildDetailCard(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange.shade800,
          title: "తిథి",
          value: "${panchangam.paksham} ${panchangam.tithi} ${panchangam.tithiEndTime}",
          subtitle: panchangam.nextTithi != null ? "${panchangam.nextTithi} (తరువాత)" : null,
        ),
        _buildDetailCard(
          icon: Icons.star,
          iconColor: Colors.amber.shade800,
          title: "నక్షత్రం",
          value: "${panchangam.nakshatram} ${panchangam.nakshatramEndTime}",
          subtitle: panchangam.nextNakshatram != null ? "${panchangam.nextNakshatram} (తరువాత)" : null,
        ),
        _buildDetailCard(
          icon: Icons.auto_awesome,
          iconColor: Colors.deepPurple,
          title: "యోగం",
          value: "${panchangam.yogam} ${panchangam.yogamEndTime}",
          subtitle: panchangam.nextYogam != null ? "${panchangam.nextYogam} (తరువాత)" : null,
        ),
        _buildDetailCard(
          icon: Icons.flare,
          iconColor: Colors.red.shade700,
          title: "కరణం",
          value: "${panchangam.karanam} ${panchangam.karanamEndTime}",
          subtitle: panchangam.nextKaranam != null ? "${panchangam.nextKaranam} (తరువాత)" : null,
        ),
        const SizedBox(height: 10),

        // ప్రత్యేకం Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1DECB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ప్రత్యేకం",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
              ),
              const Divider(height: 18),
              if (panchangam.vratamName != null)
                _buildSpecialLine(Icons.notifications_active, "వ్రతం:", panchangam.vratamName!),
              if (panchangam.festivalName != null)
                _buildSpecialLine(Icons.temple_hindu, "పండుగ:", panchangam.festivalName!),
              if (panchangam.specialNote != null)
                _buildSpecialLine(Icons.info, "విశేషం:", panchangam.specialNote!),
              _buildSpecialLine(Icons.alarm, "వర్జ్యం:", panchangam.varjyam),
              _buildSpecialLine(Icons.warning_amber_rounded, "దుర్ముహూర్తం:", panchangam.durmuhurtham),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialLine(IconData icon, String label, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFE65100)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C1810))),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
          ),
        ],
      ),
    );
  }

  // 2.B: దిన సమయాలు (SUN, MOON, RAHUKALAM, CITY)
  Widget _buildDinaSamayaluList(DailyPanchangam panchangam) {
    return Column(
      children: [
        _buildTimingItem(Icons.wb_sunny, Colors.orange, "సూర్యోదయం", panchangam.suryodayam),
        _buildTimingItem(Icons.wb_twighlight, Colors.deepOrange, "సూర్యాస్తమయం", panchangam.suryastamayam),
        _buildTimingItem(Icons.nightlight_round, Colors.indigo, "చంద్రోదయం", panchangam.chandrodayam),
        _buildTimingItem(Icons.bedtime_off, Colors.blueGrey, "చంద్రాస్తమయం", panchangam.chandrastamayam),
        const Divider(height: 16),
        _buildTimingItem(Icons.access_time_filled, Colors.red, "రాహుకాలం", panchangam.rahukalam),
        _buildTimingItem(Icons.timer, Colors.brown, "యమగండం", panchangam.yamagandam),
        _buildTimingItem(Icons.schedule, Colors.purple, "గుళిక కాలం", panchangam.gulikakalam),
        const Divider(height: 16),
        _buildTimingItem(Icons.notifications_active, Colors.green, "అభిజిత్ ముహూర్తం", panchangam.abhijitMuhurtham),
        _buildTimingItem(Icons.local_florist, Colors.teal, "అమృత కాలం", panchangam.amruthaKalam),
        _buildTimingItem(Icons.nights_stay, Colors.blue, "నిశీథ కాలం", panchangam.nishiVaaram),
        const SizedBox(height: 14),

        // City indicator & Change City Button
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1DECB)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFE53935), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "ఈ సమయాలు మీ ప్రాంతం (${panchangam.cityName}) ఆధారంగా చూపబడుతుంది.",
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_location_alt, size: 16, color: Colors.white),
                label: const Text("ప్రాంతం మార్చండి", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B29),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size.fromHeight(38),
                ),
                onPressed: () => _openLocationDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimingItem(IconData icon, Color color, String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
          const Spacer(),
          Text(time, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        ],
      ),
    );
  }

  // 2.C: శుభ సమయాలు & అశుభ సమయాలు
  Widget _buildShubhaSamayaluList(DailyPanchangam panchangam) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "శుభ ముహూర్తాలు",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
        ),
        const SizedBox(height: 8),
        _buildTimingItem(Icons.celebration, Colors.amber.shade800, "వివాహ ముహూర్తం", panchangam.vivahaMuhurtham),
        _buildTimingItem(Icons.home, Colors.teal, "గృహ ప్రవేశం", panchangam.gruhaPravesham),
        _buildTimingItem(Icons.directions_car, Colors.blue, "వాహనం కొనుగోలు", panchangam.vahanaKonugolu),
        _buildTimingItem(Icons.storefront, Colors.indigo, "వ్యాపారం ప్రారంభం", panchangam.vyaparaPrarambham),

        const SizedBox(height: 16),
        const Text(
          "అశుభ సమయాలు",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 8),
        _buildTimingItem(Icons.block, Colors.red, "రాహుకాలం", panchangam.rahukalam),
        _buildTimingItem(Icons.warning, Colors.red.shade700, "యమగండం", panchangam.yamagandam),
        _buildTimingItem(Icons.hourglass_bottom, Colors.deepOrange, "గుళిక కాలం", panchangam.gulikakalam),
        _buildTimingItem(Icons.report_problem, Colors.orange.shade900, "దుర్ముహూర్తం", panchangam.durmuhurtham),
        _buildTimingItem(Icons.timer_off, Colors.purple, "వర్జ్యం", panchangam.varjyam),
      ],
    );
  }

  // ==========================================
  // VIEW 3: పండుగలు & వ్రతాలు (LIST VIEW)
  // ==========================================
  Widget _buildFestivalsAndVratasView() {
    final monthNameTelugu = _getTeluguMonthName(_displayMonth.month);
    final allFestivals = _service.getAllFestivalsForMonth(_displayMonth.year, _displayMonth.month);

    final filtered = allFestivals.where((f) {
      if (_festivalCategoryFilter == 'అన్నీ') return true;
      if (_festivalCategoryFilter == 'పండుగలు') return f.category == 'పండుగ';
      if (_festivalCategoryFilter == 'వ్రతాలు') return f.category == 'వ్రతం';
      if (_festivalCategoryFilter == 'ప్రత్యేక దినాలు') return f.category == 'ప్రత్యేక దినం';
      return true;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Column(
          children: [
            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF6A1B29)),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  "$monthNameTelugu ${_displayMonth.year}",
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF6A1B29)),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Category Filter Chips
            Row(
              children: [
                _buildFestivalCategoryChip('అన్నీ'),
                _buildFestivalCategoryChip('పండుగలు'),
                _buildFestivalCategoryChip('వ్రతాలు'),
                _buildFestivalCategoryChip('ప్రత్యేక దినాలు'),
              ],
            ),
            const SizedBox(height: 12),

            // Festivals List
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    const Text("ఈ నెలలో ఎంపిక చేసిన కేటగిరీలో పండుగలు లేవు.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return _buildFestivalItemCard(item);
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFestivalCategoryChip(String category) {
    final isSelected = _festivalCategoryFilter == category;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _festivalCategoryFilter = category),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFF4ECE1),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            category,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF4A1A22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFestivalItemCard(FestivalItem item) {
    final monthNameTelugu = _getTeluguMonthName(item.date.month);
    final isSelectedDate = item.date.year == _selectedDate.year &&
        item.date.month == _selectedDate.month &&
        item.date.day == _selectedDate.day;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isSelectedDate ? 2 : 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelectedDate ? const Color(0xFFF1C40F) : Colors.grey.shade200,
          width: isSelectedDate ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openVratamDetailScreen(item),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Date Box (e.g. 21 అక్టోబర్)
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelectedDate ? const Color(0xFF6A1B29) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      item.date.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelectedDate ? Colors.white : const Color(0xFFE53935),
                      ),
                    ),
                    Text(
                      monthNameTelugu.replaceAll(' మాసం', ''),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isSelectedDate ? Colors.white70 : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Deity Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.deityImageUrl,
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 46,
                    height: 46,
                    color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                    child: const Icon(Icons.temple_hindu, color: Color(0xFF6A1B29)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A1B29).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              color: Color(0xFF6A1B29),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item.vrataType.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            item.vrataType,
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DETAIL SCREEN: వ్రతం / పండుగ వివరాలు (SCREEN 4)
  // ==========================================
  void _openVratamDetailScreen(FestivalItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _VratamDetailScreen(item: item),
      ),
    );
  }

  // ==========================================
  // LOCATION SELECTION DIALOG (SCREEN 5)
  // ==========================================
  void _openLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return _LocationSelectionDialog(
          cities: _service.popularCities,
          selectedCity: _service.selectedCity,
          onCitySelected: (city) {
            setState(() {
              _service.setSelectedCity(city);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("ప్రాంతం '${city.name}' కి మార్చబడింది. సమయాలు అప్‌డేట్ అయ్యాయి.")),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // REMINDERS SETUP DIALOG (SCREEN 6)
  // ==========================================
  void _openRemindersDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return const _PanchangamRemindersSheet();
      },
    );
  }

  // ==========================================
  // SHARE MODAL (SCREEN 7)
  // ==========================================
  void _openShareModal(BuildContext context, DailyPanchangam p) {
    final monthNameTelugu = _getTeluguMonthName(p.date.month);
    final textToShare = """
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
మీ ఆధ్యాత్మిక ప్రయాణాన్ని ప్రారంభించండి - దివ్య మందిర్ యాప్.
""";

    Share.share(textToShare);
  }

  // ==========================================
  // BOOKMARKS DIALOG (SCREEN 8)
  // ==========================================
  void _openBookmarksDialog(BuildContext context) {
    final bookmarked = _service.getBookmarkedFestivals(_selectedDate.year);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "నా క్యాలెండర్ (సేవ్ చేసినవి)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              if (bookmarked.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text("మీరు ఇంకా ఏ వ్రతాలను లేదా పండుగలను సేవ్ చేయలేదు.", style: TextStyle(color: Colors.grey))),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: bookmarked.length,
                    itemBuilder: (c, i) {
                      final item = bookmarked[i];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.deityImageUrl, width: 40, height: 40, fit: BoxFit.cover),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item.teluguDate),
                        trailing: const Icon(Icons.favorite, color: Colors.red),
                        onTap: () {
                          Navigator.pop(ctx);
                          _openVratamDetailScreen(item);
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

  void _pickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _displayMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _displayMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  String _getTeluguMonthName(int month) {
    const months = [
      'జనవరి', 'ఫిబ్రవరి', 'మార్చి', 'ఏప్రిల్', 'మే', 'జూన్',
      'జూలై', 'ఆగస్టు', 'సెప్టెంబర్', 'అక్టోబర్', 'నవంబర్', 'డిసెంబర్'
    ];
    return months[month - 1];
  }
}

// ==========================================
// VRATAM DETAIL SCREEN (SCREEN 4)
// ==========================================
class _VratamDetailScreen extends StatefulWidget {
  final FestivalItem item;
  const _VratamDetailScreen({required this.item});

  @override
  State<_VratamDetailScreen> createState() => _VratamDetailScreenState();
}

class _VratamDetailScreenState extends State<_VratamDetailScreen> {
  int _activeDetailTab = 0; // 0: వివరాలు, 1: విధానము, 2: ప్రాముఖ్యత

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isBookmarked = TeluguPanchangamService().isFestivalBookmarked(item.id);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.favorite : Icons.favorite_border, color: Colors.white),
            onPressed: () {
              setState(() {
                TeluguPanchangamService().toggleBookmark(item.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isBookmarked ? "బుక్‌మార్క్‌ల నుండి తొలగించబడింది" : "నా క్యాలెండర్‌లో సేవ్ చేయబడింది!"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Share.share("${item.title}\nతేదీ: ${item.teluguDate}\n\n${item.description}\n\nమంత్రం: ${item.mantram}");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Deity Artwork Banner Header
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(item.deityImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(18),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.teluguDate,
                      style: const TextStyle(color: Color(0xFFF1C40F), fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            // Segmented Tabs: వివరాలు, విధానము, ప్రాముఖ్యత
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  _buildSubTabButton("వివరాలు", 0),
                  _buildSubTabButton("విధానము", 1),
                  _buildSubTabButton("ప్రాముఖ్యత", 2),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildDetailContent(item),
            ),

            const SizedBox(height: 24),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B29),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("'${item.title}' కోసం రిమైండర్ ఆన్ చేయబడింది!")),
                  );
                },
                child: const Text(
                  "వ్రతం గురించి రిమైండర్ సెట్ చేయండి",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabButton(String label, int index) {
    final isSelected = _activeDetailTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeDetailTab = index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFF0E5D8),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF4A1A22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(FestivalItem item) {
    if (_activeDetailTab == 0) {
      // వివరాలు
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.description,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF374151)),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.local_fire_department, "తిథి", item.tithi),
          _buildInfoRow(Icons.star, "నక్షత్రం", item.nakshatram),
          _buildInfoRow(Icons.timer, "వ్రత సమయం", item.vrataType),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1DECB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.self_improvement, color: Color(0xFF6A1B29)),
                    SizedBox(width: 8),
                    Text("దివ్య మంత్రం", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6A1B29))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.mantram,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C1810), fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_activeDetailTab == 1) {
      // విధానము
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("పూజా విధానము:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
          const SizedBox(height: 10),
          Text(
            item.poojaVidhanam,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF374151)),
          ),
        ],
      );
    } else {
      // ప్రాముఖ్యత
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("వ్రత విశిష్టత & ప్రాముఖ్యత:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
          const SizedBox(height: 10),
          Text(
            item.significance,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF374151)),
          ),
        ],
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6A1B29)),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1F2937))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13.5, color: Color(0xFF4B5563)))),
        ],
      ),
    );
  }
}

// ==========================================
// LOCATION SELECTION DIALOG (SCREEN 5)
// ==========================================
class _LocationSelectionDialog extends StatefulWidget {
  final List<CityLocation> cities;
  final CityLocation selectedCity;
  final Function(CityLocation) onCitySelected;

  const _LocationSelectionDialog({
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
  });

  @override
  State<_LocationSelectionDialog> createState() => _LocationSelectionDialogState();
}

class _LocationSelectionDialogState extends State<_LocationSelectionDialog> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.cities.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) || c.state.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        height: 520,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "ప్రాంతం ఎంపిక",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: "మీ నగరం లేదా రాష్ట్రం వెతకండి...",
                hintStyle: const TextStyle(fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
            const SizedBox(height: 12),

            // Current Location Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF0ED),
                child: Icon(Icons.my_location, color: Color(0xFFE53935), size: 20),
              ),
              title: const Text("ప్రస్తుత స్థానం ఉపయోగించండి", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              onTap: () {
                widget.onCitySelected(widget.cities.first);
                Navigator.pop(context);
              },
            ),
            const Divider(),

            const Text("ప్రధాన నగరాలు", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 6),

            // Cities List
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final city = filtered[i];
                  final isSelected = city.name == widget.selectedCity.name;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFF0E5D8),
                      child: Text(
                        city.name.substring(0, 1),
                        style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF6A1B29), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text("${city.name} (${city.state})", style: TextStyle(fontSize: 13.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF6A1B29), size: 20) : null,
                    onTap: () {
                      widget.onCitySelected(city);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PANCHANGAM REMINDERS SHEET (SCREEN 6)
// ==========================================
class _PanchangamRemindersSheet extends StatefulWidget {
  const _PanchangamRemindersSheet();

  @override
  State<_PanchangamRemindersSheet> createState() => _PanchangamRemindersSheetState();
}

class _PanchangamRemindersSheetState extends State<_PanchangamRemindersSheet> {
  late List<CalendarReminder> _reminders;

  @override
  void initState() {
    super.initState();
    _reminders = TeluguPanchangamService().getDefaultReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 580,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "పంచాంగం రిమైండర్లు",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Text(
            "సూర్యోదయం, రాహుకాలం మరియు పండుగల సమాచారం నోటిఫికేషన్ ద్వారా పొందండి.",
            style: TextStyle(fontSize: 12.5, color: Colors.black54),
          ),
          const Divider(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (ctx, i) {
                final r = _reminders[i];
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("${r.time} • ${r.description}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  value: r.isEnabled,
                  activeColor: const Color(0xFF6A1B29),
                  onChanged: (val) {
                    setState(() {
                      r.isEnabled = val;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
