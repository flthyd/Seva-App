import 'package:flutter/material.dart';
import '../models/live_darshanam_models.dart';
import 'live_darshanam_player_screen.dart';

class ModernTempleSearchScreen extends StatefulWidget {
  final List<TempleDarshanModel> temples;

  const ModernTempleSearchScreen({super.key, required this.temples});

  @override
  State<ModernTempleSearchScreen> createState() => _ModernTempleSearchScreenState();
}

class _ModernTempleSearchScreenState extends State<ModernTempleSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedState = 'అన్నీ'; // అన్నీ, ఆంధ్రప్రదేశ్, తెలంగాణ, ఉత్తర భారతదేశం

  final List<String> _popularKeywords = [
    'తిరుపతి',
    'శ్రీశైలం',
    'భద్రాచలం',
    'యాదగిరిగుట్ట',
    'విజయవాడ',
    'కాశీ',
    'అయోధ్య',
    'శివుడు',
    'వేంకటేశ్వర',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTagTap(String tag) {
    _searchController.text = tag;
    setState(() {
      _query = tag.toLowerCase().trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredTemples = widget.temples.where((t) {
      if (_selectedState != 'అన్నీ' && t.state != _selectedState) {
        return false;
      }
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      final nameMatch = t.name.toLowerCase().contains(q);
      final locMatch = t.templeLocation.toLowerCase().contains(q);
      final stateMatch = t.state.toLowerCase().contains(q);
      return nameMatch || locMatch || stateMatch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE), // Warm divine cream background
      body: SafeArea(
        child: Column(
          children: [
            // Top Modern Search Bar
            _buildSearchHeader(),

            // State Quick Filter Chips
            _buildFilterChips(),

            // Main Content: List of Results or Empty State
            Expanded(
              child: filteredTemples.isEmpty
                  ? _buildEmptyState()
                  : _buildResultsList(filteredTemples),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B29),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),

          // Modern Pill Search Input
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF6A1B29), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _query = val.trim().toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "దేవాలయం పేరు వెతకండి...",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 16, color: Colors.black54),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final states = ['అన్నీ', 'తెలంగాణ', 'ఆంధ్రప్రదేశ్', 'ఉత్తర భారతదేశం'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: states.map((st) {
                final isSelected = _selectedState == st;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(st),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6A1B29),
                    backgroundColor: const Color(0xFFF7EFE4),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF5D131F),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFEADBCE),
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedState = st);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Popular Suggestion Chips when search bar is empty
          if (_query.isEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 16, color: Color(0xFFC49A45)),
                  const SizedBox(width: 6),
                  Text(
                    'ప్రసిద్ధ క్షేత్రాలు:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _popularKeywords.map((k) {
                          return GestureDetector(
                            onTap: () => _onTagTap(k),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9EC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFF1C40F).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                k,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6A1B29),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsList(List<TempleDarshanModel> temples) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: temples.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = temples[index];
        return _buildModernTempleCard(t);
      },
    );
  }

  Widget _buildModernTempleCard(TempleDarshanModel t) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LiveDarshanamPlayerScreen(
                title: t.name,
                templeLocation: t.templeLocation,
                youtubeUrl: t.youtubeUrl,
                viewerCount: t.viewerCount,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEFE4D2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Temple Thumbnail or Deity Avatar with Live Badge
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      t.bannerImage,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.temple_hindu_rounded,
                          color: Color(0xFF6A1B29),
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                  if (t.isLive)
                    Positioned(
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 3),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 6),
                            SizedBox(width: 3),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Title, Location, and State Tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B29),
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            t.templeLocation,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.brown.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7EFE4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFEADBCE)),
                          ),
                          child: Text(
                            t.state,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D131F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.remove_red_eye_outlined, size: 13, color: Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Text(
                          '${t.viewerCount} మంది భక్తులు',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Vibrant Red Play Circle Button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 44,
                color: Color(0xFFE67E22),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'దేవాలయ ఫలితాలు దొరకలేదు',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B29),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'దయచేసి సరైన దేవాలయం పేరు లేదా ఊరి పేరుతో మళ్లీ శోధించండి.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
