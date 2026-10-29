import 'package:flutter/material.dart';
import '../screens/dashboard.dart';
import '../screens/panchangam_screen.dart';
import '../screens/live_darshanam_home_screen.dart';
import '../screens/rashi_palalu_detail_screen.dart';
import '../screens/devalayalu_list_screen.dart';
import '../screens/kathalu_list_screen.dart';
import '../screens/mantra_list_screen.dart';
import '../screens/telugu_calendar_screen.dart';
import '../screens/puja_vidhanam_list_screen.dart';
import '../services/language_service.dart';

class HomeModulesGrid extends StatelessWidget {
  const HomeModulesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Exactly 12 items as shown in the updated UI layout (4 columns x 3 rows)
    final modules = [
      // ROW 1
      _ModuleItem(
        title: LanguageService().isTelugu ? "నిత్య పూజ" : "Daily Pooja",
        bgColor: const Color(0xFFFFF6ED),
        iconColor: const Color(0xFFFF6D00),
        icon: Icons.wb_sunny_rounded,
        customWidget: null,
        onTap: () {
          _showNityaPoojaChoice(context);
        },
      ),
      _ModuleItem(
        title: AppStrings.panchangam,
        bgColor: const Color(0xFFFFECEB),
        iconColor: const Color(0xFFE53935),
        icon: Icons.calendar_month_rounded,
        customWidget: null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PanchangamScreen()),
          );
        },
      ),
      _ModuleItem(
        title: LanguageService().isTelugu ? "భక్తి పాటలు" : "Devotional Songs",
        bgColor: const Color(0xFFFFF0F5),
        iconColor: const Color(0xFFE91E63),
        icon: Icons.music_note_rounded,
        customWidget: null,
        onTap: () {
          DashboardScreen.switchTab(context, 3);
        },
      ),
      _ModuleItem(
        title: AppStrings.devalayalu,
        bgColor: const Color(0xFFFFF9E6),
        iconColor: const Color(0xFFF39C12),
        icon: Icons.temple_hindu_rounded,
        customWidget: null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DevalayaluListScreen()),
          );
        },
      ),

      // ROW 2
      _ModuleItem(
        title: AppStrings.liveDarshanam,
        bgColor: const Color(0xFFFDECEE),
        iconColor: const Color(0xFFE53935),
        icon: Icons.smart_display_rounded,
        customWidget: null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LiveDarshanamHomeScreen()),
          );
        },
      ),
      _ModuleItem(
        title: AppStrings.mantraJapam,
        bgColor: const Color(0xFFF4EEFF),
        iconColor: const Color(0xFF7928CA),
        icon: null,
        customWidget: const Text(
          "ॐ",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7928CA),
            height: 1.0,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MantraListScreen()),
          );
        },
      ),
      _ModuleItem(
        title: AppStrings.puranalu,
        bgColor: const Color(0xFFEBF5FF),
        iconColor: const Color(0xFF1E88E5),
        icon: Icons.menu_book_rounded,
        customWidget: null,
        onTap: () {
          _showModuleDetail(context, AppStrings.puranalu, LanguageService().isTelugu ? "శ్రీమద్భాగవతం, రామాయణం, మహాభారతం గ్రంథాలు త్వరలో..." : "Srimad Bhagavatam, Ramayanam, Mahabharatam books coming soon...");
        },
      ),
      _ModuleItem(
        title: AppStrings.calendar,
        bgColor: const Color(0xFFFFF7EA),
        iconColor: const Color(0xFFFF6D00),
        icon: Icons.calendar_month_rounded,
        customWidget: null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeluguCalendarScreen()),
          );
        },
      ),

      // ROW 3
      _ModuleItem(
        title: AppStrings.rashiPalalu,
        bgColor: const Color(0xFFEAF9F1),
        iconColor: const Color(0xFF00A86B),
        icon: Icons.adjust_rounded,
        customWidget: null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RashiPalaluDetailScreen(initialRashiId: 'mesha')),
          );
        },
      ),
      _ModuleItem(
        title: AppStrings.dhyanam,
        bgColor: const Color(0xFFFFF9E6),
        iconColor: const Color(0xFFD48806),
        icon: Icons.self_improvement_rounded,
        customWidget: null,
        onTap: () {
          _showModuleDetail(context, AppStrings.dhyanam, LanguageService().isTelugu ? "ప్రశాంతమైన మనస్సు కోసం ధ్యాన సాధన త్వరలో..." : "Meditation practices for peaceful mind coming soon...");
        },
      ),
      _ModuleItem(
        title: AppStrings.spiritualKnowledge,
        bgColor: const Color(0xFFFFF4EC),
        iconColor: const Color(0xFFFF6D00),
        icon: Icons.local_fire_department_rounded,
        customWidget: null,
        onTap: () {
          _showModuleDetail(context, AppStrings.spiritualKnowledge, LanguageService().isTelugu ? "ఆధ్యాత్మిక సూక్తులు, భగవద్గీత శ్లోకాలు & వివరణలు త్వరలో..." : "Spiritual quotes, Bhagavad Gita slokas coming soon...");
        },
      ),
      _ModuleItem(
        title: AppStrings.seeMore,
        bgColor: const Color(0xFFFFF0F3),
        iconColor: const Color(0xFFE91E63),
        icon: Icons.grid_view_rounded,
        customWidget: null,
        onTap: () {
          _showMoreCategories(context);
        },
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3ECE0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1 (4 modules)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: modules.sublist(0, 4).map((m) => _buildModuleCard(m)).toList(),
          ),
          const SizedBox(height: 12),

          // Row 2 (4 modules)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: modules.sublist(4, 8).map((m) => _buildModuleCard(m)).toList(),
          ),
          const SizedBox(height: 12),

          // Row 3 (4 modules)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: modules.sublist(8, 12).map((m) => _buildModuleCard(m)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(_ModuleItem item) {
    return Expanded(
      child: GestureDetector(
        onTap: item.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rounded Icon Box matching the modern soft squircle style
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: item.iconColor.withValues(alpha: 0.08),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: item.customWidget ??
                  Icon(
                    item.icon,
                    size: 28,
                    color: item.iconColor,
                  ),
            ),
            const SizedBox(height: 6),

            // Telugu Title
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E242B),
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static void _showModuleDetail(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("సరే (OK)", style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static void _showNityaPoojaChoice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: const Color(0xFFFFFBF4),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "నిత్య పూజ (Daily Pooja Services)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B29),
                ),
              ),
              const SizedBox(height: 16),

              // Option 1: 30 పూజా విధానాలు (Step-by-step Pooja Procedures)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFF1D8B4)),
                ),
                tileColor: Colors.white,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3DE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Color(0xFFE65100), size: 26),
                ),
                title: const Text(
                  "పూజా విధానాలు (30 Pujas)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C1810)),
                ),
                subtitle: const Text(
                  "గణపతి, శివ, లక్ష్మీ, సాయి తదితర 30 దేవుళ్ల సమగ్ర పూజా విధానం & మంత్రాలు",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFE65100)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PujaVidhanamListScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Option 2: లైవ్ వర్చువల్ పూజ (Interactive Mandir Pooja Tab)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFF1D8B4)),
                ),
                tileColor: Colors.white,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFE53935), size: 26),
                ),
                title: const Text(
                  "వర్చువల్ పూజా మందిరం (Interactive Pooja)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C1810)),
                ),
                subtitle: const Text(
                  "హారతి, గంటలు, పూల వర్షం, దీపారాధనలతో డిజిటల్ పూజా మందిరం",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFE53935)),
                onTap: () {
                  Navigator.pop(ctx);
                  DashboardScreen.switchTab(context, 2);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void _showMoreCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "మరిన్ని ఆధ్యాత్మిక విభాగాలు",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Active Feature: నేటి కథ
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFF1D8B4)),
                ),
                tileColor: const Color(0xFFFFF9E6),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD35400),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 24),
                ),
                title: const Text(
                  "నేటి కథ (Daily Sacred Stories)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF6A1B29)),
                ),
                subtitle: const Text(
                  "శ్రీ కృష్ణ లీలలు, రామాయణ, మహాభారత మరియు పురాణ కథల మాలిక",
                  style: TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFD35400)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KathaluListScreen()),
                  );
                },
              ),

              const SizedBox(height: 18),
              const Text("ఇతర విభాగాలు (త్వరలో):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip("గోత్రాలు & ప్రవరలు"),
                  _buildChip("భగవద్గీత శ్లోకాలు"),
                  _buildChip("సుందరకాండ పారాయణ"),
                  _buildChip("శివ సహస్రనామ"),
                  _buildChip("లలితా సహస్రనామ"),
                  _buildChip("హనుమాన్ చాలీసా"),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildChip(String label) {
    return Chip(
      backgroundColor: const Color(0xFFFBF4E8),
      side: const BorderSide(color: Color(0xFFE8D7C0)),
      label: Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF5A141A))),
    );
  }
}

class _ModuleItem {
  final String title;
  final Color bgColor;
  final Color iconColor;
  final IconData? icon;
  final Widget? customWidget;
  final VoidCallback onTap;

  const _ModuleItem({
    required this.title,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    this.customWidget,
    required this.onTap,
  });
}
