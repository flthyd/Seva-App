import 'package:flutter/material.dart';
import '../models/live_darshanam_models.dart';
import 'live_darshanam_player_screen.dart';

class AllTemplesListScreen extends StatefulWidget {
  final List<TempleDarshanModel> temples;

  const AllTemplesListScreen({super.key, required this.temples});

  @override
  State<AllTemplesListScreen> createState() => _AllTemplesListScreenState();
}

class _AllTemplesListScreenState extends State<AllTemplesListScreen> {
  String _selectedFilter = 'అన్నీ';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openTempleDetails(BuildContext context, TempleDarshanModel t) {
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
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.temples.where((t) {
      if (_selectedFilter != 'అన్నీ' && t.state != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = t.name.toLowerCase().contains(q);
        final locMatch = t.templeLocation.toLowerCase().contains(q);
        return nameMatch || locMatch;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE), // Warm devotional cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        elevation: 3,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF1C40F), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "అన్ని దేవాలయాలు (All Temples)",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
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
                  const Icon(Icons.search_rounded, color: Color(0xFF6A1B29), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      decoration: const InputDecoration(
                        hintText: "దేవాలయం లేదా ప్రాంతం వెతకండి...",
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['అన్నీ', 'తెలంగాణ', 'ఆంధ్రప్రదేశ్', 'ఉత్తర భారతదేశం'].map((f) {
                  final isSelected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
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
                        if (val) setState(() => _selectedFilter = f);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Total count banner
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
            child: Row(
              children: [
                const Icon(Icons.temple_hindu_rounded, size: 16, color: Color(0xFFC49A45)),
                const SizedBox(width: 6),
                Text(
                  "మొత్తం దేవాలయాలు (${filtered.length})",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade800,
                  ),
                ),
              ],
            ),
          ),

          // Temples List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.temple_hindu_outlined, size: 54, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          "దేవాలయాలు కనుగొనబడలేదు",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final t = filtered[i];
                      return _buildTempleItem(context, t);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempleItem(BuildContext context, TempleDarshanModel t) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openTempleDetails(context, t),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1E4D2), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Temple Banner Image with rounded corners & Live tag
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      t.bannerImage,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.temple_hindu, color: Color(0xFF6A1B29), size: 30),
                      ),
                    ),
                  ),
                  if (t.isLive)
                    Positioned(
                      bottom: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 5),
                            SizedBox(width: 2.5),
                            Text(
                              "LIVE",
                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Title and Subtitle Info
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
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.brown.shade400),
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
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                        Icon(Icons.remove_red_eye_rounded, size: 13, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          "${t.viewerCount} మంది భక్తులు",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Trailing Action: Chevron Arrow Button in Soft Pill
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF2E6),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEADBCE)),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF6A1B29),
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
