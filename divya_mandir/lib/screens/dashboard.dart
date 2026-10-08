import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'music_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(), // Tab 0: Virtual Pooja
    const MusicScreen(), // Tab 1: Devotional Music
    const Center(child: Text('Center Premium Menu', style: TextStyle(fontSize: 20))), // Tab 2: Center Lotus
    const Center(child: Text('Explore Temples Coming Soon', style: TextStyle(fontSize: 20))), // Tab 3
    const Center(child: Text('My Devotion Coming Soon', style: TextStyle(fontSize: 20))), // Tab 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Puja',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Music',
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
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'My Devotion',
            ),
          ],
        ),
      ),
    );
  }
}
