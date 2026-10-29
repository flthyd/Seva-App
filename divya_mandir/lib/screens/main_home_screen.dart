import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'language_selection_screen.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/home_modules_grid.dart';
import '../widgets/home_daily_panchangam_card.dart';
import '../widgets/home_live_darshanam_section.dart';
import '../widgets/home_rashi_palalu_section.dart';
import '../widgets/home_devalayalu_section.dart';
import '../widgets/home_neti_katha_section.dart';
import '../widgets/home_mantra_japam_section.dart';
import '../widgets/home_puja_vidhanam_section.dart';
import '../widgets/home_devotional_store_section.dart';
import '../services/language_service.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return AppStrings.subhodayam;
    } else if (hour >= 12 && hour < 16) {
      return AppStrings.subhaMadhyahnam;
    } else if (hour >= 16 && hour < 21) {
      return AppStrings.subhaSayantram;
    } else {
      return AppStrings.subhaRatri;
    }
  }

  Widget _buildCircleButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15), // Translucent white pill
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    const maroonNavColor = Color(0xFF6A0F1A); // Exact rich maroon from user reference swatch

    return ListenableBuilder(
      listenable: LanguageService(),
      builder: (context, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: maroonNavColor,
            statusBarIconBrightness: Brightness.light, // White icons on Android
            statusBarBrightness: Brightness.dark, // White text on iOS
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFFCF7EE),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                decoration: const BoxDecoration(
                  color: maroonNavColor, // Maroon navbar
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: Row(
                      children: [
                        // 1. Menu Icon -> Navigates directly to My Account (ProfileScreen)
                        IconButton(
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          splashRadius: 22,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 8),

                        // 2. Greeting Title and Subtitle in Telugu (White text)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppStrings.startSpiritualJourney,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        // 4. Search Icon Button (White Icon)
                        _buildCircleButton(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('శోధన త్వరలో అందుబాటులోకి వస్తుంది...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // 5. Notification Bell Icon Button with Red Dot Badge (White Icon)
                        _buildCircleButton(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ప్రస్తుతం కొత్త నోటిఫికేషన్లు ఏమీ లేవు.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                              Positioned(
                                top: -1,
                                right: -1,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1C40F), // Bright Gold badge on Maroon
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: (currentUser != null)
              ? FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots()
              : null,
          builder: (context, snapshot) {
            String name = 'Divya Mandir';
            String? photoUrl;
            if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              name = data?['name'] ?? 'Divya Mandir';
              photoUrl = data?['profile_image_url'] as String?;
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF6A1B29),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                            ? NetworkImage(photoUrl)
                            : null,
                        child: (photoUrl == null || photoUrl.isEmpty)
                            ? const Icon(Icons.person, size: 40, color: Color(0xFF6A1B29))
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle, color: Color(0xFF6A1B29)),
                  title: Text(AppStrings.myAccount, style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: Color(0xFF6A1B29)),
                  title: Text(AppStrings.language, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A1B29).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      LanguageService().isTelugu ? "తెలుగు" : "English",
                      style: const TextStyle(
                        color: Color(0xFF6A1B29),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.grey),
                  title: Text(AppStrings.settings),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          key: ValueKey('home_sections_${LanguageService().currentLanguage}'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            const HomeBannerCarousel(),
            const SizedBox(height: 8),
            HomeModulesGrid(key: ValueKey('modules_${LanguageService().currentLanguage}')),
            const SizedBox(height: 10),
            HomeDailyPanchangamCard(key: ValueKey('panchang_${LanguageService().currentLanguage}')),
            const SizedBox(height: 10),
            HomeLiveDarshanamSection(key: ValueKey('darshan_${LanguageService().currentLanguage}')),
            const SizedBox(height: 10),
            HomeRashiPalaluSection(key: ValueKey('rashi_${LanguageService().currentLanguage}')),
            const SizedBox(height: 10),
            HomeDevalayaluSection(key: ValueKey('temples_${LanguageService().currentLanguage}')),
            const SizedBox(height: 10),
            HomeNetiKathaSection(key: ValueKey('katha_${LanguageService().currentLanguage}')),
            const SizedBox(height: 10),
            HomeMantraJapamSection(key: ValueKey('mantra_${LanguageService().currentLanguage}')),
            const SizedBox(height: 10),
            HomePujaVidhanamSection(key: ValueKey('puja_${LanguageService().currentLanguage}')),
            const SizedBox(height: 10),
            HomeDevotionalStoreSection(key: ValueKey('store_${LanguageService().currentLanguage}')),
            const SizedBox(height: 25),
            // Space for upcoming home page sections
          ],
        ),
      ),
    ),
  );
      },
    );
  }
}
