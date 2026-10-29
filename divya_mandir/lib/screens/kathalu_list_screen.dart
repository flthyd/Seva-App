import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/katha_model.dart';
import '../data/telugu_kathalu_data.dart';
import 'katha_detail_screen.dart';

class KathaluListScreen extends StatefulWidget {
  const KathaluListScreen({super.key});

  @override
  State<KathaluListScreen> createState() => _KathaluListScreenState();
}

class _KathaluListScreenState extends State<KathaluListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'అన్నీ';

  final List<String> _categories = ['అన్నీ', 'భాగవతం', 'రామాయణం', 'శివ పురాణం', 'గణేశ పురాణం', 'పురాణాలు'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "నేటి కథ & పురాణ కథల మాలిక",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // 1. SEARCH & CATEGORY BAR
          Container(
            color: const Color(0xFF6A1B29),
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
            child: Column(
              children: [
                // Search TextField
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    decoration: const InputDecoration(
                      hintText: "కథ పేరు లేదా కీవర్డ్ శోధించండి (ఉదా: కృష్ణుడు, హనుమంతుడు)...",
                      hintStyle: TextStyle(fontSize: 12.5, color: Colors.black45),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF6A1B29)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Pills
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF1C40F) : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFF1C40F) : Colors.white30,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF4A1A22) : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 2. KATHALU STREAM LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('neti_kathalu')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snap) {
                List<KathaModel> kathalu = [];

                if (snap.hasData && snap.data != null && snap.data!.docs.isNotEmpty) {
                  kathalu = snap.data!.docs.map((doc) {
                    return KathaModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();
                  kathalu.sort((a, b) => a.order.compareTo(b.order));
                }

                // If Firestore is empty initially, load 10 preloaded kathalu
                if (kathalu.isEmpty) {
                  kathalu = TeluguKathaluData.get10PreloadedKathalu();
                }

                // Filter by search & category
                final filtered = kathalu.where((k) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      k.title.toLowerCase().contains(_searchQuery) ||
                      k.shortSummary.toLowerCase().contains(_searchQuery) ||
                      k.fullStory.toLowerCase().contains(_searchQuery) ||
                      k.moral.toLowerCase().contains(_searchQuery);

                  final matchesCat = _selectedCategory == 'అన్నీ' || k.category == _selectedCategory;

                  return matchesSearch && matchesCat;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_stories_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "కథలు కనుగొనబడలేదు.",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(14),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final katha = filtered[idx];
                    return _buildKathaCard(context, katha);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKathaCard(BuildContext context, KathaModel katha) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => KathaDetailScreen(katha: katha)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1E4CE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image with Category Tag
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 140,
                    child: _buildBanner(katha),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1C40F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      katha.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A1A22),
                      ),
                    ),
                  ),
                ),
                if (katha.isFeaturedToday)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "నేటి కథ",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Text Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    katha.title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B29),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    katha.shortSummary,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF5A6E85), height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (katha.date.isNotEmpty) ...[
                        const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(katha.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                      const Spacer(),
                      const Text(
                        "కథ చదవండి →",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(KathaModel katha) {
    if (katha.imageUrl.isNotEmpty && katha.imageUrl.startsWith('http')) {
      return Image.network(
        katha.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(katha),
      );
    }
    return _buildFallback(katha);
  }

  Widget _buildFallback(KathaModel katha) {
    if (katha.assetPath.isNotEmpty) {
      return Image.asset(
        katha.assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF6A1B29),
          child: const Center(child: Icon(Icons.auto_stories, color: Colors.white30, size: 40)),
        ),
      );
    }
    return Container(
      color: const Color(0xFF6A1B29),
      child: const Center(child: Icon(Icons.auto_stories, color: Colors.white30, size: 40)),
    );
  }
}
