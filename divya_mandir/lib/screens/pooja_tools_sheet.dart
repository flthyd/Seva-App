import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PoojaToolsSheet extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Function(String imageUrl) onFlowerSelected;
  final Function(String imageUrl) onDhandaSelected;
  final String? currentGodName;

  const PoojaToolsSheet({
    Key? key,
    required this.audioPlayer,
    required this.onFlowerSelected,
    required this.onDhandaSelected,
    this.currentGodName,
  }) : super(key: key);

  @override
  State<PoojaToolsSheet> createState() => _PoojaToolsSheetState();
}

class _PoojaToolsSheetState extends State<PoojaToolsSheet> {
  static String? _cachedSelectedCategoryId;
  static String? _cachedSelectedCategoryName;

  String? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = _cachedSelectedCategoryId;
    _selectedCategoryName = _cachedSelectedCategoryName;
    if (_selectedCategoryId == null) {
      _fetchInitialCategory();
    }
  }

  Future<void> _fetchInitialCategory() async {
    final snap = await FirebaseFirestore.instance.collection('pooja_tools_categories').orderBy('created_at').get();
    if (snap.docs.isNotEmpty && mounted) {
      final firstData = snap.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _selectedCategoryId = snap.docs.first.id;
        _selectedCategoryName = firstData['name']?.toString().toLowerCase();
        _cachedSelectedCategoryId = _selectedCategoryId;
        _cachedSelectedCategoryName = _selectedCategoryName;
      });
    }
  }

  void _handleItemClick(Map<String, dynamic> item) async {
    String toolType = item['tool_type'] ?? '';
    if (toolType.isEmpty) {
      if (_selectedCategoryName != null && (_selectedCategoryName!.contains('tool') || _selectedCategoryName!.contains('sound'))) {
        toolType = 'Tools';
      } else {
        toolType = 'Flowers';
      }
    }
    
    final hasAudio = item['audio_url'] != null && item['audio_url'].toString().isNotEmpty;

    if (hasAudio) {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.stop);
      player.play(UrlSource(item['audio_url']));
      player.onPlayerComplete.listen((_) => player.dispose());
    }

    if (toolType == 'Flowers') {
      widget.onFlowerSelected(item['image_url']);
    } else if (toolType == 'Dhanda') {
      widget.onDhandaSelected(item['image_url']);
    }


  }

  Widget _buildGrid(List<Map<String, dynamic>> items, ScrollController scrollController) {
    if (items.isEmpty) return const Center(child: Text("No items found."));
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final data = items[index];
        return GestureDetector(
          onTap: () => _handleItemClick(data),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                    ]
                  ),
                  child: ClipOval(
                    child: data['image_url'] != null
                      ? Image.network(data['image_url'], fit: BoxFit.cover)
                      : const Icon(Icons.category, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['name'] ?? '',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFCF8F2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Offer items to ${widget.currentGodName ?? 'Deity'}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A1421)),
              ),
              const SizedBox(height: 16),
              
              // Tabs (Categories)
              SizedBox(
                height: 50,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('pooja_tools_categories').orderBy('created_at').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final isSelected = _selectedCategoryId == docs[index].id;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedCategoryId = docs[index].id;
                            _selectedCategoryName = data['name']?.toString().toLowerCase();
                            _cachedSelectedCategoryId = _selectedCategoryId;
                            _cachedSelectedCategoryName = _selectedCategoryName;
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(right: 24),
                            child: Column(
                              children: [
                                Text(
                                  data['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF6A1B29) : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (isSelected)
                                  Container(
                                    width: 40, height: 3, 
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC08B39),
                                      borderRadius: BorderRadius.circular(2)
                                    )
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
              
              const Divider(height: 1, thickness: 1, color: Colors.black12),
              
              // Items Grid
              Expanded(
                child: _selectedCategoryId == null 
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('pooja_tools_items').where('category_id', isEqualTo: _selectedCategoryId).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        
                        final toolDocs = snapshot.data!.docs;
                        
                        if (_selectedCategoryName != null && (_selectedCategoryName!.contains('tool') || _selectedCategoryName!.contains('sound'))) {
                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('bells').orderBy('created_at', descending: true).snapshots(),
                            builder: (context, bellSnapshot) {
                              List<Map<String, dynamic>> combinedItems = [];
                              
                              if (bellSnapshot.hasData) {
                                for (var bDoc in bellSnapshot.data!.docs) {
                                  final bData = bDoc.data() as Map<String, dynamic>;
                                  if (bData['is_active'] != false) {
                                    combinedItems.add({
                                      'name': bData['name'] ?? 'Temple Bell',
                                      'image_url': bData['image_url'], // Might be null, that's fine
                                      'audio_url': bData['audio_url'],
                                      'tool_type': 'Tools',
                                    });
                                  }
                                }
                              }
                              
                              for (var tDoc in toolDocs) {
                                combinedItems.add(tDoc.data() as Map<String, dynamic>);
                              }
                              
                              return _buildGrid(combinedItems, scrollController);
                            }
                          );
                        }

                        if (_selectedCategoryName != null && (_selectedCategoryName!.contains('pooja') || _selectedCategoryName!.contains('flower'))) {
                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('flowers').orderBy('created_at', descending: true).snapshots(),
                            builder: (context, flowerSnapshot) {
                              List<Map<String, dynamic>> combinedItems = [];
                              
                              if (flowerSnapshot.hasData) {
                                for (var fDoc in flowerSnapshot.data!.docs) {
                                  final fData = fDoc.data() as Map<String, dynamic>;
                                  if (fData['is_active'] != false) {
                                    combinedItems.add({
                                      'name': fData['name'] ?? 'Flower',
                                      'image_url': fData['image_url'],
                                      'tool_type': 'Flowers',
                                    });
                                  }
                                }
                              }
                              
                              for (var tDoc in toolDocs) {
                                combinedItems.add(tDoc.data() as Map<String, dynamic>);
                              }
                              
                              return _buildGrid(combinedItems, scrollController);
                            }
                          );
                        }

                        List<Map<String, dynamic>> items = toolDocs.map((e) => e.data() as Map<String, dynamic>).toList();
                        return _buildGrid(items, scrollController);
                      }
                    ),
              )
            ],
          ),
        );
      }
    );
  }
}




