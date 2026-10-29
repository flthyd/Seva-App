import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/temple_model.dart';
import '../data/telugu_temples_data.dart';
import '../utils/search_utils.dart';
import 'temple_detail_screen.dart';

class DevalayaluListScreen extends StatefulWidget {
  const DevalayaluListScreen({super.key});

  @override
  State<DevalayaluListScreen> createState() => _DevalayaluListScreenState();
}

class _DevalayaluListScreenState extends State<DevalayaluListScreen> {
  String _searchQuery = '';
  String _selectedState = 'అన్నీ';

  final List<String> _states = TeluguTemplesData.statesList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "పుణ్యక్షేత్రాలు & దేవాలయాలు",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR & MULTI-STATE FILTER SCROLLING ROW
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
                      hintText: "Search in English, తెలుగు, Hinglish (#తిరుమల, #tirupati...)",
                      hintStyle: TextStyle(fontSize: 12.5, color: Colors.black45),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF6A1B29)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Multi-State Filter Pills (Scrollable)
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _states.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final stateName = _states[idx];
                      final isSelected = _selectedState == stateName;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedState = stateName),
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
                            stateName,
                            style: TextStyle(
                              fontSize: 12.5,
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

          // 2. TEMPLE LIST STREAM
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('devalayalu')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snap) {
                List<TempleModel> temples = [];

                if (snap.hasData && snap.data != null && snap.data!.docs.isNotEmpty) {
                  temples = snap.data!.docs.map((doc) {
                    return TempleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();
                  temples.sort((a, b) => a.order.compareTo(b.order));
                }

                // If Firestore has fewer or empty items, use all 50 offline temples
                if (temples.isEmpty || temples.length < 5) {
                  temples = TeluguTemplesData.getAll50Temples();
                }

                // Apply Search & Multi-State filters (Multilingual: English, Telugu, Hinglish, Deity, Hashtags)
                final filtered = temples.where((t) {
                  final matchesSearch = SearchUtils.matchesTemple(
                    query: _searchQuery,
                    nameTelugu: t.nameTelugu,
                    nameEnglish: t.nameEnglish,
                    deity: t.deity,
                    district: t.district,
                    state: t.state,
                    hashtags: t.hashtags,
                  );

                  final matchesState = _selectedState == 'అన్నీ' ||
                      t.state.trim().toLowerCase() == _selectedState.trim().toLowerCase() ||
                      (_selectedState == 'ఇతర దివ్య క్షేత్రాలు' &&
                          !['ఆంధ్రప్రదేశ్', 'తెలంగాణ', 'కర్ణాటక', 'తమిళనాడు', 'కేరళ', 'మహారాష్ట్ర'].contains(t.state));

                  return matchesSearch && matchesState;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.temple_hindu_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "ఈ విభాగంలో దేవాలయాలు కనుగొనబడలేదు.",
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
                    final temple = filtered[idx];
                    return _buildTempleTile(context, temple);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempleTile(BuildContext context, TempleModel temple) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TempleDetailScreen(temple: temple)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Temple Photo Box
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFDECEE),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildTileImage(temple),
              ),
            ),
            const SizedBox(width: 14),

            // Information details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          temple.nameTelugu,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B29),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          temple.state,
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (temple.deity.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      temple.deity,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5565),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          temple.timings,
                          style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFB0BEC5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTileImage(TempleModel temple) {
    if (temple.imageUrl.isNotEmpty && temple.imageUrl.startsWith('http')) {
      return Image.network(
        temple.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackTileAsset(temple),
      );
    }
    return _buildFallbackTileAsset(temple);
  }

  Widget _buildFallbackTileAsset(TempleModel temple) {
    if (temple.assetPath.isNotEmpty) {
      return Image.asset(
        temple.assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29), size: 34),
      );
    }
    return const Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29), size: 34);
  }
}
