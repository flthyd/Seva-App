import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedInterests = {};

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6A1B29), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _navigateToHome,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B29),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF6A1B29)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Choose Your Interests",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B29),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Select what you love to explore",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('interests')
                      .where('is_active', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF6A1B29)),
                      );
                    }
                    
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      // Fallback dummy data if admin hasn't added any yet
                      return _buildGrid([
                        {'name': 'Pooja', 'icon': Icons.temple_hindu},
                        {'name': 'Bhajans', 'icon': Icons.music_note},
                        {'name': 'Mantras', 'icon': Icons.self_improvement},
                        {'name': 'Aarti', 'icon': Icons.local_fire_department},
                        {'name': 'Astrology', 'icon': Icons.auto_awesome},
                        {'name': 'Panchangam', 'icon': Icons.calendar_month},
                      ], true);
                    }
                    
                    return _buildGrid(docs, false);
                  },
                ),
              ),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _navigateToHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<dynamic> items, bool isDummy) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        String id;
        String name;
        String? imageUrl;
        IconData? fallbackIcon;

        if (isDummy) {
          id = index.toString();
          name = items[index]['name'];
          fallbackIcon = items[index]['icon'];
        } else {
          final doc = items[index] as QueryDocumentSnapshot;
          final data = doc.data() as Map<String, dynamic>;
          id = doc.id;
          name = data['name'] ?? 'Unknown';
          imageUrl = data['image_url'];
        }

        final isSelected = _selectedInterests.contains(id);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedInterests.remove(id);
              } else {
                _selectedInterests.add(id);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFBECEC) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF6A1B29) : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: 35,
                              height: 35,
                              color: isSelected ? const Color(0xFF6A1B29) : null,
                            )
                          : Icon(
                              fallbackIcon ?? Icons.star,
                              size: 35,
                              color: isSelected
                                  ? const Color(0xFF6A1B29)
                                  : Colors.grey,
                            ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF6A1B29) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(Icons.check_circle, color: Color(0xFF6A1B29), size: 18),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
