import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageLiveDarshanamScreen extends StatefulWidget {
  const ManageLiveDarshanamScreen({super.key});

  @override
  State<ManageLiveDarshanamScreen> createState() => _ManageLiveDarshanamScreenState();
}

class _ManageLiveDarshanamScreenState extends State<ManageLiveDarshanamScreen> {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('live_darshanam');
  final DocumentReference _settingsDoc = FirebaseFirestore.instance.collection('app_settings').doc('live_darshanam');

  bool _isSectionEnabled = true;
  bool _isLoadingSettings = true;
  String _searchQuery = '';
  String _selectedStateFilter = 'అన్నీ';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await _settingsDoc.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        setState(() {
          _isSectionEnabled = data?['isEnabled'] ?? true;
          _isLoadingSettings = false;
        });
      } else {
        await _settingsDoc.set({'isEnabled': true});
        setState(() {
          _isSectionEnabled = true;
          _isLoadingSettings = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingSettings = false);
    }
  }

  Future<void> _toggleSectionEnabled(bool value) async {
    setState(() => _isSectionEnabled = value);
    try {
      await _settingsDoc.set({'isEnabled': value}, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? 'ప్రత్యక్ష దర్శనం సెక్షన్ యూజర్ యాప్‌లో ఎనేబుల్ చేయబడింది.'
                : 'ప్రత్యక్ష దర్శనం సెక్షన్ యూజర్ యాప్‌లో డిజేబుల్ చేయబడింది.'),
            backgroundColor: value ? Colors.green.shade800 : Colors.red.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        title: const Text(
          "Live Darshanam & Temple Control (ప్రత్యక్ష దర్శనం)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26),
            tooltip: 'కొత్త లైవ్ దర్శనం జోడించండి',
            onPressed: () => _openDarshanDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GLOBAL SECTION TOGGLE BANNER CARD (ENABLE / DISABLE)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isSectionEnabled ? Colors.green.shade200 : Colors.red.shade200,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isSectionEnabled ? Colors.green.shade50 : Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isSectionEnabled ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: _isSectionEnabled ? Colors.green.shade700 : Colors.red.shade700,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Home Page Live Darshanam: ${_isSectionEnabled ? 'ACTIVE (కనిపిస్తుంది)' : 'DISABLED (దాచబడింది)'}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _isSectionEnabled ? Colors.green.shade900 : Colors.red.shade900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "యూజర్ యాప్ హోమ్‌పేజీలో 'ప్రత్యక్ష దర్శనం' సెక్షన్ ఆన్/ఆఫ్ చేయండి.",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  _isLoadingSettings
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : Switch(
                          value: _isSectionEnabled,
                          activeColor: const Color(0xFF6A1B29),
                          onChanged: _toggleSectionEnabled,
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. SEARCH BAR & STATE FILTER ROW
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: "దేవాలయం లేదా ఊరి పేరు శోధించండి (Search)...",
                        prefixIcon: Icon(Icons.search, color: Color(0xFF6A1B29)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  ),
                  onPressed: () => _openDarshanDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text("Create Live Card", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. STREAMBUILDER GRID OF LIVE DARSHAN CARDS
            StreamBuilder<QuerySnapshot>(
              stream: _collection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return _buildEmptyState(context);
                }

                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? data['name'] ?? '').toString().toLowerCase();
                  final loc = (data['templeLocation'] ?? '').toString().toLowerCase();
                  if (_searchQuery.isNotEmpty && !title.contains(_searchQuery) && !loc.contains(_searchQuery)) {
                    return false;
                  }
                  return true;
                }).toList();

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    mainAxisExtent: 260,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildLiveCardItem(context, doc.id, data);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCardItem(BuildContext context, String docId, Map<String, dynamic> data) {
    final title = data['title'] ?? data['name'] ?? 'ప్రత్యక్ష దర్శనం';
    final templeLocation = data['templeLocation'] ?? 'పుణ్యక్షేత్రం';
    final customThumbnail = data['bannerImage'] ?? data['customThumbnail'] ?? '';
    final viewerCount = data['viewerCount'] ?? '10K';
    final isActive = data['isActive'] ?? data['isLive'] ?? true;
    final state = data['state'] ?? 'ఆంధ్రప్రదేశ్';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.grey.shade300 : Colors.red.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Preview with badges
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                (customThumbnail.isNotEmpty)
                    ? Image.network(
                        customThumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderThumb(),
                      )
                    : _buildPlaceholderThumb(),

                // Status Badge Top Left
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFF2D20) : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isActive ? "LIVE" : "OFFLINE",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),

                // Viewers count bottom right
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "👁 $viewerCount",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1B2028)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "$templeLocation ($state)",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B1B29), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const Spacer(),
          const Divider(height: 1),

          // Control Toolbar: Active Toggle, Edit, Delete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Active / Deactive Switch
                Text(
                  isActive ? "Active" : "Disabled",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: isActive,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      _collection.doc(docId).update({'isActive': val, 'isLive': val});
                    },
                  ),
                ),
                const Spacer(),

                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1565C0)),
                  tooltip: 'ఎడిట్ చేయండి',
                  onPressed: () => _openDarshanDialog(
                    context,
                    docId: docId,
                    existingData: data,
                  ),
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFD32F2F)),
                  tooltip: 'డిలీట్ చేయండి',
                  onPressed: () => _confirmDelete(context, docId, title),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderThumb() {
    return Container(
      color: const Color(0xFF3B151C),
      child: const Center(
        child: Icon(Icons.temple_hindu_rounded, size: 48, color: Colors.white30),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.videocam_off_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              "ప్రస్తుతం ఎటువంటి లైవ్ దర్శనం లింకులు లేవు.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            const Text(
              "మీరు పైన ఉన్న 'Create Live Card' బటన్ ద్వారా యూట్యూబ్ లైవ్ లింక్ జోడించవచ్చు.",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
              onPressed: () => _seedSampleLiveStreams(),
              icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
              label: const Text("శాంపిల్ 6 ప్రముఖ దేవాలయాలు లోడ్ చేయండి", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seedSampleLiveStreams() async {
    final batch = FirebaseFirestore.instance.batch();
    final samples = [
      {
        'title': 'శ్రీ వేంకటేశ్వర స్వామి',
        'name': 'శ్రీ వేంకటేశ్వర స్వామి',
        'templeLocation': 'తిరుమల, తిరుపతి',
        'state': 'ఆంధ్రప్రదేశ్',
        'youtubeUrl': 'https://www.youtube.com/watch?v=live_ttd_stream',
        'bannerImage': 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=800&q=80',
        'customThumbnail': 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=800&q=80',
        'viewerCount': '12.4K',
        'isActive': true,
        'isLive': true,
        'description': 'కలియుగ ప్రత్యక్ష దైవమైన శ్రీ వేంకటేశ్వర స్వామి వారి పరమ పవిత్ర సన్నిధి.',
      },
      {
        'title': 'శ్రీశైలం మల్లికార్జున స్వామి',
        'name': 'శ్రీశైలం మల్లికార్జున స్వామి',
        'templeLocation': 'శ్రీశైలం',
        'state': 'ఆంధ్రప్రదేశ్',
        'youtubeUrl': 'https://www.youtube.com/watch?v=live_srisailam_stream',
        'bannerImage': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
        'customThumbnail': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
        'viewerCount': '8.7K',
        'isActive': true,
        'isLive': true,
        'description': 'ద్వాదశ జ్యోతిర్లింగాలలో మరియు అష్టాదశ శక్తిపీఠాలలో ఒకటైన దివ్య క్షేత్రం.',
      },
      {
        'title': 'శ్రీ రాముని స్వామి',
        'name': 'శ్రీ రాముని స్వామి',
        'templeLocation': 'భద్రాచలం',
        'state': 'తెలంగాణ',
        'youtubeUrl': 'https://www.youtube.com/watch?v=live_bhadrachalam_stream',
        'bannerImage': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'customThumbnail': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'viewerCount': '6.5K',
        'isActive': true,
        'isLive': true,
        'description': 'భక్త రామదాసు నిర్మించిన దక్షిణ అయోధ్య శ్రీ సీతారామచంద్ర స్వామి ఆలయం.',
      },
      {
        'title': 'శ్రీ లక్ష్మీ నరసింహ స్వామి',
        'name': 'శ్రీ లక్ష్మీ నరసింహ స్వామి',
        'templeLocation': 'యాదగిరిగుట్ట',
        'state': 'తెలంగాణ',
        'youtubeUrl': 'https://www.youtube.com/watch?v=live_yadadri_stream',
        'bannerImage': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'customThumbnail': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'viewerCount': '5.2K',
        'isActive': true,
        'isLive': true,
        'description': 'పంచ నారసింహ క్షేత్రమైన యాదగిరిగుట్ట దివ్య పుణ్యక్షేత్రం.',
      },
    ];

    for (var s in samples) {
      final doc = _collection.doc();
      batch.set(doc, s);
    }
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('దేవాలయాల డేటా విజయవంతంగా లోడ్ అయింది!')),
      );
    }
  }

  void _openDarshanDialog(BuildContext context, {String? docId, Map<String, dynamic>? existingData}) {
    final titleCtrl = TextEditingController(text: existingData?['title'] ?? existingData?['name'] ?? '');
    final locCtrl = TextEditingController(text: existingData?['templeLocation'] ?? '');
    final stateCtrl = TextEditingController(text: existingData?['state'] ?? 'ఆంధ్రప్రదేశ్');
    final urlCtrl = TextEditingController(text: existingData?['youtubeUrl'] ?? '');
    final thumbCtrl = TextEditingController(text: existingData?['bannerImage'] ?? existingData?['customThumbnail'] ?? '');
    final viewersCtrl = TextEditingController(text: existingData?['viewerCount'] ?? '10.5K');
    final descCtrl = TextEditingController(text: existingData?['description'] ?? '');
    bool isActive = existingData?['isActive'] ?? existingData?['isLive'] ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(
                docId == null ? "కొత్త లైవ్ దర్శనం కార్డ్ (Create Live)" : "లైవ్ దర్శనం ఎడిట్ చేయండి",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'ఆలయం / స్వామివారి పేరు (Title)*',
                          hintText: 'ఉదా: శ్రీ వేంకటేశ్వర స్వామి',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: locCtrl,
                              decoration: const InputDecoration(
                                labelText: 'స్థలం / ఊరు (Location)*',
                                hintText: 'ఉదా: తిరుమల',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: stateCtrl,
                              decoration: const InputDecoration(
                                labelText: 'రాష్ట్రం (State)',
                                hintText: 'ఆంధ్రప్రదేశ్ / తెలంగాణ',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: urlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'YouTube Live Video URL లేదా Video ID*',
                          hintText: 'https://www.youtube.com/watch?v=...',
                          prefixIcon: Icon(Icons.video_library_rounded, color: Colors.red),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: thumbCtrl,
                        decoration: const InputDecoration(
                          labelText: 'గోపురం / ఆలయ బ్యానర్ ఇమేజ్ URL',
                          hintText: 'https://...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: viewersCtrl,
                        decoration: const InputDecoration(
                          labelText: 'వీక్షకుల సంఖ్య (Viewers Count Badge)',
                          hintText: 'ఉదా: 12.4K',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'స్థల పురాణం / ఆలయ సమాచారం',
                          hintText: 'క్షేత్ర మహత్యం...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('కార్డ్ యాక్టివ్‌గా ఉంచాలా? (Is Active)'),
                        subtitle: Text(isActive ? 'యాప్‌లో కనిపిస్తుంది' : 'దాచబడుతుంది'),
                        value: isActive,
                        activeColor: const Color(0xFF6A1B29),
                        onChanged: (v) => setDialogState(() => isActive = v),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("రద్దు చేయి (Cancel)"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty || urlCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('దయచేసి టైటిల్ మరియు యూట్యూబ్ లింక్ నమోదు చేయండి.')),
                      );
                      return;
                    }

                    final payload = {
                      'title': titleCtrl.text.trim(),
                      'name': titleCtrl.text.trim(),
                      'templeLocation': locCtrl.text.trim().isEmpty ? 'పుణ్యక్షేత్రం' : locCtrl.text.trim(),
                      'state': stateCtrl.text.trim().isEmpty ? 'ఆంధ్రప్రదేశ్' : stateCtrl.text.trim(),
                      'youtubeUrl': urlCtrl.text.trim(),
                      'bannerImage': thumbCtrl.text.trim(),
                      'customThumbnail': thumbCtrl.text.trim(),
                      'viewerCount': viewersCtrl.text.trim().isEmpty ? '10K' : viewersCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'isActive': isActive,
                      'isLive': isActive,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    if (docId == null) {
                      payload['createdAt'] = FieldValue.serverTimestamp();
                      await _collection.add(payload);
                    } else {
                      await _collection.doc(docId).update(payload);
                    }

                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(docId == null ? 'కొత్త లైవ్ కార్డ్ సేవ్ అయింది!' : 'లైవ్ కార్డ్ అప్‌డేట్ అయింది!'),
                        ),
                      );
                    }
                  },
                  child: const Text("సేవ్ చేయండి (Save)", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String docId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("లైవ్ కార్డ్ తొలగించాలా?", style: TextStyle(color: Colors.red)),
        content: Text("మీరు నిజంగా '$title' లైవ్ స్ట్రీమ్ కార్డును తొలగించాలనుకుంటున్నారా?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("రద్దు చేయి")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _collection.doc(docId).delete();
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('కార్డ్ విజయవంతంగా తొలగించబడింది.')),
                );
              }
            },
            child: const Text("తొలగించు (Delete)", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
