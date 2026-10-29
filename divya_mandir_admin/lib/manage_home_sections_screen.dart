import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_home_banners_screen.dart';
import 'manage_music_screen.dart';
import 'manage_pooja_tools_screen.dart';
import 'manage_calendar_screen.dart';
import 'manage_live_darshanam_screen.dart';
import 'manage_rashi_palalu_screen.dart';
import 'manage_devalayalu_screen.dart';
import 'manage_neti_katha_screen.dart';
import 'manage_mantra_japam_screen.dart';
import 'manage_puja_vidhanam_screen.dart';

class ManageHomeSectionsScreen extends StatelessWidget {
  const ManageHomeSectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Description
            const Text(
              "Home Page Sections & Modules Management",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B29),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Manage, customize and control all sections and 10 categories displayed on the Mobile App Home Page.",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Mini Horizontal Grid of Home Sections (70% decreased size)
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 370,
                  mainAxisExtent: 74, // Compact mini horizontal card
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 12,
                ),
                children: [
                  // 1. BANNER SECTION (Active)
                  _buildBannerMiniCard(context),

                  // 2. నిత్య పూజ (Daily Pooja)
                  _buildModuleMiniCard(
                    context: context,
                    title: "నిత్య పూజ (Daily Pooja)",
                    subtitle: "Virtual pooja, harathi & mandir tools",
                    icon: Icons.wb_sunny_rounded,
                    iconColor: const Color(0xFFFF6B00),
                    bgColor: const Color(0xFFFFF5E5),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManagePoojaToolsScreen()),
                      );
                    },
                  ),

                  // 3. పంచాంగం (Panchangam)
                  _buildModuleMiniCard(
                    context: context,
                    title: "పంచాంగం (Panchangam)",
                    subtitle: "Daily Tithi, Vaaram & auspicious times",
                    icon: Icons.calendar_month_rounded,
                    iconColor: const Color(0xFFFF2D20),
                    bgColor: const Color(0xFFFFEFEB),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageCalendarScreen()),
                      );
                    },
                  ),

                  // 4. భక్తి పాటలు (Devotional Songs)
                  _buildModuleMiniCard(
                    context: context,
                    title: "భక్తి పాటలు (Bhakti Music)",
                    subtitle: "Stotrams, songs, suktams & audio player",
                    icon: Icons.music_note_rounded,
                    iconColor: const Color(0xFFE91E63),
                    bgColor: const Color(0xFFFFF0F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageMusicScreen()),
                      );
                    },
                  ),

                  // 5. మంత్ర జపం (Mantra Japam)
                  _buildModuleMiniCard(
                    context: context,
                    title: "మంత్ర జపం (Mantra Chanting)",
                    subtitle: "Omkar, Gayatri & sacred chants counter",
                    icon: null,
                    customIconWidget: const Text(
                      "ॐ",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7928CA),
                      ),
                    ),
                    iconColor: const Color(0xFF7928CA),
                    bgColor: const Color(0xFFF5EEFF),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageMantraJapamScreen()),
                      );
                    },
                  ),

                  // 5B. పూజా విధానం (Puja Vidhanam - ACTIVE CONTROL)
                  _buildModuleMiniCard(
                    context: context,
                    title: "పూజా విధానం (30 Puja Vidhanam)",
                    subtitle: "Manage 30 Telugu deities pooja procedures & samagri",
                    icon: Icons.temple_hindu_rounded,
                    iconColor: const Color(0xFFD35400),
                    bgColor: const Color(0xFFFFF3DE),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManagePujaVidhanamScreen()),
                      );
                    },
                  ),

                  // 6. దేవాలయాలు (Temples - ACTIVE CONTROL)
                  _buildModuleMiniCard(
                    context: context,
                    title: "దేవాలయాలు (Temples Directory)",
                    subtitle: "Manage temples, stories, online bookings & routes",
                    icon: Icons.temple_hindu_rounded,
                    iconColor: const Color(0xFFE67E22),
                    bgColor: const Color(0xFFFFF8E1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageDevalayaluScreen()),
                      );
                    },
                  ),

                  // 7. నేటి కథ (Neti Katha - ACTIVE CONTROL)
                  _buildModuleMiniCard(
                    context: context,
                    title: "నేటి కథ (Daily Sacred Stories)",
                    subtitle: "Manage daily stories, morals, images & archive",
                    icon: Icons.auto_stories_rounded,
                    iconColor: const Color(0xFFD35400),
                    bgColor: const Color(0xFFFFF3E0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageNetiKathaScreen()),
                      );
                    },
                  ),

                  // 7. లైవ్ దర్శనం (Live Darshan - ACTIVE CONTROL)
                  _buildModuleMiniCard(
                    context: context,
                    title: "లైవ్ దర్శనం (Live Darshan)",
                    subtitle: "Manage YouTube live feeds, cards & status",
                    icon: Icons.videocam_rounded,
                    iconColor: const Color(0xFFE53935),
                    bgColor: const Color(0xFFFFF0ED),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageLiveDarshanamScreen()),
                      );
                    },
                  ),

                  // 8. పురాణాలు (Puranas & Scriptures)
                  _buildModuleMiniCard(
                    context: context,
                    title: "పురాణాలు (Sacred Scriptures)",
                    subtitle: "Ramayana, Mahabharata & Bhagavatam",
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF007AFF),
                    bgColor: const Color(0xFFEAF4FF),
                    onTap: () {
                      _showModuleConfigDialog(
                        context,
                        "పురాణాలు (Sacred Scriptures)",
                        "Telugu holy scriptures, puranas, slokas with meaning and spiritual books.",
                        "puranas",
                      );
                    },
                  ),

                  // 9. వ్రతాలు (Vratams & Katha)
                  _buildModuleMiniCard(
                    context: context,
                    title: "వ్రతాలు (Vratams & Rituals)",
                    subtitle: "Vrata stories, pooja vidhi & dates",
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFFF6600),
                    bgColor: const Color(0xFFFFF6E6),
                    onTap: () {
                      _showModuleConfigDialog(
                        context,
                        "వ్రతాలు (Vratams & Rituals)",
                        "Ekadashi, Satyanarayana Vratam, Sankashti & festive fasting guidelines.",
                        "vratams",
                      );
                    },
                  ),

                  // 10. రాశిఫలాలు (Astrology & Rashi Palalu - ACTIVE CONTROL)
                  _buildModuleMiniCard(
                    context: context,
                    title: "రాశిఫలాలు (Rashi Palalu & API)",
                    subtitle: "Daily, weekly, yearly rashiphal & Prokerala API",
                    icon: Icons.brightness_7_rounded,
                    iconColor: const Color(0xFFE65100),
                    bgColor: const Color(0xFFFFF4EC),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageRashiPalaluScreen()),
                      );
                    },
                  ),

                  // 11. ధ్యానం & జపం (Meditation)
                  _buildModuleMiniCard(
                    context: context,
                    title: "ధ్యానం & జపం (Meditation)",
                    subtitle: "Peaceful ambient sounds & guided dhyana",
                    icon: Icons.spa_rounded,
                    iconColor: const Color(0xFF00A86B),
                    bgColor: const Color(0xFFEBF9F1),
                    onTap: () {
                      _showModuleConfigDialog(
                        context,
                        "ధ్యానం & జపం (Meditation)",
                        "Spiritual meditation timer, relaxing bells and Vedic chanting sounds.",
                        "meditation",
                      );
                    },
                  ),

                  // 11. మరిన్ని (More Categories)
                  _buildModuleMiniCard(
                    context: context,
                    title: "మరిన్ని సేవలు (More Services)",
                    subtitle: "Wallpapers, status & more features",
                    icon: Icons.grid_view_rounded,
                    iconColor: const Color(0xFFD81B60),
                    bgColor: const Color(0xFFFFF0F5),
                    onTap: () {
                      _showModuleConfigDialog(
                        context,
                        "మరిన్ని సేవలు (More Services)",
                        "Additional devotee services, status wallpapers, donation and community.",
                        "more_services",
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mini Horizontal Card for Banners
  Widget _buildBannerMiniCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('home_banners').snapshots(),
      builder: (context, snapshot) {
        int totalBanners = 0;
        int activeBanners = 0;
        if (snapshot.hasData) {
          totalBanners = snapshot.data!.docs.length;
          activeBanners = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['is_active'] != false;
          }).length;
        }

        return Card(
          elevation: 1.5,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF6A1B29), width: 1.5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageHomeBannersScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.view_carousel_rounded,
                      size: 24,
                      color: Color(0xFF6A1B29),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Hero Banners Section",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B29),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$activeBanners Active / $totalBanners Total Banners",
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "Manage",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.chevron_right, size: 14, color: Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Mini Horizontal Card for General Modules
  Widget _buildModuleMiniCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    IconData? icon,
    Widget? customIconWidget,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0.8,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: customIconWidget ??
                    Icon(
                      icon,
                      size: 24,
                      color: iconColor,
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E242B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B29).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Setup",
                      style: TextStyle(
                        color: Color(0xFF6A1B29),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF6A1B29)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Module Configuration Dialog
  void _showModuleConfigDialog(
    BuildContext context,
    String title,
    String description,
    String moduleId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B29),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(fontSize: 13.5, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "ఈ మాడ్యూల్‌కు సంబంధించిన డీటెయిల్డ్ ఫీచర్స్ మరియు ఫంక్షనాలిటీ కంట్రోల్స్ తర్వాతి స్టెప్‌లో యాడ్ చేయబడతాయి.",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B29),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("సరే (OK)", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

