import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'music_screen.dart';
import 'status_screen.dart';
import 'main_home_screen.dart';
import 'store_screen.dart';
import '../services/language_service.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  /// Helper to allow child screens or dialogs to switch dashboard tabs
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_DashboardScreenState>();
    if (state != null) {
      state.setIndex(index);
    }
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;

  void setIndex(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    MainHomeScreen(), // Tab 0: Home
    StatusScreen(), // Tab 1: Status
    HomeScreen(), // Tab 2: Pooja (Virtual Pooja)
    MusicScreen(), // Tab 3: Devotional Music
    StoreScreen(), // Tab 4: Store
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService(),
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF6A1B29), // Maroon
              unselectedItemColor: Colors.grey.shade400,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_filled),
                  label: AppStrings.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.photo_library),
                  label: AppStrings.status,
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6A1B29),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.self_improvement, color: Colors.white),
                  ),
                  label: AppStrings.pooja,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.music_note),
                  label: AppStrings.music,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.storefront_rounded),
                  label: AppStrings.store,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
