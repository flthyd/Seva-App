import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mantra_model.dart';
import '../data/telugu_mantra_data.dart';
import 'mantra_japam_player_screen.dart';

class MantraListScreen extends StatefulWidget {
  const MantraListScreen({super.key});

  @override
  State<MantraListScreen> createState() => _MantraListScreenState();
}

class _MantraListScreenState extends State<MantraListScreen> {
  String _searchQuery = '';
  String _selectedDeity = 'అన్నీ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        title: const Text(
          'మంత్ర జపం నిధి (Mantra Chanting)',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mantralu')
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          List<MantraModel> mantras = [];

          if (snapshot.hasData && snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
            mantras = snapshot.data!.docs.map((doc) {
              return MantraModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            }).toList();
          }

          // Fallback to preloaded Telugu mantras if Firestore is empty
          if (mantras.isEmpty) {
            mantras = TeluguMantraData.getDefaultMantras();
          }

          // Extract distinct deities for filter tabs
          final deities = ['అన్నీ', ...mantras.map((m) => m.deity).toSet()];

          // Filter by deity & search
          final filtered = mantras.where((m) {
            final matchesDeity = (_selectedDeity == 'అన్నీ' || m.deity == _selectedDeity);
            final q = _searchQuery.toLowerCase().trim();
            final matchesQuery = q.isEmpty ||
                m.name.toLowerCase().contains(q) ||
                m.deity.toLowerCase().contains(q) ||
                m.meaning.toLowerCase().contains(q);
            return matchesDeity && matchesQuery;
          }).toList();

          return Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'మంత్రం లేదా దేవుడి పేరు శోధించండి...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6A1B29)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF1E4CE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF1E4CE)),
                    ),
                  ),
                ),
              ),

              // Deity Filter Tabs
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: deities.length,
                  itemBuilder: (context, idx) {
                    final d = deities[idx];
                    final isSel = d == _selectedDeity;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(d),
                        selected: isSel,
                        selectedColor: const Color(0xFF6A1B29),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFF6A1B29),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                        backgroundColor: const Color(0xFFFDEFD9),
                        onSelected: (val) {
                          if (val) setState(() => _selectedDeity = d);
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Mantra List
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'మంత్రాలు ఏవీ లభించలేదు.',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final mantra = filtered[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFF1E4CE)),
                            ),
                            color: Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MantraJapamPlayerScreen(mantra: mantra),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Om circle avatar
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFFDEFD9),
                                        border: Border.all(color: const Color(0xFFF0C28A)),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "ॐ",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8A1E2B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mantra.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF6A1B29),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "దేవత: ${mantra.deity} • లక్ష్యం: ${mantra.defaultTargetCount}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            mantra.meaning,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6A1B29),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
